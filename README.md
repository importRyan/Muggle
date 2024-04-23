#  Muggle

Muggle is a macOS menu bar app for Bluetooth smart mugs. Unlike OEM apps, your identity and activities are not collected.

[Test Flight](https://testflight.apple.com/join/gWY84Gm8) | [Supported Mugs](#supported-mugs) | [Repo Overview](#repo-overview) | [To-Dos](#tasks) 

| At Target Temp | Heating/Cooling |
| ---------------|--------------------|
| <img width="443" alt="AtTargetTemp" src="https://github.com/importRyan/Muggle/assets/78187398/74472572-6b1d-4acd-a1e6-f91da4dc1c5b"> | <img width="443" alt="NotAtTargetTemp" src="https://github.com/importRyan/Muggle/assets/78187398/9c9b66cc-93ab-4290-b8a2-06976b432211"> |


### Supported Mugs
- Ember Cup 6 oz (tested: CM21S)
- Ember Mug 2 14 oz (tested: CM19P)
- Ember Tumbler 16 oz (tested: CM21XL)

> [!CAUTION]
Check the max target temperature of your mug in Ember's app. Muggle's max is 63℃ (145℉). If that doesn't match Ember's app, I'd appreciate an [email](mailto:ryan@roastingapps.com) about it. Don't set a higher temp (as I lack your device and have not tested whether Ember wrote a safeguard into its firmware).

### Repo overview

Various brands of BLE mugs are abstracted behind a `BluetoothMug` and `BluetoothPeripheral` protocol to keep the view layer agnostic to specific models. Nordic's CoreBluetoothMock library enables stable unit testing on CI.

| Package\Target               | Purpose                                                          |
|------------------------------|------------------------------------------------------------------|
| `MuggleMac`                  | SwiftUI MenuBarExtra                                             |
| `MuggleCore\MuggleBluetooth` | CBCentralManager                                                 |
| `MuggleCore\EmberBluetooth`  | Ember CBPeripheral(s) + Nordic mocks                             |
| `MuggleCore\VFZOBluetooth`   | VFZO M1 CBPeripheral + Nordic mocks                              |
| `MuggleCore\Common`          | BluetoothMug/Peripheral protocol + Nordic CoreBluetoothMock shim |
| `MuggleCore\CommonUI`        | Cross-platform SwiftUI                                           |


## Tasks
#### V1.0.2
- [ ] Icon: brighten/de-cheese
- [ ] Verify behavior: Travel mug (HasContentsCharacteristic, Service)
- [x] Verify behavior: Tumbler
- [x] Verify behavior: Cup
- [ ] fix: When keyboard navigation enabled, the Settings button appears with a focus ring

#### V1.1
- [ ] Experiment: predict cooldown time, battery life, charge time 
- [ ] VFZO M1 mug support

#### Features
- [ ] Experiment: eliminate Ember's low volume overheating
- [ ] Experiment: reduce Ember's' battery consumption during cooldown phase
- [ ] More non-Ember products
- [ ] visionOS: as central
- [ ] macOS/visionOS: "remote" central
- [ ] iPhone/iPad + Live Activity / Widget
- [ ] Improve onboarding

#### Minor/Fixes
- [ ] Scanner efficiency: Reduce eagerness to save a little laptop battery / turn on manually after initial session
- [ ] Forget a mug: cache forgotten IDs to prevent mugs in discovery mode from automatically reconnecting if scanning
- [ ] Multi-muggers: select mug for MenuBar or allow multiple in MenuBar
- [ ] Expand mock and live test suite
