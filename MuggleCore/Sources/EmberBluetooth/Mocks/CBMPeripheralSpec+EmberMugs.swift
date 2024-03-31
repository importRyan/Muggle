import Common
import Foundation

package extension CBMPeripheralSpec {
  static let mug2Connectable = CBMPeripheralSpec
    .simulatePeripheral()
    .advertising(
      advertisementData: [
        CBAdvertisementDataLocalNameKey: "Ember Ceramic Mug",
        CBAdvertisementDataServiceUUIDsKey: [EmberMug.GATT.service],
        CBAdvertisementDataIsConnectable: true as NSNumber
      ],
      withInterval: 0.250
    )
    .connectable(
      name: "Ember Ceramic Mug",
      services: [.ember],
      delegate: EmberMug2SpecDelegate(),
      connectionInterval: 0.045,
      mtu: 186
    )
    .build()
}
