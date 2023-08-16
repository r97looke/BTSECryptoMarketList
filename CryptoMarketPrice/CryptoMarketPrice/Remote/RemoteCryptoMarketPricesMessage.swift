//
//  RemoteCryptoMarketPricesMessage.swift
//  CryptoMarketPrice
//
//  Created by Shun Lung Chen on 2023/8/16.
//

import Foundation

public struct RemoteCryptoMarketPricesMessage: Codable {
    public let topic: String?
    public let data: [String : RemoteCryptoMarketPrice]?
    
    public init(topic: String?, data: [String : RemoteCryptoMarketPrice]?) {
        self.topic = topic
        self.data = data
    }
}
