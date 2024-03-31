package enum ConnectionStatus: String {
  case connected
  case connecting
  case disconnected

  package var isConnected: Bool { self == .connected }
  package var isNotConnected: Bool { self != .connected }
}
