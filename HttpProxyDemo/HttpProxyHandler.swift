//
//  HttpProxyHandler.swift
//  Test
//
//  Created by Nemo on 2018/9/21.
//  Copyright © 2018年 Nemo. All rights reserved.
//

import UIKit
import WebKit

class HttpProxyHandler: NSObject {
    static var host: String?
    static var port: Int?
    private var dataTask:URLSessionDataTask?
}

extension HttpProxyHandler: WKURLSchemeHandler{
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        HttpProxySessionManager.shared.host = type(of: self).host
        HttpProxySessionManager.shared.port = type(of: self).port
        dataTask = HttpProxySessionManager.shared.dataTask(with: urlSchemeTask.request, completionHandler: {[weak urlSchemeTask] (data, response, error) in
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

extension WKWebViewConfiguration{
    static var proxyConifg:WKWebViewConfiguration{
        let config = WKWebViewConfiguration()
        let handler = HttpProxyHandler()
        config.setURLSchemeHandler(handler, forURLScheme: "http")
        config.setURLSchemeHandler(handler, forURLScheme: "https")
        return config
    }
}
