import Common
import SwiftUI

public struct BluetoothCentralStatusHint: View {
  public let status: CBManagerState
  public let noPeripherals: Bool

  public init(status: CBManagerState, noPeripherals: Bool) {
    self.status = status
    self.noPeripherals = noPeripherals
  }

  public var body: some View {
    switch status {
    case .poweredOn:
      if noPeripherals {
        NoDevicesInstructionsView()
      }
    case .poweredOff:
      TurnOnBluetoothNotice()

    case .resetting:
      BluetoothResettingNotice()
        .padding()

    case .unauthorized:
      AuthorizeBluetoothView()
        .padding(20)

    case .unknown, .unsupported:
      BluetoothUnsupportedView()
        .padding(20)
    }
  }
}

struct BluetoothUnsupportedView: View {
  var body: some View {
    ContentUnavailableView("Bluetooth unsupported", systemImage: "antenna.radiowaves.left.and.right.slash")
  }
}

struct BluetoothResettingNotice: View {
  var body: some View {
    Label("Bluetooth Resetting", systemImage: "antenna.radiowaves.left.and.right.slash")
      .modifier(NoticeCapsule())
  }
}

struct TurnOnBluetoothNotice: View {
  var body: some View {
    Label("Bluetooth Off", systemImage: "antenna.radiowaves.left.and.right.slash")
      .modifier(NoticeCapsule())
  }
}

struct NoticeCapsule: ViewModifier {
  func body(content: Content) -> some View {
    content
      .padding(.horizontal)
      .padding(.vertical, 8)
      .background(.ultraThickMaterial, in: .capsule)
  }
}
