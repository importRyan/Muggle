import Foundation
import OSLog

public enum Log {
  public static func category(_ category: String) -> Logger {
    Logger(subsystem: Bundle.main.uniqueAppIdentifier, category: category)
  }

  public static let app = Log.category("app")
}
