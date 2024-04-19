import Foundation

public protocol KeyValueStore {
  subscript<T>(key: StorageKey<T>) -> T? { get nonmutating set }
  subscript<T>(key: StorageKey<T>, default defaultValue: T) -> T { get nonmutating set }
}

public struct StorageKey<Value> {
  public let key: String
  public init(key: String) {
    self.key = key
  }
}

extension NSUbiquitousKeyValueStore: KeyValueStore {
  public subscript<T>(key: StorageKey<T>) -> T? {
    get { object(forKey: key.key) as? T }
    set { set(newValue, forKey: key.key) }
  }

  public subscript<T>(key: StorageKey<T>, default defaultValue: T) -> T {
    get { object(forKey: key.key) as? T ?? defaultValue }
    set { set(newValue, forKey: key.key) }
  }
}

extension UserDefaults: KeyValueStore {
  public subscript<T>(key: StorageKey<T>) -> T? {
    get { object(forKey: key.key) as? T }
    set { set(newValue, forKey: key.key) }
  }

  public subscript<T>(key: StorageKey<T>, default defaultValue: T) -> T {
    get { object(forKey: key.key) as? T ?? defaultValue }
    set { set(newValue, forKey: key.key) }
  }
}

#if DEBUG
extension KeyValueStore where Self == UserDefaults {
  public static var ephemeral: UserDefaults {
    let store = UserDefaults(suiteName: "ephemeral")!
    store.removePersistentDomain(forName: "ephemeral")
    return store
  }
}
#endif
