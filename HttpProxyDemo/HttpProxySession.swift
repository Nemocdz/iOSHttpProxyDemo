//
//  ProxyURLSession.swift
//  HttpProxyDemo
//
//  Created by Nemo on 2018/9/25.
//  Copyright © 2018年 Nemo. All rights reserved.
//

import Foundation

final class HttpProxySession {
    private let sessionDelegate = Delegate()
    let currentSession: URLSession
    
    init(proxyConfig: HttpProxyConfig) {
        let config = URLSessionConfiguration.default
        config.addProxyConfig(proxyConfig)
        currentSession = URLSession(configuration: config, delegate: sessionDelegate, delegateQueue: nil)
    }
    
    deinit {
        currentSession.invalidateAndCancel()
    }
    
    func dataTask(with request: URLRequest, delegate: URLSessionDelegate) -> URLSessionDataTask {
        let dataTask = currentSession.dataTask(with: request)
        sessionDelegate[dataTask] = delegate
        return dataTask
    }
}

extension HttpProxySession {
    final class Delegate: NSObject {
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
}

extension HttpProxySession.Delegate: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask,
                    didReceive response: URLResponse,
                    completionHandler: @escaping (URLSession.ResponseDisposition) -> Void)
    {
        if let delegate = self[dataTask] as? URLSessionDataDelegate {
            delegate.urlSession!(session, dataTask: dataTask, didReceive: response, completionHandler: completionHandler)
        } else {
            completionHandler(.cancel)
        }
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if let delegate = self[dataTask] as? URLSessionDataDelegate {
            delegate.urlSession!(session, dataTask: dataTask, didReceive: data)
        }
    }
}

extension HttpProxySession.Delegate: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        if let delegate = self[task] as? URLSessionTaskDelegate {
            delegate.urlSession?(session, task: task, willPerformHTTPRedirection: response, newRequest: request, completionHandler: completionHandler)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let delegate = self[task] as? URLSessionTaskDelegate {
            delegate.urlSession!(session, task: task, didCompleteWithError: error)
        }
        self[task] = nil
    }
}
