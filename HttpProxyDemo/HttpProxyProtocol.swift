//
//  URLProxyProtocol.swift
//  Test
//
//  Created by Nemo on 2018/9/20.
//  Copyright © 2018年 tencent. All rights reserved.
//

import UIKit
//import CoreFoundation

class HttpProxyProtocol: URLProtocol{
    static var isRegistered = false
    static let customKey = "HttpProxyProtocolKey"
    static let sessionConfig = URLSessionConfiguration.ephemeral
    
    class func setProxy(_ host:String, _ port:Int){
        let httpProxyKey = kCFNetworkProxiesHTTPEnable as String
        let hostKey = kCFNetworkProxiesHTTPProxy as String
        let portKey = kCFNetworkProxiesHTTPPort as String
        let proxyDict:[String:Any] = [httpProxyKey: true,hostKey: host, portKey: port]
        sessionConfig.connectionProxyDictionary = proxyDict
    }
    
    class func start() {
        guard isRegistered == false else {
            return
        }
        URLProtocol.registerClass(self)
        isRegistered = true
    }
    
    class func stop(){
        guard isRegistered else {
            return
        }
        URLProtocol.unregisterClass(self)
        isRegistered = false
    }
    
    
    private var dataTask:URLSessionDataTask?
    
    // MARK: NSURLProtocol
    override class func canInit(with request: URLRequest) -> Bool {
        if (URLProtocol.property(forKey:customKey, in: request) == nil) {
            return true
        } else {
            return false
        }
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    
    override func startLoading() {
        let newRequest = request as! NSMutableURLRequest
        URLProtocol.setProperty(true, forKey: type(of: self).customKey, in: newRequest)
        let proxySession = URLSession(configuration: type(of: self).sessionConfig, delegate: self, delegateQueue: nil)
        dataTask = proxySession.dataTask(with: newRequest as URLRequest)
        dataTask?.resume()
    }
    
    override func stopLoading() {
        dataTask?.cancel()
    }
}

extension HttpProxyProtocol: URLSessionDataDelegate{
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask,
                    didReceive response: URLResponse,
                    completionHandler: (URLSession.ResponseDisposition) -> Void) {
        
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        client?.urlProtocol(self, didLoad: data as Data)
    }
}

extension HttpProxyProtocol: URLSessionTaskDelegate{
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error != nil && error!._code != NSURLErrorCancelled {
            client?.urlProtocol(self, didFailWithError: error!)
        } else {
            client?.urlProtocolDidFinishLoading(self)
        }
    }
}


