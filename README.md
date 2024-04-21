#  Muggle

Muggle is a macOS menu bar app for Bluetooth smart mugs. Unlike OEM apps, your identity and activities aren't collected. [Test Flight](https://testflight.apple.com/join/gWY84Gm8)

<img width="234" alt="Demo" src="https://github.com/importRyan/Muggle/assets/78187398/cf0f3549-3bd9-413b-b7ab-205a93f360c4">


### Supported Mugs
- Ember Mug 2

Other Ember products may work. Before changing the target temperature, check with Ember's app that your maximum temperature is 63C/145F. You can use Ember's app at the same time as Muggle.

### Repo
- `MuggleMac` SwiftUI MenuBarExtra
- `MuggleBluetooth` CBCentralManager
- `EmberBluetooth` CBPeripheral and Nordic mocks for Ember products
- `Common` general utilities and the `BluetoothMug` protocol to keep UI product agnostic

## To-dos
V1.1
- [ ] Bright/fix icon
- [ ] macOS: Sort eager Settings button first responder highlighting if opened while scanning
- [ ] Confirm Travel mug support (HasContentsCharacteristic)

V1.2
- [x] Brightness and color characteristic editing
- [x] Add color to cloud-syncing
- [ ] Reduce scanning eagerness to save a little laptop battery

V1.3
- [ ] Experiment: predict cooldown time, battery life, charge time 
- [ ] Experiment: eliminate Ember's low volume overheating
- [ ] Experiment: reduce Ember's' battery consumption during cooldown phase

V1.4
- [ ] visionOS: as central
- [ ] macOS/visionOS: "remote" central

V1.5
- [ ] Non-Ember products

V1.6
- [ ] iPhone/iPad + Live Activity / Widget
