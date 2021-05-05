//
//  WkWebView1-VC.swift
//  HttpProxyDemo
//
//  Created by Nemo on 2018/9/24.
//  Copyright © 2018年 Nemo. All rights reserved.
//

import UIKit
import WebKit

class WKWebView1VC: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let host = ViewController.host
        let port = ViewController.port
        let url = URL(string: "http://ip111.cn/")
        let request = URLRequest(url: url!)
        HttpProxyProtocol.webKitSupport = true
        HttpProxyProtocol.start(proxyConfig: (host, port))
        if (HttpProxyProtocol.canInit(with: request)){
            webView.load(request)
        }
    }
    
    deinit {
        HttpProxyProtocol.webKitSupport = false
        HttpProxyProtocol.stop()
    }
}
