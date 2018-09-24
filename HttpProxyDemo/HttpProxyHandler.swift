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
    static let sessionConfig = URLSessionConfiguration.ephemeral
    
    required override init() {
        
    }
    
    private var dataTask:URLSessionDataTask?
    
    class func proxyConifg(_ host:String, _ port:Int) -> WKWebViewConfiguration{
        let httpProxyKey = kCFNetworkProxiesHTTPEnable as String
        let hostKey = kCFNetworkProxiesHTTPProxy as String
        let portKey = kCFNetworkProxiesHTTPPort as String
        let proxyDict:[String:Any] = [httpProxyKey: true, hostKey:host, portKey: port]
        sessionConfig.connectionProxyDictionary = proxyDict
        
        let config = WKWebViewConfiguration()
        let handler = self.init()
        config.setURLSchemeHandler(handler, forURLScheme: "dummy")
        let handlers = config.value(forKey: "_urlSchemeHandlers") as! NSMutableDictionary
        //handlers?["http"] = self.init()
        handlers.setObject(handler, forKey: "http" as NSString)
        handlers.setObject(handler, forKey: "https" as NSString)
        //handlers?["https"] = self.init()
        return config
    }
    
}

extension HttpProxyHandler: WKURLSchemeHandler{
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        let proxySession = URLSession(configuration: type(of: self).sessionConfig)
        dataTask = proxySession.dataTask(with: urlSchemeTask.request) {[weak urlSchemeTask] (data, response, error) in
            guard let urlSchemeTask = urlSchemeTask else{
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
        }
        dataTask?.resume()
    }
    
    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        dataTask?.cancel()
    }
}

