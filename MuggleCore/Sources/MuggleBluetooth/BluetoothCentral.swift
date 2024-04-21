import Common
import Combine
import EmberBluetooth
import Foundation

public final class BluetoothCentral: NSObject, ObservableObject {
  @Published public var peripherals: Dictionary<UUID, BluetoothMug & BluetoothPeripheral> = [:]
  @Published public var status = CBManagerState.unknown
  @Published public var isScanning = false
  private var central: CBCentralManager?
  private var isScanningUpdates: AnyCancellable?
  private var stopScanTimer: AnyCancellable?
  private var stopScanTimerExpiration: Date?
  private let known: KnownPeripheralsStore

  public init(knownPeripheralsStore: KnownPeripheralsStore) {
    self.known = knownPeripheralsStore
    super.init()
  }

  #if DEBUG
  /// - Parameter configure: Call `CBMCentralManagerMock` methods to register devices and set authorization state.
  public static func mocked(
    knownPeripheralsStore: KnownPeripheralsStore,
    configure: (BluetoothCentral) -> Void
  ) -> BluetoothCentral {
    let central = BluetoothCentral(knownPeripheralsStore: knownPeripheralsStore)
    configure(central)
    central.setup(forceMock: true)
    return central
  }
  #endif
}

public extension BluetoothCentral {

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
  public func centralManagerDidUpdateState(_ central: CBCentralManager) {
    Log.central.info("\(#function) \(central.state.debugDescription)")
    status = central.state
    if status == .poweredOn && peripherals.isEmpty {
      populatePastPeripherals()
      // TODO: - Travel Mug Support
      populateEmberMugsCurrentlyConnectedByOtherApps()
      scanForEmberProducts()
      scheduleScanStop(after: 5 * 60)
    } else if status == .poweredOn {
      for mug in peripherals.values {
        connect(mug)
      }
    }
  }

  public func centralManager(
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

  public func centralManager(
    _ central: CBCentralManager,
    didDiscover peripheral: CBPeripheral,
    advertisementData: [String : Any],
    rssi RSSI: NSNumber
  ) {
    if let existing = peripherals[peripheral.identifier] {
      if existing.connection.isNotConnected {
        connect(existing)
      }
      return
    }
    let name = peripheral.name ?? "unknown"
    let manufacturerData = advertisementData.manufacturerData?.bytes ?? []
    do {
      Log.central.info("didDiscover \(name) \(peripheral.identifier) \(manufacturerData)")
      let mug = try registerNew(peripheral, advertisementData.advertisedServices)
      connect(mug)
    } catch {
      Log.central.error("didDiscover unsupported product \(name) \(manufacturerData)")
    }
  }

  public func centralManager(
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

  public func centralManager(
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

  public func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
    guard let restorablePeripherals = dict[CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral] else { return }
    Log.central.info("willRestoreState for: \(restorablePeripherals.map(\.identifier))")
    for peripheral in restorablePeripherals {
      if let existing = peripherals[peripheral.identifier] {
        connect(existing)
        continue
      }
      guard let knownPeripheral = known.peripherals()[peripheral.identifier] else {
        Log.central.error("willRestoreState for unrecognized peripheral: \(peripheral.identifier) services: \(peripheral.services?.map(\.uuid) ?? [])")
        do {
          let mug = try registerNew(peripheral, Set(peripheral.services?.map(\.uuid) ?? []))
          connect(mug)
        } catch {
          Log.central.error("willRestoreState failed to re-register unsupported peripheral: \(peripheral.identifier)")
        }
        continue
      }
      let mug = registerKnown(peripheral, knownPeripheral)
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

  /// TODO: - Travel Mug Support
  func populateEmberMugsCurrentlyConnectedByOtherApps() {
    guard let central else {
      Log.central.error("\(#function) Central Not Instantiated")
      return
    }
    let emberMugs = central.retrieveConnectedPeripherals(withServices: [.ember.service])
    Log.central.info("\(#function) Found \(emberMugs.count) Currently Connected Ember Products")
    for mug in emberMugs {
      do {
        let registeredMug = try registerNew(mug, [.ember.service])
        connect(registeredMug)
      } catch {
        Log.central.error("\(#function) Unsupported Product \(mug.name ?? "") \(mug.identifier)")
      }
    }
  }

  func populatePastPeripherals() {
    guard let central else {
      Log.central.error("\(#function) \(Self.self) Not Setup")
      return
    }
    Log.central.info("\(#function) Known: \(self.known.peripherals().values.map { [$0.mug.name, $0.localCBUUID.uuidString, $0.mug.serial].joined(separator: " ") }.joined(separator: ","))")
    if known.peripherals().isEmpty { return }

    let retrievedPeripherals = central.retrievePeripherals(withIdentifiers: known.peripherals().values.map(\.localCBUUID))
    Log.central.info("\(#function) Retrieved \(retrievedPeripherals.count): \(retrievedPeripherals.map(\.identifier))")

    for peripheral in retrievedPeripherals {
      guard let knownPeripheral = known.peripherals()[peripheral.identifier] else {
        Log.central.error("\(#function) Expected Peripheral Not Found \(peripheral.identifier)")
        continue
      }
      let mug = registerKnown(peripheral, knownPeripheral)
      connect(mug)
    }
  }

  func registerKnown(
    _ newPeripheral: CBPeripheral,
    _ previouslyConnected: LocalKnownBluetoothMug
  ) -> BluetoothMug & BluetoothPeripheral {
    if let alreadyRegistered = peripherals[newPeripheral.identifier] {
      return alreadyRegistered
    }
    let mug = previouslyConnected.mug.model.build(newPeripheral)
    peripherals[newPeripheral.identifier] = mug
    mug.configure(
      known: previouslyConnected,
      onUpdate: { [weak self] identity in
        self?.known.updatePeripheral(identity)
      }
    )
    return mug
  }

  func registerNew(
    _ newPeripheral: CBPeripheral,
    _ advertisedServices: Set<CBUUID>
  ) throws -> BluetoothMug & BluetoothPeripheral {
    if let alreadyRegistered = peripherals[newPeripheral.identifier] {
      return alreadyRegistered
    }
    guard let model = BluetoothMugModel.EmberModel(advertisedServices: advertisedServices) else {
      throw BluetoothCentralError.unsupportedDevice
    }
    let mug = model.build(newPeripheral)
    peripherals[newPeripheral.identifier] = mug
    mug.configure(
      known: nil,
      onUpdate: { [weak self] identity in
        self?.known.updatePeripheral(identity)
      }
    )
    return mug
  }
}

private enum BluetoothCentralError: Error {
  case unsupportedDevice
}

private extension BluetoothMugModel {
  func build(_ peripheral: CBPeripheral) -> BluetoothMug & BluetoothPeripheral {
    switch self {
    case .ember(let model):
      model.build(peripheral)
    }
  }
}
