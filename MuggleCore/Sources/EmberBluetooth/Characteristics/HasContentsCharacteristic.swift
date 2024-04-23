import Common
import Foundation

/// Ember Mug 2 14oz CM17 seems to deliver push notifications faster than other mugs. Perhaps a gyroscope gates measurements and my pouring/sipping motions don't trigger later models.
///
/// Tumbler 16 oz CM21XL:. Completely filling or emptying the mug with warm water may take ~10-60 seconds to report (including potentially receiving a false push notification to read state that remains stale). Received: when full `1e` (30), when empty `06`. Filling halfway may never trigger a `1e` report. The current activity (e.g., heating) push update seems to occur before the push for reading the contents characteristic.
///
/// Cup 6 oz CM21S: Filling the mug with warm water is reported faster (~1-3 seconds) than pouring out that warm water (~10 seconds or possibly never). Received: when full `1e` (30), sometimes mid-pour, `0E` (14), when empty `07` and `0b` (11).
///
class HasContentsCharacteristic: BluetoothCharacteristic {
  @Published var value: Bool?
  var characteristic: CBCharacteristic?

  func parse(update data: Data) throws {
    let level: UInt8 = try data.readInteger(from: 0)
    value = level >= 30
  }
}

final class TravelMugHasContentsCharacteristic: HasContentsCharacteristic {
  override func parse(update data: Data) throws {
    let level: UInt8 = try data.readInteger(from: 0)
    value = level >= 5
  }
}
