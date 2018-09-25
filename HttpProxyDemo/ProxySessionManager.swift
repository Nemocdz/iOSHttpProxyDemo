//
//  ProxyURLSession.swift
//  HttpProxyDemo
//
//  Created by Nemo on 2018/9/25.
//  Copyright © 2018年 Nemo. All rights reserved.
//

import UIKit

class ProxySessionManager: NSObject {
    var host = ""
    var port = 0
    
    static let shared = ProxySessionManager()
    private override init() {
        
    }
    
    private var currentSession: URLSession?
    private var delegate: SessionDelegate?
    
    func dataTask(with request: URLRequest, delegate: URLSessionDelegate) -> URLSessionDataTask {
        if let currentSession = currentSession, currentSession.isProxyConfig(host, port){
            
        } else {
            let config = type(of: self).proxyConfig(host, port)
            self.delegate = SessionDelegate()
            currentSession = URLSession(configuration: config, delegate: self.delegate, delegateQueue: nil)
        }
        
        let dataTask = currentSession!.dataTask(with: request)
        let proxyDataTask = ProxyDataTask(dataTask, delegate)
        self.delegate?[dataTask] = proxyDataTask

        return dataTask
    }
    
    
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask{
        if let currentSession = currentSession, currentSession.isProxyConfig(host, port){
            
        } else {
            let config = type(of: self).proxyConfig(host, port)
            currentSession = URLSession(configuration: config)
        }
        
        let dataTask = currentSession!.dataTask(with: request, completionHandler: completionHandler)
        return dataTask
    }
    
    
    class func proxyConfig(_ host: String, _ port: Int) -> URLSessionConfiguration{
        let config = URLSessionConfiguration.ephemeral
        if !host.isEmpty, port != 0{
            let httpProxyKey = kCFNetworkProxiesHTTPEnable as String
            let hostKey = kCFNetworkProxiesHTTPProxy as String
            let portKey = kCFNetworkProxiesHTTPPort as String
            let proxyDict:[String:Any] = [httpProxyKey: true,hostKey: host, portKey: port]
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
        let hostKey = kCFNetworkProxiesHTTPProxy as String
        let portKey = kCFNetworkProxiesHTTPPort as String
        guard let host = proxyDic[hostKey] as? String, let port = proxyDic[portKey] as? Int else{
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


class ProxyDataTask: NSObject {
    private(set) var delegate: URLSessionDelegate?
    private(set) var dataTask: URLSessionDataTask?
    
    init(_ dataTask: URLSessionDataTask,_ delegate: URLSessionDelegate) {
        self.dataTask = dataTask
        self.delegate = delegate
    }
}

class SessionDelegate: NSObject {
    
    private let lock = NSLock()
    
    var taskDic = [Int: ProxyDataTask]()
    
    /// Access the task delegate for the specified task in a thread-safe manner.
    open subscript(task: URLSessionTask) -> ProxyDataTask? {
        get {
            lock.lock() ; defer { lock.unlock() }
            return taskDic[task.taskIdentifier]
        }
        set {
            lock.lock() ; defer { lock.unlock() }
            taskDic[task.taskIdentifier] = newValue
        }
    }
}

extension SessionDelegate: URLSessionDataDelegate{
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask,
                    didReceive response: URLResponse,
                    completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        if let delegate = self[dataTask]?.delegate as? URLSessionDataDelegate{
            delegate.urlSession!(session, dataTask: dataTask, didReceive: response, completionHandler: completionHandler)
        } else {
            completionHandler(.cancel)
        }
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if let delegate = self[dataTask]?.delegate as? URLSessionDataDelegate{
            delegate.urlSession!(session, dataTask: dataTask, didReceive: data)
        }
    }
}

extension SessionDelegate: URLSessionTaskDelegate{
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let delegate = self[task]?.delegate as? URLSessionTaskDelegate{
            delegate.urlSession!(session, task: task, didCompleteWithError: error)
        }
    }
}

