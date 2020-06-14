//
//  BLECentralController.swift
//  BluetoothService
//
//  Created by nenhall on 2020/4/16.
//  Copyright © 2020 nenhall. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth
import IBAnimatable
import BluetoothService


class BLECentralController: AnimatableViewController {

    @IBOutlet weak var peripheralListView: UITableView!
    
    var peripheralData = [Any]()
    let btCentral = Central.init()
    var peripherals = [String : CBPeripheral]()
    var characteristicF1: CBCharacteristic?
    var characteristicF2: CBCharacteristic?
    var cDescriptor: CBDescriptor?
    let serviceUUID = CBUUID.init(string: "FFF0")
    let cReadUUID = CBUUID.init(string: "FFF1")
    let cWriteUUID = CBUUID.init(string: "FFF2")
    var cmd = CMD()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        settingListView()
        
        btCentral.beginScan(services: [serviceUUID])
        btCentral.delegate = self
        cmd.verify
        
        
        var result = "0x436f6d6d616e64204572726f72210d0a"
        print("hexToString:",result.toHexString())
        

        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        btCentral.cancelPeripheralConnection()
    }
    
    func settingListView() {
        peripheralListView.register(UINib(nibName: "PeripheralCell", bundle: nil), forCellReuseIdentifier: "PeripheralCell")
        peripheralListView.estimatedRowHeight = 100
        peripheralListView.tableFooterView = UIView()
    }
    
    @IBAction func beginOrStopScanEvent(_ sender: AnimatableButton) {
        
        
    }
    
    
    @IBAction func disconnectEvent(_ sender: AnimatableButton) {
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(segue.identifier as Any)
        let navController = segue.destination as! UINavigationController
        let detailVC = navController.topViewController as! BLEDetailController
        detailVC.central = btCentral
        detailVC.characteristic = characteristicF2
    }
    
    func showBLEDetailControl(model: AnyObject) {
        self.performSegue(withIdentifier: "showBLEDetailControl", sender: nil)
    }
    
    @IBAction func leftEvent(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func rightEvent(_ sender: Any) {
        btCentral.beginScan(services: nil)

    }
    
}

extension BLECentralController: CentralDelegate {
    func CentralDidDiscover(peripherals: [String : CBPeripheral]) {
        self.peripherals = peripherals
        peripheralListView.reloadData()
    }
    
    func CentralDidConnect(peripheral: CBPeripheral) {
        self.peripherals.updateValue(peripheral, forKey: peripheral.identifier.uuidString)
        peripheralListView.reloadData()
    }
    
    func CentralDidDisconnect(peripheral: CBPeripheral) {
        self.peripherals.updateValue(peripheral, forKey: peripheral.identifier.uuidString)
        peripheralListView.reloadData()
    }
    
    func CentralDidDiscoverCharacteristics(peripheral: CBPeripheral, characteristics: [CBCharacteristic]?) {
        guard let name = peripheral.name else { return }
        if name.contains("BUD RL Glass") {
            if let tempChs = characteristics {
                for characteristic in tempChs {
                    if characteristic.uuid.uuidString == cReadUUID.uuidString {
                        characteristicF1 = characteristic
                        peripheral.setNotifyValue(true, for: characteristic)
                    }
                    if characteristic.uuid.uuidString == cWriteUUID.uuidString {
                        characteristicF2 = characteristic
                        peripheral.writeValue(cmd.verify, for: characteristicF2!, type: CBCharacteristicWriteType.withResponse)
                    }
                }
            }
        }
        
        self.peripherals.updateValue(peripheral, forKey: peripheral.identifier.uuidString)
          peripheralListView.reloadData()
    }
}

extension BLECentralController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let pCell = tableView.dequeueReusableCell(withIdentifier: "PeripheralCell")
        
        if let _pCell = pCell as? PeripheralCell {
            let model = [CBPeripheral](peripherals.values)
            if model.count > indexPath.row {
                let peripheral = model[indexPath.row]
                _pCell.updateModels(peripheral)
                _pCell.didClickConnectEvent = { [weak self] isSelected in
                    self?.btCentral.stopScan()
                    self?.btCentral.connectPeripheral(peripheral)
                }
            }
        }
        
        return pCell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        peripherals.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.showBLEDetailControl(model: tableView)
    }
    
}
