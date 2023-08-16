//
//  CryptoMarketPricesReceiver.swift
//  CryptoMarketPrice
//
//  Created by Shun Lung Chen on 2023/8/16.
//

import Foundation

public protocol CryptoMarketPricesReceiverDelegate: AnyObject {
    func receiverDidClose()
    func receiverDidOpen()
    func receiverSubscribeError()
    func receiverSubscribeSuccess()
    func receiverReceiveError()
    func receiverReceiveInvalidData()
    func receiverReceive(prices: [String : CryptoMarketPrice])
}

public protocol CryptoMarketPricesReceiver: WebsocketClientDelegate {
    var delegate: CryptoMarketPricesReceiverDelegate? { get set }
    
    func startReceive()
    
    func stopReceive()
}
