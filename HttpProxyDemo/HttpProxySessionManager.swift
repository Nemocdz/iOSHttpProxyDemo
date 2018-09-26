//
//  ProxyURLSession.swift
//  HttpProxyDemo
//
//  Created by Nemo on 2018/9/25.
//  Copyright © 2018年 Nemo. All rights reserved.
//

import UIKit

class HttpProxySessionManager: NSObject {
    var host = ""
    var port = 0
    
    static let shared = HttpProxySessionManager()
    private override init() {}
    
    private var currentSession: URLSession?
    private var sessionDelegate: HttpProxySessionDelegate?
    
    func dataTask(with request: URLRequest, delegate: URLSessionDelegate) -> URLSessionDataTask {
        if let currentSession = currentSession, currentSession.isProxyConfig(host, port){
            
        } else {
            let config = URLSessionConfiguration.proxyConfig(host, port)
            sessionDelegate = HttpProxySessionDelegate()
            currentSession = URLSession(configuration: config, delegate: self.sessionDelegate, delegateQueue: nil)
        }
        
        let dataTask = currentSession!.dataTask(with: request)
        sessionDelegate?[dataTask] = delegate
        return dataTask
    }
    
    
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask{
        if let currentSession = currentSession, currentSession.isProxyConfig(host, port){
            
        } else {
            let config = URLSessionConfiguration.proxyConfig(host, port)
            currentSession = URLSession(configuration: config)
        }
        
        let dataTask = currentSession!.dataTask(with: request, completionHandler: completionHandler)
        return dataTask
    }
}

fileprivate let httpProxyKey = kCFNetworkProxiesHTTPEnable as String
fileprivate let httpHostKey = kCFNetworkProxiesHTTPProxy as String
fileprivate let httpPortKey = kCFNetworkProxiesHTTPPort as String
fileprivate let httpsProxyKey = "HTTPSEnable"
fileprivate let httpsHostKey = "HTTPSProxy"
fileprivate let httpsPortKey = "HTTPSPort"

extension URLSessionConfiguration{
    class func proxyConfig(_ host: String, _ port: Int) -> URLSessionConfiguration{
        let config = URLSessionConfiguration.ephemeral
        if !host.isEmpty, port != 0{
            let proxyDict:[String:Any] = [httpProxyKey: true,
                                          httpHostKey: host,
                                          httpPortKey: port,
                                          httpsProxyKey: true,
                                          httpsHostKey: host,
                                          httpsPortKey: port]
            config.connectionProxyDictionary = proxyDict
        }
        return config
    }
}

extension URLSession{
    func isProxyConfig(_ aHost: String, _ aPort: Int) -> Bool{
        guard let proxyDic = self.configuration.connectionProxyDictionary else {
            return false
        }
        guard let host = proxyDic[httpHostKey] as? String, let port = proxyDic[httpPortKey] as? Int else{
            if aHost.isEmpty, aPort == 0{
                return true
            } else{
                return false
            }
        }
        
        guard host == aHost, port == aPort else {
            return false
        }
        
        return true
    }
}


fileprivate class HttpProxySessionDelegate: NSObject {
    private let lock = NSLock()
    private var taskDelegates = [Int: URLSessionDelegate]()
    subscript(task: URLSessionTask) -> URLSessionDelegate? {
        get {
            lock.lock()
            defer {
                lock.unlock()
            }
            return taskDelegates[task.taskIdentifier]
        }
        set {
            lock.lock()
            defer {
                lock.unlock()
            }
            taskDelegates[task.taskIdentifier] = newValue
        }
    }
}

extension HttpProxySessionDelegate: URLSessionDataDelegate{
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask,
                    didReceive response: URLResponse,
                    completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        if let delegate = self[dataTask] as? URLSessionDataDelegate{
            delegate.urlSession!(session, dataTask: dataTask, didReceive: response, completionHandler: completionHandler)
        } else {
            completionHandler(.cancel)
        }
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if let delegate = self[dataTask] as? URLSessionDataDelegate{
            delegate.urlSession!(session, dataTask: dataTask, didReceive: data)
        }
    }
}

extension HttpProxySessionDelegate: URLSessionTaskDelegate{
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let delegate = self[task] as? URLSessionTaskDelegate{
            delegate.urlSession!(session, task: task, didCompleteWithError: error)
        }
        self[task] = nil
    }
}

