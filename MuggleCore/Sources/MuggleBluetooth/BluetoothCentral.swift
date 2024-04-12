import Common
import Combine
import EmberBluetooth
import Foundation
import OrderedCollections

package final class BluetoothCentral: NSObject, ObservableObject {
  @Published package var peripherals: OrderedDictionary<UUID, BluetoothMug & BluetoothPeripheral> = [:]
  @Published package var status = CBManagerState.unknown
  @Published package var isScanning = false
  private var central: CBCentralManager?
  private var isScanningUpdates: AnyCancellable?
  private var stopScanTimer: AnyCancellable?
  private var stopScanTimerExpiration: Date?
  private let known = KnownPeripheralsRegistry(persistence: .default)

  #if DEBUG
  /// - Parameter configure: Call `CBMCentralManagerMock` methods to register devices and set authorization state.
  package static func mocked(configure: (BluetoothCentral) -> Void) -> BluetoothCentral {
    let central = BluetoothCentral()
    configure(central)
    central.setup(forceMock: true)
    return central
  }
  #endif
}

package extension BluetoothCentral {
  
  func setup() {
    setup(forceMock: false)
  }

  private func setup(forceMock: Bool) {
    if central == nil {
      Log.central.info(#function)
      let central = CBCentralManagerFactory.instance(
        delegate: self,
        queue: .main,
        options: [
          CBCentralManagerOptionRestoreIdentifierKey: NSString(string: Bundle.main.uniqueAppIdentifier)
        ],
        forceMock: forceMock || CommandLine.arguments.contains("mock-bluetooth")
      )
      self.central = central
      self.isScanning = central.isScanning
      self.status = central.state
      isScanningUpdates = central
        .publisher(for: \.isScanning)
        .assign(to: \.isScanning, on: self)
    }
  }

  func scanForEmberProducts() {
    guard central?.state == .poweredOn else { return }
    Log.central.info(#function)
    central?.scanForPeripherals(
      withServices: [.ember.service],
      options: [CBCentralManagerScanOptionAllowDuplicatesKey: true]
    )
  }

  func scheduleScanStop(after seconds: TimeInterval) {
    let expiration = Date.now.advanced(by: seconds)
    if let existingExpiration = stopScanTimerExpiration, expiration < existingExpiration {
      Log.central.info("\(#function) an existing scheduled stop will end at a later time")
      return
    }
    Log.central.info("\(#function) \(seconds)")

    stopScanTimerExpiration = expiration
    stopScanTimer?.cancel()
    stopScanTimer = Timer
      .publish(every: seconds, on: .main, in: .default)
      .autoconnect()
      .first()
      .sink { [weak self] _ in
        self?.central?.stopScan()
        self?.stopScanTimerExpiration = nil
      }
  }
}

extension BluetoothCentral: CBCentralManagerDelegate {
  package func centralManagerDidUpdateState(_ central: CBCentralManager) {
    Log.central.info("\(#function) \(central.state.debugDescription)")
    status = central.state
    if status == .poweredOn && peripherals.isEmpty {
      populateCurrentlyConnectedEmberProducts()
      populatePastPeripherals()
      scanForEmberProducts()
      scheduleScanStop(after: 5 * 60)
    } else if status == .poweredOn {
      for mug in peripherals.values {
        connect(mug)
      }
    }
  }

  package func centralManager(
    _ central: CBCentralManager,
    didConnect peripheral: CBPeripheral
  ) {
    guard let mug = peripherals[peripheral.identifier] else {
      Log.central.error("didConnect unregistered peripheral \(peripheral.identifier)")
      return
    }
    Log.central.info("didConnect \(mug.debugAllIdentifiers)")
    peripherals[peripheral.identifier]?.connection = .connected
  }

  package func centralManager(
    _ central: CBCentralManager,
    didDiscover peripheral: CBPeripheral,
    advertisementData: [String : Any],
    rssi RSSI: NSNumber
  ) {
    if peripherals.keys.contains(peripheral.identifier) { return }
    let name = peripheral.name ?? "unknown"
    let manufacturerData = advertisementData.manufacturerData?.bytes ?? []
    guard advertisementData.advertisedServices.contains(.ember.service) else {
      Log.central.error("didDiscover non-Ember product \(name) \(peripheral.identifier) \(manufacturerData)")
      return
    }
    Log.central.info("didDiscover \(name) \(peripheral.identifier) \(manufacturerData)")
    let mug = registerEmber(peripheral, previouslyConnected: nil)
    connect(mug)
  }

  package func centralManager(
    _ central: CBCentralManager,
    didFailToConnect peripheral: CBPeripheral,
    error: (any Error)?
  ) {
    let errorDescription = error?.localizedDescription ?? ""
    guard let mug = peripherals[peripheral.identifier] else {
      Log.central.error("didFailToConnect unregistered peripheral \(peripheral.identifier) \(errorDescription)")
      return
    }
    Log.central.error("didFailToConnect \(mug.name) \(mug.debugAllIdentifiers) \(errorDescription)")
    mug.connection = .disconnected
  }

  package func centralManager(
    _ central: CBCentralManager,
    didDisconnectPeripheral peripheral: CBPeripheral,
    error: (any Error)?
  ) {
    let errorDescription = error?.localizedDescription ?? ""
    guard let mug = peripherals[peripheral.identifier] else {
      Log.central.error("didDisconnectPeripheral unregistered peripheral \(peripheral.identifier) \(errorDescription)")
      return
    }
    let lastConnectionState = mug.connection
    mug.connection = .disconnected
    Log.central.info("didDisconnectPeripheral \(mug.name) \(mug.debugAllIdentifiers)")
    guard [.connected, .connecting].contains(lastConnectionState) else { return }
    Log.central.info("reconnecting \(mug.name) \(mug.debugAllIdentifiers)")
    central.connect(peripheral)
  }

  package func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
    guard let restorablePeripherals = dict[CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral] else { return }
    Log.central.info("willRestoreState for: \(restorablePeripherals.map(\.identifier))")
    let knownPeripherals = known.peripheralsByLocalIds()

    for peripheral in restorablePeripherals {
      if let existing = peripherals[peripheral.identifier] {
        connect(existing)
        continue
      }
      guard peripheral.services?.map(\.uuid).contains(where: { $0 == .ember.service }) == true else {
        Log.central.error("willRestoreState unrecognized product \(peripheral.name ?? "") \(peripheral.identifier) services: \(peripheral.services?.map(\.uuid) ?? [])")
        continue
      }
      let mug = registerEmber(peripheral, previouslyConnected: knownPeripherals[peripheral.identifier])
      connect(mug)
    }
  }
}

private extension BluetoothCentral {

  func connect(_ mug: BluetoothPeripheral) {
    Log.central.info("\(#function) \(mug.debugAllIdentifiers)")
    central?.connect(mug.peripheral, options: [
      CBConnectPeripheralOptionNotifyOnConnectionKey: NSNumber(booleanLiteral: true),
      CBConnectPeripheralOptionNotifyOnDisconnectionKey: NSNumber(booleanLiteral: true),
      // TODO: - Nordic for iOS 17 CBConnectPeripheralOptionEnableAutoReconnect: NSNumber(booleanLiteral: true)
    ])
  }

  func registerEmber(_ newPeripheral: CBPeripheral, previouslyConnected: KnownPeripheral?) -> BluetoothMug & BluetoothPeripheral {
    if let alreadyRegistered = peripherals[newPeripheral.identifier] {
      return alreadyRegistered
    }
    let mug = EmberMug(newPeripheral)
    let knownPeripheral = previouslyConnected ?? KnownPeripheral(
      localBluetoothIds: [newPeripheral.identifier],
      name: mug.name,
      serial: previouslyConnected?.serial ?? ""
    )
    mug.configure(
      knownSerial: previouslyConnected?.serial,
      onSerialNumberUpdate: { [weak self] updatedSerial in
        guard let self else { return }
        var update = knownPeripheral
        update.serial = updatedSerial
        self.known.update(update)
      }
    )
    peripherals[newPeripheral.identifier] = mug
    return mug
  }

  func populateCurrentlyConnectedEmberProducts() {
    let connectedEmberPeripherals = central?.retrieveConnectedPeripherals(withServices: [.ember.service]) ?? []
    if connectedEmberPeripherals.isEmpty {
      Log.central.info("\(#function) No Currently Connected Ember Products")
    } else {
      Log.central.info("\(#function) Found Currently Connected Ember Products \(connectedEmberPeripherals.map(\.identifier))")
    }
    let knownPeripherals = known.peripheralsByLocalIds()
    for peripheral in connectedEmberPeripherals {
      let mug = registerEmber(peripheral, previouslyConnected: knownPeripherals[peripheral.identifier])
      connect(mug)
    }
  }

  func populatePastPeripherals() {
    let knownPeripheralDescriptors = known.peripherals.values.map { [$0.name, $0.serial].joined(separator: " ") }
    Log.central.info("\(#function) Attempting to Retrieve: \(knownPeripheralDescriptors.joined(separator: ","))")

    let knownPeripherals = known.peripheralsByLocalIds()
    let retrievedEmberPeripherals = central?.retrievePeripherals(withIdentifiers: Array(knownPeripherals.keys)) ?? []

    if retrievedEmberPeripherals.isEmpty {
      Log.central.info("\(#function) No Past Ember Products")
    } else {
      Log.central.info("\(#function) Retrieved \(retrievedEmberPeripherals.map(\.identifier))")
    }

    for peripheral in retrievedEmberPeripherals {
      let mug = registerEmber(peripheral, previouslyConnected: knownPeripherals[peripheral.identifier])
      connect(mug)
    }
  }
}

private extension [String : Any] {
  var advertisedServices: Set<CBUUID> {
    let services = self[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID]
    return Set(services ?? [])
  }

  var manufacturerData: Data? {
    self[CBAdvertisementDataManufacturerDataKey] as? Data
  }
}
