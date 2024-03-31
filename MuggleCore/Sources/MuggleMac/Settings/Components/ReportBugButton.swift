import SwiftUI

struct ReportBugButton: View {

  @StateObject private var report = ReportBugEmailClient()
  @State private var showReportBugPrompt = false

  var body: some View {
    Button("Report bug", systemImage: "ladybug") { showReportBugPrompt = true  }
      .labelStyle(.titleAndIcon)
      .alert(
        "Let's fix this",
        isPresented: $showReportBugPrompt,
        actions: {
          Button("App and Apple logs") { report.sendEmailWithAllLogs() }
          Button("App logs only") { report.sendEmailWithAppLogsOnly() }
          Button("Don't include logs") { report.sendEmailWithoutLogs() }
        },
        message: {
          Text("Can we send debugging logs from this session? You can see them before sending.")
        }
      )
      .sheet(isPresented: $report.isLoading) {
        VStack(spacing: 20) {
          ProgressView()
          Text("Collecting logs")
            .padding(.bottom)
          Button("Skip") { report.abandonLogsPreparationAndSendEmail() }
        }
        .padding()
        .padding()
      }
  }
}
