//
//  ViewController.swift
//  HttpProxyDemo
//
//  Created by Nemo on 2018/9/23.
//  Copyright © 2018年 Nemo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    static var host = ""
    static var port = 0
    
    @IBAction func changeHsot(_ sender: UITextField) {
        type(of: self).host = hostTextField.text ?? ""
    }
    @IBAction func changePort(_ sender: UITextField) {
        type(of: self).port = Int(portTextField.text ?? "") ?? 0
    }
    @IBOutlet weak var hostTextField: UITextField!
    @IBOutlet weak var portTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        type(of: self).host = hostTextField.text ?? ""
        type(of: self).port = Int(portTextField.text ?? "") ?? 0
    }
    
   


}

