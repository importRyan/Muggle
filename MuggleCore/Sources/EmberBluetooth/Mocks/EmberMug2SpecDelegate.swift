import Common
import Foundation

class EmberMug2SpecDelegate: CBMPeripheralSpecDelegate {
  // Reading
  var activity = EmberMugActivity.empty
  var battery = BatteryState(percent: 1, isCharging: true)
  var hasContents = false
  var serial: [UInt8] =  [197, 172, 22, 184, 120, 206, 80, 66, 66, 71, 49, 52, 49, 48, 53, 48, 54, 55]
  var tempCurrent = Double(0)

  // Notifying
  var push = PushEvent.charging

  // Writeable
  var led = LEDState(color: .red, brightness: 1)
  var tempTarget = Double(0)
  var tempUnit = UnitTemperature.celsius
}

extension EmberMug2SpecDelegate {

  func peripheral(
    _ peripheral: CBMPeripheralSpec,
    didReceiveReadRequestFor characteristic: CBMCharacteristicMock
  ) -> Result<Data, any Error> {
    guard let gatt = characteristic.ember() else {
      return .failure(CBMATTError(.invalidHandle))
    }
    if gatt == .push {
      return .failure(CBMATTError(.invalidHandle))
    }
    let data: Data = {
      switch gatt {
      case .activity:
        return Data([UInt8(activity.rawValue)])
      case .battery:
        return Data([UInt8(battery.percent * 100), battery.isCharging ? 1 : 0])
      case .hasContents:
        return Data([UInt8(hasContents ? 30 : 0)])
      case .led:
        return led.emberData
      case .push:
        return Data()
      case .serialNumber:
        return Data(serial)
      case .tempCurrent:
        var current = UInt16(tempCurrent * 100)
        return Data(bytes: &current, count: MemoryLayout<UInt16>.size)
      case .tempTarget:
        var target = UInt16(tempTarget * 100)
        return Data(bytes: &target, count: MemoryLayout<UInt16>.size)
      case .tempUnitPreference:
        return  Data([tempUnit.ember])
      }
    }()
    return .success(data)
  }

  func peripheral(
    _ peripheral: CBMPeripheralSpec,
    didReceiveWriteRequestFor characteristic: CBMCharacteristicMock,
    data: Data
  ) -> Result<Void, any Error> {
    guard let gatt = characteristic.ember() else {
      return .failure(CBMATTError(.invalidHandle))
    }
    switch gatt {
    case .led:
      guard let value = LEDState(ember: data)
      else { return .failure(CBMATTError(.unlikelyError)) }
      led = value

    case .tempTarget:
      guard let rawValue: UInt16 = try? data.readInteger(from: 0)
      else { return .failure(CBMATTError(.unlikelyError)) }
      tempTarget = Double(rawValue) * 0.01

    case .tempUnitPreference:
      guard
        data.bytes.count == 1,
        let byte = data.bytes.first,
        let newValue = UnitTemperature.from(ember: byte)
      else { return .failure(CBMATTError(.unlikelyError)) }
      tempUnit = newValue

    case .activity, .battery, .hasContents, .push, .serialNumber, .tempCurrent:
      return .failure(CBMATTError(.writeNotPermitted))
    }
    return .success(())
  }
}
