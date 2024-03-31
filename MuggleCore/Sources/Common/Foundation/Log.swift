import Foundation
import OSLog

package enum Log {
  package static func category(_ category: String) -> Logger {
    Logger(subsystem: Bundle.main.uniqueAppIdentifier, category: category)
  }

  package static let app = Log.category("app")
}
