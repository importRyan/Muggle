import Common

extension EmberMug: BluetoothPeripheral {
  package func configure(
    knownSerial: String?,
    onSerialNumberUpdate: @escaping (String) -> Void
  ) {
    peripheral.delegate = self
    self.onSerialNumberUpdate = onSerialNumberUpdate

    if let knownSerial {
      self.serial.value = knownSerial
      setupStepsRemaining.remove(.serialNumber)
    }

    onConnection = $connection
      .filter { $0 == .connected }
      .sink { [weak peripheral, weak self] _ in
        guard let self else { return }
        if setupStepsRemaining.isEmpty {
          onReconnect()
          return
        }
        Log.ember.info("\(self.debugShortIdentifier) onConnection request discoverServices")
        peripheral?.discoverServices(nil)
      }

    Log.ember.info("\(self.debugShortIdentifier) configured \(Self.self) serial: \(knownSerial ?? "unknown") local: \(self.peripheral.identifier)")
  }

  package var debugShortIdentifier: String {
    serialNumber ?? peripheral.identifier.uuidString
  }

  package var debugAllIdentifiers: String {
    [(serialNumber ?? ""), peripheral.identifier.uuidString].joined(separator: " ")
  }

  package var isSetUp: Bool {
    setupStepsRemaining.isEmpty
  }

  package var name: String {
    peripheral.name ?? "Ember"
  }
}
