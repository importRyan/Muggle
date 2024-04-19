import SwiftUI

struct QuitButton: View {
  var body: some View {
    Button("Quit") {
      NSApp.terminate(nil)
    }
  }
}
