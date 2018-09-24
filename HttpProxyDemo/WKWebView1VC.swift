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
        let sel = Selector(("registerSchemeForCustomProtocol:"))
        let vc = WKWebView().value(forKey: "browsingContextController") as AnyObject
        let cls = type(of: vc) as AnyObject
        
        let _ = cls.perform(sel, with: "http")
        let _ = cls.perform(sel, with: "https")
        
        
        let host = ViewController.host
        let port = ViewController.port
        
        let url = URL(string: "http://ip111.cn/")
        let request = URLRequest(url: url!)
        
        HttpProxyProtocol.setProxy(host, port)
        HttpProxyProtocol.start()
        if (HttpProxyProtocol.canInit(with: request)){
            webView.load(request)
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        HttpProxyProtocol.stop()
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
