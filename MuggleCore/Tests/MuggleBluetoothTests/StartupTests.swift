import Combine
import Common
import XCTest
import EmberBluetooth
@testable import MuggleBluetooth

final class ConnectionTests: XCTestCase {

  override func setUp() {
    CBMCentralManagerMock.tearDownSimulation()
    super.setUp()
  }

  func testMug_OnConnect_KeyCharacteristicsPopulate() {
    let mug = CBMPeripheralSpec.mug2(proximity: .immediate)
    var test = testBluetoothCentral(connect: mug)

    test.onFirstConnection
      .sink { device in
        XCTAssertNotNil(device.activity)
        XCTAssertNotNil(device.batteryState)
        XCTAssertNotNil(device.hasContents)
        XCTAssertNotNil(device.led)
        XCTAssertNotNil(device.temperatureTarget)
        XCTAssertNotNil(device.temperatureCurrent)
        XCTAssertFalse(device.isWriting)
      }
      .store(in: &test.subs)

    test.awaitConnection()
  }

  func testCentral_OnDisconnect_AutoReconnects() {
    let mug = CBMPeripheralSpec.mug2(proximity: .immediate)
    var test = testBluetoothCentral(connect: mug)

    let (disconnect, reconnect) = (XCTestExpectation(), XCTestExpectation())
    test.onFirstConnection
      .flatMap { $0.connectionStream.dropFirst() }
      .sink { status in
        switch status {
        case .disconnected: disconnect.fulfill()
        case .connected: reconnect.fulfill()
        default: break
        }
      }
      .store(in: &test.subs)

    test.awaitConnection()
    mug.simulateDisconnection()

    wait(for: [disconnect, reconnect], timeout: 1, enforceOrder: true)
  }

  func testCentral_OnPermissionsAuthorization_DiscoversAndAutoConnectsToNearbyMug() {
    let powersOnAfterAuthorization = XCTestExpectation()
    let connectsNearbyPeripheral = XCTestExpectation()
    var subs = Set<AnyCancellable>()

    // Arrange
    let peripheral = CBMPeripheralSpec.mug2()
    CBMCentralManagerMock.simulateAuthorization(.notDetermined)
    CBMCentralManagerMock.simulatePeripherals([peripheral])
    let central = BluetoothCentral()
    central.setup()
    central.$status
      .filter { $0 == .poweredOn }
      .fulfill(powersOnAfterAuthorization, &subs)
    central.$peripherals
      .compactMap { $0[peripheral.identifier] }
      .flatMap(\.isConnectedAndReadyForCommandsStream)
      .filter(\.isTrue)
      .fulfill(connectsNearbyPeripheral, &subs)

    // Act
    CBMCentralManagerMock.simulateAuthorization(.allowedAlways)
    CBMCentralManagerMock.simulatePowerOn()

    // Assert
    wait(for: [powersOnAfterAuthorization, connectsNearbyPeripheral], timeout: 1, enforceOrder: true)
  }
}

// MARK: - Boiler

private extension XCTestCase {

  func testBluetoothCentral(connect peripheral: CBMPeripheralSpec) -> (
    central: BluetoothCentral,
    didConnect: XCTestExpectation,
    awaitConnection: () -> Void,
    onFirstConnection: AnyPublisher<(BluetoothMug & BluetoothPeripheral), Never>,
    subs: Set<AnyCancellable>
  ) {
    CBMCentralManagerMock.simulateInitialState(.poweredOn)
    CBMCentralManagerMock.simulatePeripherals([peripheral])

    let central = BluetoothCentral()
    central.setup()

    let didConnect = XCTestExpectation()
    let onFirstConnection = central.$peripherals
      .compactMap { $0[peripheral.identifier] }
      .map { device in
        device.isConnectedAndReadyForCommandsStream
          .filter(\.isTrue)
          .map { _ in
            didConnect.fulfill()
            return device
          }
      }
      .switchToLatest()
      .eraseToAnyPublisher()

    return (
      central,
      didConnect,
      { self.wait(for: [didConnect], timeout: 1) },
      onFirstConnection,
      Set<AnyCancellable>()
    )
  }
}

private extension Publisher {
  func fulfill(_ expectation: XCTestExpectation, _ store: inout Set<AnyCancellable>) where Failure == Never {
    sink { _ in expectation.fulfill() }
      .store(in: &store)
  }
}

private extension Bool {
  var isTrue: Bool { self }
}
