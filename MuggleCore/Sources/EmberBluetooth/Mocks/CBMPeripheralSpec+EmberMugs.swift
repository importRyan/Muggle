import Common
import Foundation

package extension CBMPeripheralSpec {
  static func advertising(
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
        CBAdvertisementDataServiceUUIDsKey: [EmberGATT.service],
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

  static func connected(
    delegate: CBMPeripheralSpecDelegate = EmberMug2SpecDelegate(),
    services: [CBMServiceMock] = [.ember]
  ) -> CBMPeripheralSpec {
    simulatePeripheral(
      identifier: UUID(uuidString: "11111111-2222-2222-2222-111111111111")!,
      proximity: .immediate
    )
    .allowForRetrieval()
    .connected(
      name: "Preview Mug",
      services: services,
      delegate: delegate,
      connectionInterval: 0.001,
      mtu: 186
    )
    .build()
  }
}
