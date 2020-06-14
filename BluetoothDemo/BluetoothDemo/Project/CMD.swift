//
//  CMD.swift
//  BluetoothService
//
//  Created by nenhall on 2020/4/19.
//  Copyright © 2020 nenhall. All rights reserved.
//

import Foundation
import BluetoothService

public struct CMD {
    var R = 0xdc.hex
    var G = 0x14.hex
    var B = 0x3c.hex
    
    /**
     Byte0 Byte1 Byte2 Byte3 Byte4 Byte5 Byte6 Byte7 Byte8
     0x55  0x01  0x06  Add6  Add5  Add4  Add3  Add2  Add1
     */
    let verifyBase = Hex(0x55)>~Hex(0x01)>~Hex(0x06)
    let macAddress = Hex(0x44)>~Hex(0xbf)>~Hex(0xe3)>~Hex(0x17)>~Hex(0x08)>~Hex(0x57)
    let defaultTimeOut = Hex(0x62)>~Hex(0x55)>~Hex(0x01)>~Hex(0x06)>~Hex(0xbc)>~Hex(0x01)

    var verify: Data { get { (verifyBase.bytes>~macAddress.bytes).byte } }
    
    func setTimeOut(_ time: UInt8) -> Data {
        var bytes = defaultTimeOut.bytes
        bytes.removeLast()
        return (bytes>~Hex(time).bytes).byte
    }
    
    /**
     Byte0 Byte1   Byte2
     Hex(0x6C  Length  New Device Name,The maximum length is 18 bytes
     */
    var editName: Data {
        get {
            (Hex(0x6C)>~Hex(0x05)>~Hex(0x08)>~Hex(0x08)>~Hex(0x08)>~Hex(0x08)>~Hex(0x08)).byte
        }
    }
    
    /**
     Byte0 Byte1 Byte2 Byte3      Byte4      Byte5
     0x62  0x55  0x50  Default R  Default G  Default B
     */
    var setRBG: Data {
        get {
            (Hex(0x53)>~Hex(0x45)>~Hex(0x54)>~Hex(0xec)>~Hex(R)>~Hex(G)>~Hex(B)).byte
        }
    }
    
    /**
     Byte0 Byte1 Byte2 Byte3
     0x62  0x56  0x50  User Default Pattern
     */
    var setUserDefaultPattern: Data {
        get {
            (Hex(0x62)>~Hex(0x56)>~Hex(0x50)>~Hex(0x01)).byte
        }
    }
    
    /**
     Byte0 Byte1 Byte2 Byte3 Byte4 Byte5 Byte6 Byte7 Byte8 Byte9 Byte10
     0x62  0x55  0x02  Mode TimeOS Add6  Add5  Add4  Add3   Add2  Add1
     */
    var tempData: Data {
        get {
            (Hex(0x62)>~Hex(0x55)>~Hex(0x01)>~Hex(0x06)>~Hex(0xbc)>~Hex(0x02)>~Hex(0x01)>~Hex(0x77)>~Hex(0x77)>~Hex(0x77)>~Hex(0x7a)).byte
        }
    }
    
    
    /**
     Byte0 Byte1 Byte2 Byte3 Byte4 Byte5      Byte6   Byte7 Byte8 Byte9 Byte10
     0x62  0x55  0x01  Mode  0xbc  TimeOutSet Pattern  R     G     B    Pattern Time(s)
     */
    var setMaster: Data {
        get {
            (Hex(0x62)>~Hex(0x55)>~Hex(0x01)>~Hex(0x01)>~Hex(0xbc)>~Hex(0x05)>~Hex(0x01)>~Hex(R)>~Hex(G)>~Hex(B)>~Hex(0x05)).byte
        }
    }
    
    /**
     Byte0 Byte1 Byte2 Byte3 Byte4 Byte5 Byte6 Byte7 Byte8 Byte9 Byte10
     0x62  0x55  0x02  0x06 TimeOS Add6  Add5  Add4  Add3   Add2  Add1
     Mode: 0x01----Non-slient connection
     0x00----slient connection
     */
    var setSlave: Data {
        get {
            (Hex(0x62)>~Hex(0x55)>~Hex(0x02)>~Hex(0x06)>~Hex(0x02)>~Hex(0x44)>~Hex(0xbf)>~Hex(0xe3)>~Hex(0x17)>~Hex(0x08)>~Hex(0x57)).byte
        }
    }
    
    /**
     Byte0 Byte1 Byte2 Byte3   Byte4 Byte5 Byte6  Byte7
     0x62  0x55  0x40  Pattern R     G     B      Pattern Time(s)
     */
    var setLEDPattern: Data {
        get {
            (Hex(0x62)>~Hex(0x55)>~Hex(0x10)>~Hex(0xc7)).byte
        }
    }
    
    /**
     Byte0 Byte1 Byte2 Byte3   Byte4 Byte5 Byte6  Byte7
     0x62  0x55  0x40  Pattern R     G     B      Pattern Time(s)
     */
    var setLEDPatternColor: Data {
        get {
            (Hex(0x62)>~Hex(0x55)>~Hex(0x40)>~Hex(0x10)>~Hex(0xdc)>~Hex(0x14)>~Hex(0x3c)).byte
        }
    }
    
    var power: Data {
        get {
            (Hex(0x5d)>~Hex(0x08)>~Hex(0x01)>~Hex(0x3b)).byte
        }
    }
    
    let returnBLE = (Hex(0x62)>~Hex(0x55)>~Hex(0x20)>~Hex(0xd7)).byte
    
}
