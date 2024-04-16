import SwiftUI

struct AppSettings: View {

  var body: some View {
    #if os(macOS)
    LaunchAtLoginToggle()
      .padding()
    #endif
  }
}
