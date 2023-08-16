//
//  RemoteCryptoMarketPricesReceiver.swift
//  CryptoMarketPrice
//
//  Created by Shun Lung Chen on 2023/8/16.
//

import Foundation

public final class RemoteCryptoMarketPricesReceiver: CryptoMarketPricesReceiver {
    
    private let url: URL
    private var client: WebsocketClient
    public weak var delegate: CryptoMarketPricesReceiverDelegate?
    
    public init(url: URL, client: WebsocketClient) {
        self.url = url
        self.client = client
        self.client.delegate = self
    }
    
    public func startReceive() {
        client.connect(url: url)
    }
    
    public func stopReceive() {
        client.disconnect()
    }

    // MARK: WebsocketClientDelegate
    
    public func websocketDidClose() {
        delegate?.receiverDidClose()
    }
    
    public func websocketDidOpen() {
        delegate?.receiverDidOpen()
        
        let subscribeJSON: [String : Any] = ["op": "subscribe",
                                             "args": ["coinIndex"]]
        
        client.send(data: try! JSONSerialization.data(withJSONObject: subscribeJSON))
    }
    
    public func websocketSendError() {
        delegate?.receiverSubscribeError()
    }
    
    public func websocketSendSuccess() {
        delegate?.receiverSubscribeSuccess()
        
        client.receive()
    }
    
    public func websocketReceiveError() {
        delegate?.receiverReceiveError()
    }
    
    public func websocketReceive(data: Data) {
        if !data.isEmpty, let message = try? JSONDecoder().decode(RemoteCryptoMarketPricesMessage.self, from: data), let remotePrices = message.data, !remotePrices.isEmpty {
            var prices = [String : CryptoMarketPrice]()
            for (key, remote) in remotePrices {
                prices[key] = remote.toModel()
            }
            delegate?.receiverReceive(prices: prices)
        }
        else {
            delegate?.receiverReceiveInvalidData()
        }
    }
}

private extension RemoteCryptoMarketPrice {
    func toModel() -> CryptoMarketPrice {
        return CryptoMarketPrice(
            id: id,
            name: name,
            type: type,
            price: price)
    }
}
