//
//  URLProxyProtocol.swift
//  Test
//
//  Created by Nemo on 2018/9/20.
//  Copyright © 2018年 Nemo. All rights reserved.
//

import Foundation
import WebKit

final class HttpProxyProtocol: URLProtocol {
    private static var proxyConfig: HttpProxyConfig?
    private static var isRegistered = false
    private static let customKey = "HttpProxyProtocolKey"
    private static var session: HttpProxySession?
    private var dataTask: URLSessionDataTask?
    
    static func start(proxyConfig: HttpProxyConfig) {
        guard !isRegistered else { return }
        URLProtocol.registerClass(self)
        isRegistered = true
        self.proxyConfig = proxyConfig
    }
    
    static func stop() {
        guard isRegistered else { return }
        URLProtocol.unregisterClass(self)
        isRegistered = false
    }
    
    private static func updateSession(of proxyConfig: HttpProxyConfig) {
        if let session = Self.session, session.currentSession.configuration.hasProxyConfig(proxyConfig) {
            return
        }
        Self.session = HttpProxySession(proxyConfig: proxyConfig)
    }
}

extension HttpProxyProtocol {
    private static let contextControllerType: AnyObject = {
        let controller = WKWebView().value(forKey: "browsingContextController") as AnyObject
        return type(of: controller) as AnyObject
    }()
    
    static var webKitSupport: Bool = false {
        didSet {
            let selName = webKitSupport ? "registerSchemeForCustomProtocol:" : "unregisterSchemeForCustomProtocol:"
            httpSchemes.forEach {
                _ = contextControllerType.perform(Selector(selName), with: $0)
            }
        }
    }
}

extension HttpProxyProtocol {
    override class func canInit(with request: URLRequest) -> Bool {
        guard let scheme = request.url?.scheme?.lowercased(),
              httpSchemes.contains(scheme) else {
            return false
        }
        if property(forKey: customKey, in: request) != nil {
            return false
        }
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return (request as NSURLRequest).cdz_canonical()
    }
    
    override func startLoading() {
        if let request = request as? NSMutableURLRequest {
            Self.setProperty((), forKey: Self.customKey, in: request)
        }
        Self.updateSession(of: Self.proxyConfig!)
        dataTask = Self.session?.dataTask(with: request, delegate: self)
        dataTask?.resume()
    }
    
    override func stopLoading() {
        dataTask?.cancel()
        dataTask = nil
    }
}

extension HttpProxyProtocol: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask,
                    didReceive response: URLResponse,
                    completionHandler: (URLSession.ResponseDisposition) -> Void)
    {
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        client?.urlProtocol(self, didLoad: data)
    }
}

extension HttpProxyProtocol: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        if let request = request as? NSMutableURLRequest {
            Self.removeProperty(forKey: Self.customKey, in: request)
        }
        client?.urlProtocol(self, wasRedirectedTo: request, redirectResponse: response)
        dataTask?.cancel()
        let error = NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil)
        client?.urlProtocol(self, didFailWithError: error)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error, error._code != NSURLErrorCancelled {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            client?.urlProtocolDidFinishLoading(self)
        }
    }
}



