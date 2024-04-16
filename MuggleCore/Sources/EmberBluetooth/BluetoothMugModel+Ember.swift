import Foundation
import Common

package extension BluetoothMugModel.EmberModel {
  func build(_ peripheral: CBPeripheral) -> BluetoothMug & BluetoothPeripheral {
    EmberMug(peripheral, self)
  }

  /// TODO: - Travel Mug Support
  init?(advertisedServices services: Set<CBUUID>) {
    if services.contains(EmberGATT.serviceTravelMug) {
      self = .travel
    } else if services.contains(EmberGATT.service) {
      self = .mug
    } else {
      return nil
    }
  }
}

extension BluetoothMugModel.EmberModel {
  var hasContentsCharacteristic: HasContentsCharacteristic {
    switch self {
    case .mug: HasContentsCharacteristic()
    case .travel: TravelMugHasContentsCharacteristic()
    }
  }
}
