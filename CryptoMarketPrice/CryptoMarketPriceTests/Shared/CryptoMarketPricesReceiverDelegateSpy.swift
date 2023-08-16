//
//  CryptoMarketPricesReceiverDelegateSpy.swift
//  CryptoMarketPriceTests
//
//  Created by Shun Lung Chen on 2023/8/16.
//

import Foundation
import CryptoMarketPrice

final class CryptoMarketPricesReceiverDelegateSpy: CryptoMarketPricesReceiverDelegate {
    enum Message: Equatable {
        case close
        case open
        case subscribeError
        case subscribeSuccess
        case receiveError
        case receiveInvalidData
        case receivePrices([String : CryptoMarketPrice])
    }
    
    var message = [Message]()
    
    func receiverDidClose() {
        message.append(.close)
    }
    
    func receiverDidOpen() {
        message.append(.open)
    }
    
    func receiverSubscribeError() {
        message.append(.subscribeError)
    }
    
    func receiverSubscribeSuccess() {
        message.append(.subscribeSuccess)
    }
    
    func receiverReceiveError() {
        message.append(.receiveError)
    }
    
    func receiverReceiveInvalidData() {
        message.append(.receiveInvalidData)
    }
    
    func receiverReceive(prices: [String : CryptoMarketPrice]) {
        message.append(.receivePrices(prices))
    }
}
