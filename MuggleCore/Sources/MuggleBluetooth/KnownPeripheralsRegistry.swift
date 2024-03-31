import Foundation
import OrderedCollections

struct KnownPeripheral: Codable, Identifiable {
  var id: String { serial }
  var localBluetoothIds: Set<UUID>
  var name: String
  var serial: String
}

final class KnownPeripheralsRegistry {
  private(set) var peripherals: OrderedDictionary<KnownPeripheral.ID, KnownPeripheral>
  private let persistence: NSUbiquitousKeyValueStore

  func peripheralsByLocalIds() -> [UUID: KnownPeripheral] {
    peripherals
      .values
      .reduce(into: [UUID: KnownPeripheral]()) { dict, peripheral in
        for id in peripheral.localBluetoothIds {
          dict[id] = peripheral
        }
      }
  }

  func update(_ known: KnownPeripheral) {
    peripherals[known.id, default: known].localBluetoothIds.formUnion(known.localBluetoothIds)
    persistence.knownPeripherals = peripherals
  }

  init(persistence: NSUbiquitousKeyValueStore) {
    self.persistence = persistence
    persistence.synchronize()
    self.peripherals = persistence.knownPeripherals
  }
}

extension NSUbiquitousKeyValueStore {
  var knownPeripherals: OrderedDictionary<KnownPeripheral.ID, KnownPeripheral> {
    get {
      guard let data = self.data(forKey: "known"),
            let peripherals = try? JSONDecoder().decode(OrderedDictionary<KnownPeripheral.ID, KnownPeripheral>.self, from: data)
      else { return [:] }
      return peripherals
    }
    set {
      let encoder = JSONEncoder()
      encoder.outputFormatting = [.sortedKeys]
      guard let data = try? encoder.encode(newValue) else { return }
      self.set(data, forKey: "known")
    }
  }
}
