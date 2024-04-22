import Common

package extension BluetoothMugModel.VFZOModel {
  func build(_ peripheral: CBPeripheral) -> BluetoothMug & BluetoothPeripheral {
    VFZOMug(peripheral, self)
  }
}
