//
//  BLEZdetailController.swift
//  BluetoothService
//
//  Created by nenhall on 2020/4/17.
//  Copyright © 2020 nenhall. All rights reserved.
//

import UIKit
import BluetoothService
import CoreBluetooth

class BLEDetailController: UIViewController {
    
    var central: Central?
    var characteristic: CBCharacteristic?
    
    var cmd = CMD()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    @IBAction func writeCommand(_ sender: Any) {
        cmd.setRBG
        if let cbCentral = central, let btCharacteristic = characteristic {
//            cbCentral.writeCommand(cmd: cmd.tempData, characteristic: btCharacteristic)
//            cbCentral.writeCommand(cmd: cmd.setTimeOut(0x02), characteristic: btCharacteristic)
//            cbCentral.writeCommand(cmd: cmd.setSlave, characteristic: btCharacteristic)
//            cbCentral.writeCommand(cmd: cmd.setLEDPattern, characteristic: btCharacteristic)
//            cbCentral.writeCommand(cmd: cmd.setLEDPatternColor, characteristic: btCharacteristic)
            cbCentral.writeCommand(cmd: cmd.setRBG, characteristic: btCharacteristic)
            cbCentral.writeCommand(cmd: cmd.returnBLE, characteristic: btCharacteristic)

            
        }
    }
    
    override func performSegue(withIdentifier identifier: String, sender: Any?) {
        
    }
    
}
