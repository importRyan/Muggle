import Common

extension VFZOMug: BluetoothPeripheral {
  func configure(
    known: LocalKnownBluetoothMug?,
    onUpdate: @escaping (LocalKnownBluetoothMug) -> Void
  ) {
    self.onIdentityUpdate = onUpdate

    //    if let knownSerial = known?.mug.serial {
    //      self.serial.value = knownSerial
    //      setupStepsRemaining.remove(.serialNumber)
    //    }
    //
    //    if let knownLED = known?.mug.led {
    //      self.color.value = knownLED
    //      // Always fetch on connection because Ember's app could change this while Muggle isn't running.
    //    }
    //
    //    Log.zfzo.info("\(self.debugShortIdentifier) configured \(Self.self) serial: \(known?.mug.serial ?? "unknown") local: \(self.peripheral.identifier)")
    Log.vfzo.info("\(self.debugShortIdentifier) configured \(Self.self) local: \(self.peripheral.identifier)")
  }

  var debugShortIdentifier: String {
    peripheral.identifier.uuidString
//    serialNumber ?? peripheral.identifier.uuidString
  }

  var debugAllIdentifiers: String {
    peripheral.identifier.uuidString
//    [(serialNumber ?? ""), peripheral.identifier.uuidString].joined(separator: " ")
  }

  var isSetUp: Bool {
    setupStepsRemaining.isEmpty
  }

  var name: String {
    peripheral.name ?? "VFZO"
  }
}
