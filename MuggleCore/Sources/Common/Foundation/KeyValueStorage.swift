import Foundation

package protocol KeyValueStore {
  subscript<T>(key: StorageKey<T>) -> T? { get nonmutating set }
  subscript<T>(key: StorageKey<T>, default defaultValue: T) -> T { get nonmutating set }
}

package struct StorageKey<Value> {
  package let key: String
  package init(key: String) {
    self.key = key
  }
}

extension NSUbiquitousKeyValueStore: KeyValueStore {
  package subscript<T>(key: StorageKey<T>) -> T? {
    get { object(forKey: key.key) as? T }
    set { set(newValue, forKey: key.key) }
  }

  package subscript<T>(key: StorageKey<T>, default defaultValue: T) -> T {
    get { object(forKey: key.key) as? T ?? defaultValue }
    set { set(newValue, forKey: key.key) }
  }
}

extension UserDefaults: KeyValueStore {
  package subscript<T>(key: StorageKey<T>) -> T? {
    get { object(forKey: key.key) as? T }
    set { set(newValue, forKey: key.key) }
  }

  package subscript<T>(key: StorageKey<T>, default defaultValue: T) -> T {
    get { object(forKey: key.key) as? T ?? defaultValue }
    set { set(newValue, forKey: key.key) }
  }
}

#if DEBUG
extension KeyValueStore where Self == UserDefaults {
  package static var ephemeral: UserDefaults {
    let store = UserDefaults(suiteName: "ephemeral")!
    store.removePersistentDomain(forName: "ephemeral")
    return store
  }
}
#endif
