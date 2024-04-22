import Common
import Combine
import Foundation
import OrderedCollections

final class VFZOMug: NSObject {
  @Published var connection = ConnectionStatus.disconnected
  private var onConnection: AnyCancellable?
  var onIdentityUpdate: ((LocalKnownBluetoothMug) -> Void)?
  let peripheral: CBPeripheral
  private let model: BluetoothMugModel
  @Published var setupStepsRemaining = Set(VFZOGATT.Characteristics.allCases)

  // Reading
  let readUnknownA = GenericReverseEngineeringCharacteristic(name: "UnknownA")
  let readUnknown5 = GenericReverseEngineeringCharacteristic(name: "Unknown5")

  // Notifying
  let push = PushEventCharacteristic()

  // Writeable
  let writes = WriteQueue<VFZOGATT.Characteristics, BluetoothMugCommand>()

  init(_ peripheral: CBPeripheral, _ model: BluetoothMugModel.VFZOModel) {
    self.model = .vfzo(model)
    self.peripheral = peripheral
    super.init()

    peripheral.delegate = self

    onConnection = $connection
      .filter { $0 == .connected }
      .sink { [weak peripheral, weak self] _ in
        guard let self else { return }
        if setupStepsRemaining.isEmpty {
          onReconnect()
          return
        }
        Log.vfzo.info("\(self.debugShortIdentifier) onConnection request discoverServices")
        peripheral?.discoverServices(nil)
      }
  }
}

extension VFZOMug {

  func onReconnect() {
    for awaitedResponse in writes.awaitingResponse {
      requestRead(awaitedResponse)
    }
    Log.vfzo.info("\(self.debugShortIdentifier) onReconnect requested reads: \(self.writes.awaitingResponse.map(\.debugDescription))")
    writes.removeAllAwaitedResponses()
    sendNextQueuedWrite()
  }

  func requestRead(_ characteristic: VFZOGATT.Characteristics) {
    guard let characteristic = self[vfzo: characteristic].characteristic else {
      Log.vfzo.error("\(self.debugShortIdentifier) readValue attempted before setup \(characteristic.debugDescription)")
      return
    }
    peripheral.readValue(for: characteristic)
  }

  func sendNextQueuedWrite() {
    guard let (_, command) = writes.popNextInQueue() else { return }
    Log.vfzo.info("\(self.debugShortIdentifier) writeQueue dequeue \(command.debugDescription)")
    send(command)
  }
}

// MARK: - CBPeripheralDelegate

extension VFZOMug: CBPeripheralDelegate {
  func peripheral(
    _ peripheral: CBPeripheral,
    didDiscoverServices error: (any Error)?
  ) {
    if let error {
      Log.vfzo.error("\(self.debugShortIdentifier) didDiscoverServices: \(peripheral.services?.map { $0.uuid } ?? []) \(error.localizedDescription)")
      return
    }
//    for service in peripheral.services ?? [] {
//      peripheral.discoverCharacteristics(nil, for: service)
//    }
    guard let primaryService = peripheral.services?.first(where: { $0.uuid == .vfzo.service }) else {
      let services = (peripheral.services ?? []).map(\.uuid).map(\.uuidString).joined(separator: ",")
      Log.vfzo.error("\(self.debugShortIdentifier) didDiscoverServices: VFZO Primary service not found. Services: \(services)")
      return
    }
    Log.vfzo.info("\(self.debugShortIdentifier) didDiscoverServices: \(peripheral.services?.map(\.uuid.uuidString) ?? [])")
    peripheral.discoverCharacteristics(Array(setupStepsRemaining.map(\.id)), for: primaryService)
  }

  func peripheral(
    _ peripheral: CBPeripheral,
    didDiscoverCharacteristicsFor service: CBService,
    error: (any Error)?
  ) {
    if let error {
      Log.vfzo.error("\(self.debugShortIdentifier) didDiscoverCharacteristicsFor: \(service.uuid) \(service.characteristics?.map(\.uuid) ?? []) \(error.localizedDescription)")
      return
    }
    for characteristic in service.characteristics ?? [] {
      Log.vfzo.debug("\(self.debugShortIdentifier) didDiscoverCharacteristic \(characteristic.uuid.uuidString)")
      guard let gatt = characteristic.vfzo() else { continue }
      self[vfzo: gatt].set(characteristic)
      if gatt == .push {
//        push.mug = self
        peripheral.setNotifyValue(true, for: characteristic)
        setupStepsRemaining.remove(.push)
      } else {
        peripheral.readValue(for: characteristic)
        // Wait to remove from setupStepsRemaining until after the first read
      }
    }
  }

  func peripheral(
    _ peripheral: CBPeripheral,
    didUpdateValueFor characteristic: CBCharacteristic,
    error: (any Error)?
  ) {
    guard let gatt = characteristic.vfzo() else {
      Log.vfzo.warning("\(self.debugShortIdentifier) didUpdateValueFor: unexpected \(characteristic.uuid.uuidString)")
      return
    }
    if let error {
      Log.vfzo.error("\(self.debugShortIdentifier) didUpdateValueFor: \(gatt.debugDescription) \(error.localizedDescription)")
      return
    }
    guard let data = characteristic.value else {
      Log.vfzo.warning("\(self.debugShortIdentifier) didUpdateValueFor: \(gatt.debugDescription) unexpected empty value")
      return
    }
    do {
      let characteristic = self[vfzo: gatt]
      try characteristic.parse(update: data)
      updateIdentityIfNeeded(gatt)
      setupStepsRemaining.remove(gatt)
      Log.vfzo.info("\(self.debugShortIdentifier) didUpdateValueFor: \(characteristic.debugDescription) \(data.bytes)")
    } catch {
      Log.vfzo.error("\(self.debugShortIdentifier) didUpdateValueFor: \(gatt.debugDescription) \(error.localizedDescription) parsing: \(data.bytes)")
    }
  }

  func peripheral(
    _ peripheral: CBPeripheral,
    didWriteValueFor characteristic: CBCharacteristic,
    error: (any Error)?
  ) {
//    guard let gatt = characteristic.ember() else {
//      Log.vfzo.warning("\(self.debugShortIdentifier) didWriteValueFor: unexpected \(characteristic.uuid.uuidString)")
//      return
//    }
//    if let error {
//      Log.vfzo.error("\(self.debugShortIdentifier) didWriteValueFor: \(gatt.debugDescription) \(error.localizedDescription)")
//    } else {
//      Log.vfzo.info("\(self.debugShortIdentifier) didWriteValueFor: \(self[ember: gatt].debugDescription) (old value)")
//      requestRead(gatt)
//    }
//    writes.removeAwaitedResponse(gatt)
    sendNextQueuedWrite()
  }
}

extension VFZOMug {
  subscript(vfzo characteristic: VFZOGATT.Characteristics) -> any BluetoothCharacteristic {
    switch characteristic {
    case .push: push
    case .readUnknownA: readUnknownA
    case .readUnknown5: readUnknown5
    }
  }
}

private extension VFZOMug {
  func updateIdentityIfNeeded(_ updatedCharacteristic: VFZOGATT.Characteristics) {
//    guard [.serialNumber, .led].contains(updatedCharacteristic),
//          let serial = serial.value,
//          let led
//    else { return }
//    let identity = LocalKnownBluetoothMug(
//      localCBUUID: peripheral.identifier,
//      mug: KnownBluetoothMug(
//        led: led,
//        model: model,
//        name: name,
//        serial: serial
//      )
//    )
//    onIdentityUpdate?(identity)
  }
}
