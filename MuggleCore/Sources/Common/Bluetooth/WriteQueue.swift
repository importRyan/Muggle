import Foundation
import OrderedCollections

package final class WriteQueue<Scope: Hashable, Action> {
  @Published package private(set) var awaitingResponse = Set<Scope>()
  private var queue = OrderedDictionary<Scope, Action>()
  private let lock = NSLock()

  package init() {}
}

package extension WriteQueue {
  func awaitResponse(_ characteristic: Scope) {
    lock.lock()
    defer { lock.unlock() }
    awaitingResponse.insert(characteristic)
  }

  func removeAwaitedResponse(_ characteristic: Scope) {
    lock.lock()
    defer { lock.unlock() }
    awaitingResponse.remove(characteristic)
  }

  func removeAllAwaitedResponses() {
    lock.lock()
    defer { lock.unlock() }
    awaitingResponse.removeAll()
  }

  func addToQueue(_ characteristic: Scope, _ command: Action) {
    lock.lock()
    defer { lock.unlock() }
    queue[characteristic] = command
  }

  func popNextInQueue() -> (Scope, Action)? {
    lock.lock()
    defer { lock.unlock() }
    if queue.isEmpty { return nil }
    return queue.removeFirst()
  }
}
