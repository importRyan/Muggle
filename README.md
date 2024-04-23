#  Muggle

Muggle is a macOS menu bar app for Bluetooth smart mugs. Unlike OEM apps, your identity and activities aren't collected. [Test Flight](https://testflight.apple.com/join/gWY84Gm8)

<img width="234" alt="Demo" src="https://github.com/importRyan/Muggle/assets/78187398/cf0f3549-3bd9-413b-b7ab-205a93f360c4">


### Supported Mugs
- Ember Mug 2 14 oz (tested: CM19P)
- Ember Tumbler 16 oz (tested: CM21XL)
- Ember Cup 6 oz (tested: CM21S)

Caution: Before setting the max target temperature, check with Ember's app that the maximum temperature is 63C/145F. You can use Ember's app at the same time as Muggle.

### Quick repo overview

Various brands of BLE mugs are abstracted behind a `BluetoothMug` and `BluetoothPeripheral` protocol to keep the view layer agnostic to specific models. Nordic's CoreBluetoothMock library enables stable unit testing on CI.

| Package\Target               | Purpose                                                          |
|------------------------------|------------------------------------------------------------------|
| `MuggleMac`                  | SwiftUI MenuBarExtra                                             |
| `MuggleCore\MuggleBluetooth` | CBCentralManager                                                 |
| `MuggleCore\EmberBluetooth`  | Ember CBPeripheral(s) + Nordic mocks                             |
| `MuggleCore\VFZOBluetooth`   | VFZO M1 CBPeripheral + Nordic mocks                              |
| `MuggleCore\Common`          | BluetoothMug/Peripheral protocol + Nordic CoreBluetoothMock shim |
| `MuggleCore\CommonUI`        | Cross-platform SwiftUI                                           |


## To-dos
V1.0.2
- [ ] Icon: brighten/de-cheese
- [ ] Verify behavior: Travel mug (HasContentsCharacteristic, Service)
- [x] Verify behavior: Tumbler
- [x] Verify behavior: Cup
- [ ] fix: When keyboard navigation enabled, the Settings button appears with a focus ring

V1.1
- [ ] Experiment: predict cooldown time, battery life, charge time 
- [ ] VFZO M1 mug support

Features
- [ ] Experiment: eliminate Ember's low volume overheating
- [ ] Experiment: reduce Ember's' battery consumption during cooldown phase
- [ ] More non-Ember products
- [ ] visionOS: as central
- [ ] macOS/visionOS: "remote" central
- [ ] iPhone/iPad + Live Activity / Widget
- [ ] Improve onboarding

Tasks/Fixes
- [ ] Scanner efficiency: Reduce eagerness to save a little laptop battery / turn on manually after initial session
- [ ] Forget a mug: cache forgotten IDs to prevent mugs in discovery mode from automatically reconnecting if scanning
- [ ] Multi-muggers: select mug for MenuBar or allow multiple in MenuBar
