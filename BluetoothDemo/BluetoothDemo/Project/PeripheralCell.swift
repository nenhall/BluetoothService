//
//  PeripheralCell.swift
//  BluetoothService
//
//  Created by nenhall on 2020/4/17.
//  Copyright © 2020 nenhall. All rights reserved.
//

import UIKit
import IBAnimatable
import CoreBluetooth

class PeripheralCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var serviceLabel: UILabel!
    @IBOutlet weak var characteristicLavel: UILabel!
    @IBOutlet weak var connectButton: UIButton!
    var didClickConnectEvent: ((Bool) -> (Void))?

    var peripheral: CBPeripheral?

    override func awakeFromNib() {
        super.awakeFromNib()

   
    }
    
    
    @IBAction func clickConnectEvent(_ sender: AnimatableButton) {
        didClickConnectEvent?(sender.isSelected)
    }
    
    func updateModels(_ peripheral:  CBPeripheral) {
        self.peripheral = peripheral
        nameLabel.text = peripheral.name
        serviceLabel.text = "\(String(describing: peripheral.services?.count))"
        characteristicLavel.text = "\(String(describing: peripheral.services?.count))"
        connectButton.isSelected = peripheral.state == CBPeripheralState.connected
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
    
}
