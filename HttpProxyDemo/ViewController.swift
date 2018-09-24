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
    
    @IBOutlet weak var hostTextField: UITextField!
    @IBOutlet weak var portTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        type(of: self).host = hostTextField.text ?? ""
        type(of: self).port = Int(portTextField.text ?? "") ?? 0
    }


}

