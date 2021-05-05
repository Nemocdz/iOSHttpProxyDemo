//
//  UIWebView-VC.swift
//  HttpProxyDemo
//
//  Created by Nemo on 2018/9/24.
//  Copyright © 2018年 Nemo. All rights reserved.
//

import UIKit

class UIWebViewVC: UIViewController {
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let host = ViewController.host
        let port = ViewController.port
        let url = URL(string: "http://ip111.cn/")
        let request = URLRequest(url: url!)
        HttpProxyProtocol.start(proxyConfig: (host, port))
        if (HttpProxyProtocol.canInit(with: request)){
            webView.loadRequest(request)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        HttpProxyProtocol.stop()
    }
}
