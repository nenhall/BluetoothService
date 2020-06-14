//
//  BluetoothCentral.swift
//  BluetoothService
//
//  Created by nenhall on 2020/4/17.
//  Copyright © 2020 nenhall. All rights reserved.
//

import UIKit
import CoreBluetooth

@objc public protocol CentralDelegate {
    @objc optional func CentralDidDiscover(peripherals: [String : CBPeripheral])
    @objc optional func CentralDidConnect(peripheral: CBPeripheral)
    @objc optional func CentralDidDisconnect(peripheral: CBPeripheral)
    @objc optional func CentralDidDiscoverCharacteristics(peripheral: CBPeripheral, characteristics: [CBCharacteristic]?)
}

@objc public class Central: NSObject {
    @objc private let cenQueue = DispatchQueue.init(label: "com.bluetooth.central.queue")
    @objc public var delegate: CentralDelegate?
    @objc public var peripherals = [String : CBPeripheral]()
    @objc public var services = [String : CBService]()
    var cPeripheral: CBPeripheral?
    var cServie: CBService?
    @objc public var scanServicesID: [CBUUID]?
    @objc public var scanPeripheralsID: [CBUUID]?

    @objc public lazy var centralManager = { () -> CBCentralManager in
        //        CBCentralManagerOptionShowPowerAlertKey
        //        CBCharacteristicWriteWithResponse
        let centralManager =  CBCentralManager.init(delegate: self, queue: self.cenQueue, options: nil)
        return centralManager
    }()
    
    public override init() {
        super.init()
        
    }
    
    @objc public func beginScan(services: [CBUUID]?) {
        if self.centralManager.state == CBManagerState.poweredOn {
            if !self.centralManager.isScanning {
                self.centralManager.scanForPeripherals(withServices: scanServicesID, options: nil)
            }
        } else {

        }
    }
    
    @objc public func stopScan() {
        if self.centralManager.isScanning {
            self.centralManager.stopScan()
        }
    }
    
    @objc public func connectPeripheral(_ peripheral: CBPeripheral) {
        centralManager.connect(peripheral, options: nil)
    }
    
    
    @objc public func cancelPeripheralConnection() {
       stopScan()
        if let p = cPeripheral {
            centralManager.cancelPeripheralConnection(p)
        }
    }
    
    
    /// 写入指令到特征
    /// - Parameters:
    ///   - cmd: 指令：16进制数组组成 `Data`
    ///   - characteristic: 特征，传 nil 代表特征 `cPeripheral`
    @objc public func writeCommand(cmd: Data, characteristic: CBCharacteristic) {
        guard let cp = cPeripheral else {
            print("外设、特征都不能为空")
            return
        }
        cp.writeValue(cmd, for: characteristic, type: CBCharacteristicWriteType.withResponse)
    }
    
}


extension Central: CBCentralManagerDelegate {
    /*
     *  @param central  状态已更改的中央管理器.
     *
     *  @discussion     每当中央管理器的状态已更新时调用。 仅当状态为`CBCentralManagerStatePoweredOn`时才发出命令
     *   `CBCentralManagerStatePoweredOn`以下的状态表示扫描已停止并且所有连接的外围设备均已断开连接。
     *    如果状态移至`CBCentralManagerStatePoweredOff`，
     所有从此中心获取的`CBPeripheral`对象管理员无效，必须重新检索或发现它。
     *
     */
   public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("\ncentralManagerDidUpdateState")
        self.centralManager.scanForPeripherals(withServices: scanServicesID, options: nil)
    }
    
    
    /**
     *  @param central              The central manager providing this update.
     *  @param peripheral           外设对象 `CBPeripheral`
     *  @param advertisementData    包含任何广告和扫描响应数据的字典
     *  @param RSSI                 外围设备的当前 `RSSI`，以dBm为单位。
     *                              保留`127`的值，该值指示 `RSSI`
     *
     *  @discussion                 在 `central` 发现 `peripheral` 后，在扫描时调用此方法。
     *                              发现的外围设备必须保留以便使用；否则，将认为它没有意义，
     *                              并且将由中央管理器进行清理。对于`advertisementData`键的列表，
     *                              请参见`{CBAdvertisementDataLocalNameKey}`和其他类似的常量
     */
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
//        print("\ndidDiscover peripheral：",peripheral,"\nadvertisementData:\(advertisementData)")
        print(advertisementData["kCBAdvDataManufacturerData"] as Any)
        
        peripheral.delegate = self
//        centralManager.connect(peripheral, options: nil)
         // 已扫到的，添加对应的外设到字曲
        if !peripherals.keys.contains(peripheral.identifier.uuidString) {
            peripherals.updateValue(peripheral, forKey: peripheral.identifier.uuidString)
        }
        DispatchQueue.main.async {
            self.delegate?.CentralDidDiscover?(peripherals: self.peripherals)
        }

    }
    
    
    /**
     *  @param central      The central manager providing this information.
     *  @param peripheral   The <code>CBPeripheral</code> that has connected.
     *
     *  @discussion         当 `{@link connectPeripheral：options：}`启动的连接成功时，将调用此方法。
     *
     */
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("\ndidConnect peripheral:",peripheral)
        cPeripheral = peripheral
        peripheral.discoverServices(nil)
        DispatchQueue.main.async {
            self.delegate?.CentralDidConnect?(peripheral: peripheral)
        }
    }
    
    
    /**
     *  @param central      The central manager providing this information.
     *  @param peripheral   外设无法连接的 `CBPeripheral `.
     *  @param error        错误失败原因.
     *
     *  @discussion         当由 `{@link connectPeripheral：options：}`发起的连接未能完成时，将调用此方法。
     *                      由于连接尝试不
     *                      超时，连接失败是非典型的，通常表示暂时性问题。
     *
     */
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("\ndidFailToConnect peripheral:",error as Any)
    }
    
    
    /**
     *  @method centralManager:didDisconnectPeripheral:error:
     *
     *  @param central      The central manager providing this information.
     *  @param peripheral   外设已断开连接的 `CBPeripheral `
     *  @param error        错误如果发生错误，则为失败原因
     *
     *  @discussion         在通过{@link connectPeripheral：options：}连接的外围设备断开连接时调用此方法。
     *                      如果断开不是由{@link cancelPeripheralConnection}启动的，其原因将在 error参数中详细说明。
     *                      一旦这种方法被调用，将不会在`peripheral`的 `CBPeripheralDelegate `上调用更多方法
     *
     */
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("\n外设已断开连接的:",peripheral.name as Any,"\nerror:\(String(describing: error))")
        // 已断开连接的，移除字曲对应的外设
//        if peripherals.keys.contains(peripheral.identifier.uuidString) {
//            peripherals.removeValue(forKey: peripheral.identifier.uuidString)
//        }
        
        DispatchQueue.main.async {
            self.delegate?.CentralDidDisconnect?(peripheral: peripheral)
        }
        
    }
    
    /**
     *  @param central      The central manager providing this information.
     *  @param dict         包含有关 <i>central</i> 信息的字典，该信息在应用终止时由系统保留。
     *
     *  @discussion         对于选择加入状态保存和还原的应用程序，这是在您的应用程序重新启动到其中时调用的第一个方法
          *后台完成一些与蓝牙相关的任务。使用此方法可以将您的应用状态与
     *
     *  @seealso            CBCentralManagerRestoredStatePeripheralsKey;
     *  @seealso            CBCentralManagerRestoredStateScanServicesKey;
     *  @seealso            CBCentralManagerRestoredStateScanOptionsKey;
     *
     */
//    public func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
//        print("\nwillRestoreState",dict)
//    }
    
    /**
     *  @param central      提供此信息的中央管理器.
     *  @param event        事件发生的 `CBConnectionEvent.
     *  @param peripheral   外设导致事件的 `CBPeripheral `.
     *
     *  @discussion         在与`{@link registerForConnectionEventsWithOptions：}`
     *                      中提供的任何选项匹配的外围设备连接或断开连接时调用此方法。
     *
     */
    @available(iOS 13.0, *)
    public func centralManager(_ central: CBCentralManager, connectionEventDidOccur event: CBConnectionEvent, for peripheral: CBPeripheral) {
        print("\nconnectionEventDidOccur:",event)
    }
    
    
    /**
     *  @param central      提供此信息的中央管理器.
     *  @param peripheral   外设导致事件的 `CBPeripheral `.
     *
     *  @discussion         当使用 `{@link connectPeripheral：}` 选项 `{@link CBConnectPeripheralOptionRequiresANCS}` 连接的外围设备的授权状态更改时，将调用此方法
     *
     */
    @available(iOS 13.0, *)
    public func centralManager(_ central: CBCentralManager, didUpdateANCSAuthorizationFor peripheral: CBPeripheral) {
        print("\ndidUpdateANCSAuthorizationFor:",peripheral)
    }
    
    
}

extension Central: CBPeripheralDelegate {
    /**
     *  @param peripheral    The peripheral providing this update.
     *
     *  @discussion            This method is invoked when the @link name @/link of <i>peripheral</i> changes.
     */
   public func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
        print("peripheralDidUpdateName")

    }


    /**
     *  @param peripheral    The peripheral providing this information.
     *    @param error        If an error occurred, the cause of the failure.
     *
     *  @discussion            此方法返回@link discoverServices：@ / link调用的结果。
     *                       如果已成功读取服务，则可以通过以下方式进行检索<i>外围设备</ i>的@link服务@ / link属性。
     *
     */
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("didDiscoverServices:",peripheral.services as Any,error as Any)
        if let services = peripheral.services {
            for service in services {
                peripheral.discoverCharacteristics(scanPeripheralsID, for: service)
            }
        }
    }

    
    /**
     *  @param peripheral    The peripheral providing this information.
     *  @param service        服务包含特征的<code> CBService </ code>对象
     *    @param error        If an error occurred, the cause of the failure.
     *
     *  @discussion            此方法返回@link discoverCharacteristics：forService：@ / link调用的结果。
     *                  如果特征被成功读取，它们可以通过<i> service </ i>的<code> characteristics </ code>属性进行检索。
     */
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("读取到特征:",service.characteristics as Any)
        DispatchQueue.main.async {
            self.delegate?.CentralDidDiscoverCharacteristics?(peripheral: peripheral, characteristics: service.characteristics)
        }
        
        if let characteristics = service.characteristics {
            for cc in characteristics {
                 peripheral.discoverDescriptors(for: cc)
            }
        }
    }
    
    
    /**
     *  @param peripheral    The peripheral providing this information.
     *  @param service        对象包含所包含的服务。
     *    @param error        错误如果发生错误，则为失败原因
     *
     *  @discussion          发现包含的服务:此方法返回@link discoverIncludedServices：forService：@ / link调用的结果。
     *              如果成功读取了包含的服务，它们可以通过<i> service </ i>的<code> includedServices </ code>属性进行检索
     */
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: Error?) {
        print("发现包含的服务:",service.includedServices as Any)
    }

    
    /**
     *  @method peripheral:didUpdateValueForCharacteristic:error:
     *
     *  @param peripheral        The peripheral providing this information.
     *  @param characteristic    特征:一个<code> CBCharacteristic </ code>对象
     *    @param error            If an error occurred, the cause of the failure.
     *
     *  @discussion              在@link readValueForCharacteristic：@ / link调用之后或在收到通知/指示后调用此方法。
     */
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("特征已更新值:",characteristic)
    }

    
    /**
     *  @method peripheral:didWriteValueForCharacteristic:error:
     *
     *  @param peripheral        The peripheral providing this information.
     *  @param characteristic    特征:一个<code> CBCharacteristic </ code>对象
     *    @param error            If an error occurred, the cause of the failure.
     *
     *  @discussion              当使用<code> CBCharacteristicWriteWithResponse </ code>类型时，
     *                      此方法返回{@link writeValue：forCharacteristic：type：}调用的结果。
     */
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("写入值到特征:",characteristic)
    }

    
    /**
     *  @method peripheral:didUpdateNotificationStateForCharacteristic:error:
     *
     *  @param peripheral        The peripheral providing this information.
     *  @param characteristic    特征:一个<code> CBCharacteristic </ code>对象
     *    @param error            错误如果发生错误，则为失败原因
     *
     *  @discussion           更新了通知状态:此方法返回@link setNotifyValue：forCharacteristic：@ / link调用的结果。
     */
    public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("更新了通知状态:",characteristic)
    }

    
    /**
     *  @param peripheral        The peripheral providing this information.
     *  @param characteristic    A <code>CBCharacteristic</code> object.
     *    @param error            If an error occurred, the cause of the failure.
     *
     *  @discussion            发现描述符: 此方法返回@link discoverDescriptorsForCharacteristic：@ / link调用的结果。 如果描述符已成功读取，
     *                          它们可以通过<i>特征</ i>的<code> descriptors </ code>属性进行检索。
     */
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        print("发现描述符:",characteristic.descriptors as Any)
//        if let descriptors = characteristic.descriptors {
//            for _ in descriptors {
//
//            }
//        }
    }

    
    /**
     *  @param peripheral        The peripheral providing this information.
     *  @param descriptor        A <code>CBDescriptor</code> object.
     *    @param error            If an error occurred, the cause of the failure.
     *
     *  @discussion             此方法返回@link readValueForDescriptor：@ / link调用的结果。
     */
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        print("更新描述符的值：",descriptor)
    }

    
    /**
     *  @param peripheral        The peripheral providing this information.
     *  @param descriptor        A <code>CBDescriptor</code> object.
     *    @param error            If an error occurred, the cause of the failure.
     *
     *  @discussion              此方法返回@link writeValue：forDescriptor：@ / link调用的结果。
     */
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        print("写入描述符的值：",descriptor)
    }

    
    /**
     *  @param peripheral   The peripheral providing this update.
     *
     *  @discussion         再次<i> peripheral </ i>再次调用@link writeValue：forCharacteristic：type：@ / link失败后，
     *                  将调用此方法,准备发送特征值更新。
     *
     */
    public func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
        print("外围设备就绪,发送写而不响应操作", peripheral)
    }

    
    /**
     *  @param peripheral            提供此更新的外设
     *  @param invalidatedServices   已失效的服务
     *
     *  @discussion            更改<i>外围设备</ i>的@link服务@ / link时，将调用此方法。
     *                         至此，指定的<code> CBService </ code>对象已失效。
     *                         可以通过@link discoverServices：@ / link重新发现服务
     */
    public func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        print("didModifyServices 已失效的服务:",invalidatedServices)
    }
    
    
     /**
      *  @param peripheral    The peripheral providing this update.
      *    @param error        错误如果发生错误，则为失败原因
      *
      *  @discussion            此方法返回@link readRSSI：@ / link调用的结果
      *
      *  @deprecated            建议使用{@link外设：didReadRSSI：错误：}
      */
     public func peripheralDidUpdateRSSI(_ peripheral: CBPeripheral, error: Error?) {
         print("peripheralDidUpdateRSSI")
     }

     
     /**
      *  @param peripheral    The peripheral providing this update.
      *  @param RSSI           RSSI链接的当前RSSI.
      *  @param error        错误如果发生错误，则为失败原因.
      *
      *  @discussion          此方法返回@link readRSSI：@ / link调用的结果
      */
    public func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
         print("didReadRSSI")
     }
    
    
    /**
     *  @method peripheral:didOpenL2CAPChannel:error:
     *
     *  @param peripheral        The peripheral providing this information.
     *  @param channel            A <code>CBL2CAPChannel</code> object.
     *    @param error            If an error occurred, the cause of the failure.
     *
     *  @discussion                This method returns the result of a @link openL2CAPChannel: @link call.
     */
    @available(iOS 11.0, *)
    public func peripheral(_ peripheral: CBPeripheral, didOpen channel: CBL2CAPChannel?, error: Error?) {
        print("did Open channel")
    }
}
