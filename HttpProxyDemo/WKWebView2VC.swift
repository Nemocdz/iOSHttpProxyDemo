//
//  WKWebview2+VC.swift
//  HttpProxyDemo
//
//  Created by Nemo on 2018/9/24.
//  Copyright © 2018年 Nemo. All rights reserved.
//

import UIKit
import WebKit

class WKWebView2VC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let host = ViewController.host
        let port = ViewController.port
        let url = URL(string: "http://ip111.cn/")
        let request = URLRequest(url: url!)
        let config = WKWebViewConfiguration()
        config.addProxyConfig((host, port))
        let webView = WKWebView(frame: view.frame, configuration: config)
        view.addSubview(webView)
        webView.load(request)
    }
}
