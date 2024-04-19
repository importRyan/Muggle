public enum ConnectionStatus: String {
  case connected
  case connecting
  case disconnected

  public var isConnected: Bool { self == .connected }
  public var isNotConnected: Bool { self != .connected }
}
