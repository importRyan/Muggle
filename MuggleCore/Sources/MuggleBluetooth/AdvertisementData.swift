import Common
import Foundation

extension [String : Any] {
  var advertisedServices: Set<CBUUID> {
    let services = self[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID]
    return Set(services ?? [])
  }

  var manufacturerData: Data? {
    self[CBAdvertisementDataManufacturerDataKey] as? Data
  }
}
