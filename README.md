#  Muggle

Muggle is a macOS menu bar app for Bluetooth smart mugs. Unlike OEM apps, your identity and activities aren't collected. [Test Flight](https://testflight.apple.com/join/gWY84Gm8)

### Supported Mugs
- Ember Mug 2

Other Ember products may work. Before changing the target temperature, check with Ember's app that your maximum temperature is 63C/145F. You can use Ember's app at the same time as Muggle.

### Repo
- `MuggleMac` SwiftUI MenuBarExtra
- `MuggleBluetooth` CBCentralManager
- `EmberBluetooth` CBPeripheral and Nordic mocks for Ember products
- `Common` general utilities and the `BluetoothMug` protocol to keep UI product agnostic

## To-dos
V1.0
- [x] Nordic integration tests
- [x] App icon inset
- [x] Add boot on login to footer during onboarding
- [x] Test Flight (privacy, XCC, solicit testers)

V1.1
- [ ] Vision Pro (as central)
- [ ] Sort eager Settings button first responder highlighting if opened while scanning
- [ ] Confirm Travel mug support (HasContentsCharacteristic)

V1.2
- [ ] Vision Pro (as shared client)

V1.3
- [ ] Brightness and color characteristics editing
- [ ] Add color to cloud-syncing

V1.4
- [ ] Use cloud-syncing to skip or trigger scanning (to save battery on laptops) / add this as an explicit preference

V1.5
- [ ] Non-Ember products

V1.6
- [ ] iPhone/iPad + Live Activity / Widget
