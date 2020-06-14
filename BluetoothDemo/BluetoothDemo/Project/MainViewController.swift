//
//  ViewController.swift
//  BluetoothService
//
//  Created by nenhall on 2020/4/16.
//  Copyright © 2020 nenhall. All rights reserved.
//

import UIKit


class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *) {
            if previousTraitCollection?.userInterfaceStyle ==  UIUserInterfaceStyle.light{
                self.view.backgroundColor = UIColor.darkGray
            } else {
                self.view.backgroundColor = UIColor.white
            }
        }
    }
    
}

