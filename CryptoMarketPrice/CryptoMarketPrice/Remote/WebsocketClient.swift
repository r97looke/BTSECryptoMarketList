//
//  WebsocketClient.swift
//  CryptoMarketPrice
//
//  Created by Shun Lung Chen on 2023/8/16.
//

import Foundation

public protocol WebsocketClientDelegate: AnyObject {
    func websocketDidClose()
    func websocketDidOpen()
    func websocketSendError()
    func websocketSendSuccess()
    func websocketReceiveError()
    func websocketReceive(data: Data)
}

public protocol WebsocketClient {
    var delegate: WebsocketClientDelegate? { set get }
    
    func connect(url: URL)
    
    func disconnect()
    
    func send(data: Data)
    
    func receive()
}
