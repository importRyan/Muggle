/*
 * Copyright (c) 2020, Nordic Semiconductor
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice, this
 *    list of conditions and the following disclaimer in the documentation and/or
 *    other materials provided with the distribution.
 *
 * 3. Neither the name of the copyright holder nor the names of its contributors may
 *    be used to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

@_exported import CoreBluetoothMock

package typealias CBPeer                          = CBMPeer
package typealias CBAttribute                     = CBMAttribute
package typealias CBCentralManagerFactory         = CBMCentralManagerFactory
package typealias CBUUID                          = CBMUUID
package typealias CBError                         = CBMError
package typealias CBATTError                      = CBMATTError
package typealias CBManagerState                  = CBMManagerState
package typealias CBPeripheralState               = CBMPeripheralState
package typealias CBCentralManager                = CBMCentralManager
package typealias CBCentralManagerDelegate        = CBMCentralManagerDelegate
package typealias CBPeripheral                    = CBMPeripheral
package typealias CBPeripheralDelegate            = CBMPeripheralDelegate
package typealias CBService                       = CBMService
package typealias CBCharacteristic                = CBMCharacteristic
package typealias CBCharacteristicWriteType       = CBMCharacteristicWriteType
package typealias CBCharacteristicProperties      = CBMCharacteristicProperties
package typealias CBDescriptor                    = CBMDescriptor
package typealias CBConnectionEvent               = CBMConnectionEvent
package typealias CBConnectionEventMatchingOption = CBMConnectionEventMatchingOption

package let CBCentralManagerScanOptionAllowDuplicatesKey       = CBMCentralManagerScanOptionAllowDuplicatesKey
package let CBCentralManagerOptionShowPowerAlertKey            = CBMCentralManagerOptionShowPowerAlertKey
package let CBCentralManagerOptionRestoreIdentifierKey         = CBMCentralManagerOptionRestoreIdentifierKey
package let CBCentralManagerScanOptionSolicitedServiceUUIDsKey = CBMCentralManagerScanOptionSolicitedServiceUUIDsKey
package let CBConnectPeripheralOptionStartDelayKey             = CBMConnectPeripheralOptionStartDelayKey

package let CBCentralManagerRestoredStatePeripheralsKey        = CBMCentralManagerRestoredStatePeripheralsKey
package let CBCentralManagerRestoredStateScanServicesKey       = CBMCentralManagerRestoredStateScanServicesKey
package let CBCentralManagerRestoredStateScanOptionsKey        = CBMCentralManagerRestoredStateScanOptionsKey

package let CBAdvertisementDataLocalNameKey                    = CBMAdvertisementDataLocalNameKey
package let CBAdvertisementDataServiceUUIDsKey                 = CBMAdvertisementDataServiceUUIDsKey
package let CBAdvertisementDataIsConnectable                   = CBMAdvertisementDataIsConnectable
package let CBAdvertisementDataTxPowerLevelKey                 = CBMAdvertisementDataTxPowerLevelKey
package let CBAdvertisementDataServiceDataKey                  = CBMAdvertisementDataServiceDataKey
package let CBAdvertisementDataManufacturerDataKey             = CBMAdvertisementDataManufacturerDataKey
package let CBAdvertisementDataOverflowServiceUUIDsKey         = CBMAdvertisementDataOverflowServiceUUIDsKey
package let CBAdvertisementDataSolicitedServiceUUIDsKey        = CBMAdvertisementDataSolicitedServiceUUIDsKey

package let CBConnectPeripheralOptionNotifyOnConnectionKey     = CBMConnectPeripheralOptionNotifyOnConnectionKey
package let CBConnectPeripheralOptionNotifyOnDisconnectionKey  = CBMConnectPeripheralOptionNotifyOnDisconnectionKey
package let CBConnectPeripheralOptionNotifyOnNotificationKey   = CBMConnectPeripheralOptionNotifyOnNotificationKey
