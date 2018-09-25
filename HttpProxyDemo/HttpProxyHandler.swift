//
//  HttpProxyHandler.swift
//  Test
//
//  Created by Nemo on 2018/9/21.
//  Copyright © 2018年 tencent. All rights reserved.
//

import UIKit
import WebKit

class HttpProxyHandler: NSObject {
    static var host = ""
    static var port = 0
    
    required override init() {
        
    }
    
    private var dataTask:URLSessionDataTask?
    
    class func proxyConifg(_ host:String, _ port:Int) -> WKWebViewConfiguration{
        self.host = host
        self.port = port
        
        let config = WKWebViewConfiguration()
        let handler = self.init()
        config.setURLSchemeHandler(handler, forURLScheme: "dummy")
        let handlers = config.value(forKey: "_urlSchemeHandlers") as! NSMutableDictionary
        handlers["http"] = self.init()
        handlers["https"] = self.init()
        return config
    }
}

extension HttpProxyHandler: WKURLSchemeHandler{
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        ProxySessionManager.shared.host = type(of: self).host
        ProxySessionManager.shared.port = type(of: self).port
        dataTask = ProxySessionManager.shared.dataTask(with: urlSchemeTask.request, completionHandler: {[weak urlSchemeTask] (data, response, error) in
            guard let urlSchemeTask = urlSchemeTask else {
                return
            }
            
            if let error = error {
                urlSchemeTask.didFailWithError(error)
            } else {
                if let response = response {
                    urlSchemeTask.didReceive(response)
                }
                
                if let data = data {
                    urlSchemeTask.didReceive(data)
                }
                urlSchemeTask.didFinish()
            }
        })
        dataTask?.resume()
    }
    
    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        dataTask?.cancel()
    }
}

