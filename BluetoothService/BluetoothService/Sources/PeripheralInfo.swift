//
//  PeripheralInfo.swift
//  BluetoothService
//
//  Created by nenhall on 2020/4/17.
//  Copyright © 2020 nenhall. All rights reserved.
//

import UIKit
import CoreBluetooth

struct Characteristic {
    var bytes = Array<Int>()
    var rawBytes = 0x00
    var properties = 0x00
    var uuidString = String()
}


struct PeripheralInfo {
    var peripheral: CBPeripheral?
    var identifier = String()
    var name = String()
    var state = CBPeripheralState.disconnected
    var advertisementData: [String : Int]?
    var RSSI: NSNumber = NSNumber.init(value: -99)
    var characteristic: Characteristic?
}


