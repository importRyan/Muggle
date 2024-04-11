import Common
import Foundation

package extension CBMPeripheralSpec {
  static func mug2(
    id: UUID = UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
    proximity: CBMProximity = .immediate
  ) -> CBMPeripheralSpec {
    simulatePeripheral(
      identifier: id,
      proximity: proximity
    )
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
}
