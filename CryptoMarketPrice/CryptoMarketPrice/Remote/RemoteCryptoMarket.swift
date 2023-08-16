//
//  RemoteCryptoMarket.swift
//  CryptoMarketPrice
//
//  Created by Shun Lung Chen on 2023/8/16.
//

import Foundation

public struct RemoteCryptoMarket: Decodable {
    public let symbol: String
    public let future: Bool
    
    public init(symbol: String, future: Bool) {
        self.symbol = symbol
        self.future = future
    }
}
