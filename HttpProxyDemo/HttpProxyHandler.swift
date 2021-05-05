//
//  HttpProxyHandler.swift
//  Test
//
//  Created by Nemo on 2018/9/21.
//  Copyright © 2018年 Nemo. All rights reserved.
//

import Foundation
import WebKit
import ObjectiveC

final class HttpProxyHandler: NSObject {
    private var dataTask: URLSessionDataTask?
    private static var session: URLSession?
    
    init(proxyConfig: HttpProxyConfig) {
        Self.updateSession(of: proxyConfig)
    }

    private static func updateSession(of proxyConfig: HttpProxyConfig) {
        if let session = Self.session, session.configuration.hasProxyConfig(proxyConfig) {
            return
        }
        let config = URLSessionConfiguration.default
        config.addProxyConfig(proxyConfig)
        Self.session = URLSession(configuration: config)
    }
}

extension HttpProxyHandler: WKURLSchemeHandler {
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        dataTask = Self.session?.dataTask(with: urlSchemeTask.request) { [weak urlSchemeTask] data, response, error in
            guard let urlSchemeTask = urlSchemeTask else { return }
            if let error = error, error._code != NSURLErrorCancelled {
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

private var hookWKWebView: () = {
    guard let origin = class_getClassMethod(WKWebView.self, #selector(WKWebView.handlesURLScheme(_:))),
          let hook = class_getClassMethod(WKWebView.self, #selector(WKWebView._handlesURLScheme(_:))) else {
        return
    }
    method_exchangeImplementations(origin, hook)
}()

fileprivate extension WKWebView {
    @objc static func _handlesURLScheme(_ urlScheme: String) -> Bool {
        if httpSchemes.contains(urlScheme) {
            return false
        }
        return Self.handlesURLScheme(urlScheme)
    }
}

extension WKWebViewConfiguration {
    func addProxyConfig(_ config: HttpProxyConfig) {
        let handler = HttpProxyHandler(proxyConfig: config)
        _ = hookWKWebView
        httpSchemes.forEach {
            setURLSchemeHandler(handler, forURLScheme: $0)
        }
    }
}
