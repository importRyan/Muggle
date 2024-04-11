import Common
import Combine
import Foundation
import OrderedCollections

package final class EmberMug: NSObject {
  @Published package var connection = ConnectionStatus.disconnected
  var onConnection: AnyCancellable?
  var onSerialNumberUpdate: ((String) -> Void)?
  package let peripheral: CBPeripheral
  @Published var setupStepsRemaining = Set(GATT.Characteristics.allCases)

  // Reading
  let activityCharacteristic = ActivityCharacteristic()
  let battery = BatteryCharacteristic()
  let hasContentsCharacteristic = HasContentsCharacteristic()
  let serial = SerialNumberCharacteristic()
  let tempCurrent = TemperatureCharacteristic()

  // Notifying
  let push = PushEventCharacteristic()

  // Writeable
  let color = LEDColorCharacteristic()
  let tempTarget = TargetTemperatureCharacteristic()
  let tempUnit = TemperatureUnitPreferenceCharacteristic()
  let writes = Writes()

  package init(_ peripheral: CBPeripheral) {
    self.peripheral = peripheral
    super.init()
  }
}

extension EmberMug {

  func onReconnect() {
    for awaitedResponse in writes.awaitingResponse {
      requestRead(awaitedResponse)
    }
    Log.ember.info("\(self.debugShortIdentifier) onReconnect requested reads: \(self.writes.awaitingResponse.map(\.debugDescription))")
    writes.removeAllAwaitedResponses()
    sendNextQueuedWrite()
  }

  func requestRead(_ characteristic: EmberMug.GATT.Characteristics) {
    guard let characteristic = self[ember: characteristic].characteristic else {
      Log.ember.error("\(self.debugShortIdentifier) readValue attempted before setup \(characteristic.debugDescription)")
      return
    }
    peripheral.readValue(for: characteristic)
  }

  func sendNextQueuedWrite() {
    guard let (_, command) = writes.popNextInQueue() else { return }
    Log.ember.info("\(self.debugShortIdentifier) writeQueue dequeue \(command.debugDescription)")
    send(command)
  }
}

// MARK: - CBPeripheralDelegate

extension EmberMug: CBPeripheralDelegate {
  package func peripheral(
    _ peripheral: CBPeripheral,
    didDiscoverServices error: (any Error)?
  ) {
    if let error {
      Log.ember.error("\(self.debugShortIdentifier) didDiscoverServices: \(peripheral.services?.map { $0.uuid } ?? []) \(error.localizedDescription)")
      return
    }
    guard let emberService = peripheral.services?.first(where: { $0.uuid == .ember.service }) else {
      let services = (peripheral.services ?? []).map(\.uuid).map(\.uuidString).joined(separator: ",")
      Log.ember.error("\(self.debugShortIdentifier) didDiscoverServices: Ember service not found. Services: \(services)")
      return
    }
    Log.ember.info("\(self.debugShortIdentifier) didDiscoverServices: EmberService")
    peripheral.discoverCharacteristics(Array(setupStepsRemaining.map(\.id)), for: emberService)
  }

  package func peripheral(
    _ peripheral: CBPeripheral,
    didDiscoverCharacteristicsFor service: CBService,
    error: (any Error)?
  ) {
    if let error {
      Log.ember.error("\(self.debugShortIdentifier) didDiscoverCharacteristicsFor: \(service.uuid) \(service.characteristics?.map(\.uuid) ?? []) \(error.localizedDescription)")
      return
    }
    for characteristic in service.characteristics ?? [] {
      guard let gatt = characteristic.ember() else { continue }
      self[ember: gatt].set(characteristic)
      if gatt == .push {
        push.mug = self
        peripheral.setNotifyValue(true, for: characteristic)
        setupStepsRemaining.remove(.push)
      } else {
        peripheral.readValue(for: characteristic)
        // Wait to remove from setupStepsRemaining until after the first read
      }
    }
  }

  package func peripheral(
    _ peripheral: CBPeripheral,
    didUpdateValueFor characteristic: CBCharacteristic,
    error: (any Error)?
  ) {
    guard let gatt = characteristic.ember() else {
      Log.ember.warning("\(self.debugShortIdentifier) didUpdateValueFor: unexpected \(characteristic.uuid.uuidString)")
      return
    }
    if let error {
      Log.ember.error("\(self.debugShortIdentifier) didUpdateValueFor: \(gatt.debugDescription) \(error.localizedDescription)")
      return
    }
    guard let data = characteristic.value else {
      Log.ember.warning("\(self.debugShortIdentifier) didUpdateValueFor: \(gatt.debugDescription) unexpected empty value")
      return
    }
    do {
      let characteristic = self[ember: gatt]
      try characteristic.parse(update: data)
      if let serial = serial.value {
        onSerialNumberUpdate?(serial)
      }
      setupStepsRemaining.remove(gatt)
      Log.ember.info("\(self.debugShortIdentifier) didUpdateValueFor: \(characteristic.debugDescription) \(data.bytes)")
    } catch {
      Log.ember.error("\(self.debugShortIdentifier) didUpdateValueFor: \(gatt.debugDescription) \(error.localizedDescription) parsing: \(data.bytes)")
    }
  }

  package func peripheral(
    _ peripheral: CBPeripheral,
    didWriteValueFor characteristic: CBCharacteristic,
    error: (any Error)?
  ) {
    guard let gatt = characteristic.ember() else {
      Log.ember.warning("\(self.debugShortIdentifier) didWriteValueFor: unexpected \(characteristic.uuid.uuidString)")
      return
    }
    if let error {
      Log.ember.error("\(self.debugShortIdentifier) didWriteValueFor: \(gatt.debugDescription) \(error.localizedDescription)")
    } else {
      Log.ember.info("\(self.debugShortIdentifier) didWriteValueFor: \(self[ember: gatt].debugDescription) (old value)")
      requestRead(gatt)
    }
    writes.removeAwaitedResponse(gatt)
    sendNextQueuedWrite()
  }
}

extension EmberMug {
  subscript(ember characteristic: GATT.Characteristics) -> any BluetoothCharacteristic {
    switch characteristic {
    case .tempCurrent: tempCurrent
    case .tempTarget: tempTarget
    case .tempUnitPreference: tempUnit
    case .hasContents: hasContentsCharacteristic
    case .activity: activityCharacteristic
    case .battery: battery
    case .push: push
    case .led: color
    case .serialNumber: serial
    }
  }

  class Writes {
    @Published private(set) var awaitingResponse = Set<GATT.Characteristics>()
    private var queue = OrderedDictionary<GATT.Characteristics, BluetoothMugCommand>()
    private let lock = NSLock()

    func awaitResponse(_ characteristic: GATT.Characteristics) {
      lock.lock()
      defer { lock.unlock() }
      awaitingResponse.insert(characteristic)
    }

    func removeAwaitedResponse(_ characteristic: GATT.Characteristics) {
      lock.lock()
      defer { lock.unlock() }
      awaitingResponse.remove(characteristic)
    }

    func removeAllAwaitedResponses() {
      lock.lock()
      defer { lock.unlock() }
      awaitingResponse.removeAll()
    }

    func addToQueue(_ characteristic: GATT.Characteristics, _ command: BluetoothMugCommand) {
      lock.lock()
      defer { lock.unlock() }
      queue[characteristic] = command
    }

    func popNextInQueue() -> (GATT.Characteristics, BluetoothMugCommand)? {
      lock.lock()
      defer { lock.unlock() }
      if queue.isEmpty { return nil }
      return queue.removeFirst()
    }
  }
}
