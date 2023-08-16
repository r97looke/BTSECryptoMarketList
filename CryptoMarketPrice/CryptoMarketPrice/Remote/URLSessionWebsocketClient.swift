//
//  URLSessionWebsocketClient.swift
//  CryptoMarketPrice
//
//  Created by Shun Lung Chen on 2023/8/16.
//

import Foundation

public final class URLSessionWebsocketClient: NSObject, WebsocketClient {
    
    private let TAG = "TODO"
    
    private let session: URLSession
    private var task: URLSessionWebSocketTask?
    
    public init(session: URLSession) {
        self.session = session
    }
    
    public weak var delegate: WebsocketClientDelegate?
    
    public func connect(url: URL) {
        NSLog("\(self.TAG): connect")
        task = session.webSocketTask(with: url)
        task?.delegate = self
        task?.resume()
    }
    
    public func disconnect() {
        NSLog("\(self.TAG): disconnect")
        task?.cancel()
        task = nil
    }
    
    public func send(data: Data) {
        task?.send(.data(data)) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                NSLog("\(self.TAG): send error \(error)")
                self.delegate?.websocketSendError()
            }
            else {
                NSLog("\(self.TAG): send success")
                self.delegate?.websocketSendSuccess()
            }
        }
    }
    
    public func send(string: String) {
        task?.send(.string(string)) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                NSLog("\(self.TAG): send error \(error)")
                self.delegate?.websocketSendError()
            }
            else {
                NSLog("\(self.TAG): send success")
                self.delegate?.websocketSendSuccess()
            }
        }
    }
    
    public func receive() {
        NSLog("\(self.TAG): receive")
        task?.receive(completionHandler: { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(.data(receivedData)):
                NSLog("\(self.TAG): receivedData.count = \(receivedData.count)")
                self.delegate?.websocketReceive(data: receivedData)
                
            case let .success(.string(receivedString)):
                NSLog("\(self.TAG): receivedString = \(receivedString)")
                self.delegate?.websocketReceive(string: receivedString)
                break
                
            case let .failure(receivedError):
                NSLog("\(self.TAG): receivedError = \(receivedError)")
                self.delegate?.websocketReceiveError()
                
            default:
                break
            }
            
            self.receive()
        })
    }
}

// MARK: URLSessionWebSocketDelegate
extension URLSessionWebsocketClient: URLSessionWebSocketDelegate {
    
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        NSLog("\(TAG): didOpenWithProtocol")
        self.delegate?.websocketDidOpen()
    }
    
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        NSLog("\(TAG): didCloseWith")
        self.delegate?.websocketDidOpen()
    }
}
