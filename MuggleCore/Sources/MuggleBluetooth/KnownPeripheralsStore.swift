import Common
import Foundation
import SwiftUI

public struct KnownPeripheralsStore {
  public var peripherals: () -> [UUID: LocalKnownBluetoothMug]
  public var updatePeripheral: (LocalKnownBluetoothMug) -> Void
  public var forget: (LocalKnownBluetoothMug.ID) -> Void

  public init(
    peripherals: @escaping () -> [UUID : LocalKnownBluetoothMug],
    updatePeripheral: @escaping (LocalKnownBluetoothMug) -> Void,
    forget: @escaping (LocalKnownBluetoothMug.ID) -> Void
  ) {
    self.peripherals = peripherals
    self.forget = forget
    self.updatePeripheral = updatePeripheral
  }
}

public extension KnownPeripheralsStore {
  static func live(store: KeyValueStore) -> KnownPeripheralsStore {
    var cache: [UUID: LocalKnownBluetoothMug] = store.knownPeripherals
    return KnownPeripheralsStore(
      peripherals: { cache },
      updatePeripheral: { peripheral in
        cache[peripheral.id] = peripheral
        store.knownPeripherals = cache
      },
      forget: { id in
        cache.removeValue(forKey: id)
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
