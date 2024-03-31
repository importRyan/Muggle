#  Muggle

Muggle is an open source, privacy-friendly alternative to apps by Bluetooth smart mug manufacturers. 

Currently this macOS menu bar app supports the Ember Mug 2. Other Ember products may work — but you should confirm what the maximum temperature Ember's own app allows for your mug (this app limits the heat command to 63 celsius). You can use Ember's app at the same time as Muggle.

Given the macOS menu bar application, this repo is simple:
- `MuggleMac` holds the UI (SwiftUI MenuBarExtra) against a generic `BluetoothMug`
- `MuggleBluetooth` holds the CBCentralManager (currently detects only Ember products)
- `EmberBluetooth` holds the read/write CBPeripheral methods and Nordic mocks for Ember products
- `Common` holds general utilities and the `BluetoothMug` and other Nordic mocking related contracts

## To-dos
V1.0
- [ ] Nordic integration tests
- [ ] App icon inset
- [ ] Sort eager first responder highlighting (is this keyboard navigation?)
- [ ] Add boot on login to footer during onboarding
- [ ] Test Flight (privacy, XCC, solicit tests for non Mug 2 devices)

V1.1
- [ ] Vision Pro (as central)

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
