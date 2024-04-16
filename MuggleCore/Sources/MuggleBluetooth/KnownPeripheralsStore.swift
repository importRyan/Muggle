import Common
import Foundation
import OrderedCollections
import SwiftUI

package struct KnownPeripheralsStore {
  package var peripherals: () -> [UUID: LocalKnownBluetoothMug]
  package var updatePeripheral: (LocalKnownBluetoothMug) -> Void

  package init(
    peripherals: @escaping () -> [UUID : LocalKnownBluetoothMug],
    updatePeripheral: @escaping (LocalKnownBluetoothMug) -> Void
  ) {
    self.peripherals = peripherals
    self.updatePeripheral = updatePeripheral
  }
}

package extension KnownPeripheralsStore {
  static func live(store: KeyValueStore) -> KnownPeripheralsStore {
    var cache: [UUID: LocalKnownBluetoothMug] = store.knownPeripherals
    return KnownPeripheralsStore(
      peripherals: { cache },
      updatePeripheral: { peripheral in
        cache[peripheral.id] = peripheral
        store.knownPeripherals = cache
      }
    )
  }
}

extension StorageKey where Value == Data {
  static var knownPeripherals: StorageKey<Data> = .init(key: "known")
}

extension KeyValueStore {
  var knownPeripherals: [LocalKnownBluetoothMug.ID: LocalKnownBluetoothMug] {
    get {
      guard let data: Data = self[.knownPeripherals] else { return [:] }
      do {
        return try JSONDecoder().decode([LocalKnownBluetoothMug.ID: LocalKnownBluetoothMug].self, from: data)
      } catch {
        Log.app.error("\(Self.self) knownPeripherals decoding error: \(error.localizedDescription)")
        return [:]
      }
    }
    nonmutating set {
      do {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data = try encoder.encode(newValue)
        self[.knownPeripherals] = data
      } catch {
        Log.app.error("\(Self.self) knownPeripherals encoding error: \(error.localizedDescription)")
      }
    }
  }
}
