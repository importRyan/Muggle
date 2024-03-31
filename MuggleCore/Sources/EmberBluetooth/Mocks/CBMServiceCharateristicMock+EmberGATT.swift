import Common
import Foundation

extension CBMServiceMock {
  static let ember = CBMServiceMock(
    type: .ember.service,
    primary: true,
    characteristics: .activity, .battery, .hasContents, .led, .push, .serialNumber, .tempCurrent, .tempTarget, .tempUnit
  )
}

extension CBMCharacteristicMock {
  static let activity = CBMCharacteristicMock(
    type: .ember.Characteristics.activity.id,
    properties: [.read]
  )
  static let battery = CBMCharacteristicMock(
    type: .ember.Characteristics.battery.id,
    properties: [.read]
  )
  static let hasContents = CBMCharacteristicMock(
    type: .ember.Characteristics.hasContents.id,
    properties: [.read]
  )
  static let led = CBMCharacteristicMock(
    type: .ember.Characteristics.led.id,
    properties: [.read, .write]
  )
  static let push = CBMCharacteristicMock(
    type: .ember.Characteristics.push.id,
    properties: [.notify]
  )
  static let serialNumber = CBMCharacteristicMock(
    type: .ember.Characteristics.serialNumber.id,
    properties: [.read]
  )
  static let tempCurrent = CBMCharacteristicMock(
    type: .ember.Characteristics.tempCurrent.id,
    properties: [.read]
  )
  static let tempTarget = CBMCharacteristicMock(
    type: .ember.Characteristics.tempTarget.id,
    properties: [.read, .write]
  )
  static let tempUnit = CBMCharacteristicMock(
    type: .ember.Characteristics.tempUnitPreference.id,
    properties: [.read, .write]
  )
}
