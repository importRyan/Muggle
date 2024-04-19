import Common

extension StorageKey where Value == Int {
  static var launches: StorageKey<Int> = .init(key: "launches")
}
