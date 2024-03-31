import AppKit
import Common
import Foundation
import OSLog

final class ReportBugEmailClient: ObservableObject {
  @Published var isLoading = false
  private var store: OSLogStore?
  private var collectionTask: Task<Void, Never>?

  @MainActor
  func abandonLogsPreparationAndSendEmail() {
    isLoading = false
    collectionTask?.cancel()
    email(logs: "")
  }

  @MainActor
  func sendEmailWithoutLogs() {
    email(logs: "")
  }

  @MainActor
  func sendEmailWithAllLogs() {
    isLoading = true
    collectionTask = .detached { [weak self] in
      guard let self else { return }
      let logs = await collectLogs(predicate: nil)
      if Task.isCancelled { return }
      await email(logs: logs.map(\.formatted).joined(separator: "\n"))
    }
  }

  @MainActor
  func sendEmailWithAppLogsOnly() {
    isLoading = true
    collectionTask = .detached { [weak self] in
      guard let self else { return }
      let logs = await collectLogs(predicate: NSPredicate(format: "subsystem == %@", Bundle.main.uniqueAppIdentifier))
      if Task.isCancelled { return }
      await email(logs: logs.map(\.formattedOmitSubsystem).joined(separator: "\n"))
    }
  }
}

private extension ReportBugEmailClient {
  
  @MainActor
  func email(logs: String?) {
    self.isLoading = false
    guard let url = URL(
      email: "ryan@roastingapps.com",
      subject: "Muggle Bug: ",
      body: """
Ryan, 

I ran into an issue with Muggle. Here's what happened:



Thanks,



------------------------------------------
\(ProcessInfo.processInfo.operatingSystemVersionString)
\(Bundle.main.uniqueAppIdentifier) \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "") [\(Bundle.main.infoDictionary?["CFBundleVersion"] ?? "")]
\(logs ?? "")
"""
    ) else { return }
    NSWorkspace.shared.open(url)
  }

  func collectLogs(predicate: NSPredicate?) async -> [DatedLog] {
    do {
      try await setupStore()
      guard let entries = try store?.getEntries(with: .reverse, matching: predicate)
      else { return [] }
      return entries
        .compactMap { $0 as? OSLogEntryLog }
        .map(DatedLog.init)
    } catch {
      return [DatedLog(date: .now, level: "error", category: "logs", subsystem: "\(Self.self)", message: error.localizedDescription)]
    }
  }

  func setupStore() async throws {
    guard store == nil else { return }
    store = try OSLogStore(scope: .currentProcessIdentifier)
  }
}

private struct DatedLog {
  let date: Date
  let level: String
  let category: String
  let subsystem: String
  let message: String

  var formatted: String {
    "\(date.formatted(Self.dateFormatStyle)) \(level) \(subsystem) \(category) \(message)"
  }

  var formattedOmitSubsystem: String {
    "\(date.formatted(Self.dateFormatStyle)) \(level) \(category) \(message)"
  }

  private static let dateFormatStyle: Date.FormatStyle = .dateTime.month(.twoDigits).day(.twoDigits).hour(.twoDigits(amPM: .omitted)).minute(.twoDigits).second(.twoDigits).secondFraction(.fractional(2))
}

extension DatedLog {
  init(log: OSLogEntryLog) {
    date = log.date
    category = log.category
    subsystem = log.subsystem
    level = log.level.debugDescription
    message = log.composedMessage
  }
}

extension OSLogEntryLog.Level: CustomDebugStringConvertible {
  public var debugDescription: String {
    switch self {
    case .undefined: "undefined"
    case .debug: "debug"
    case .info: "info"
    case .notice: "notice"
    case .error: "error"
    case .fault: "fault"
    @unknown default: "unknown"
    }
  }
}
