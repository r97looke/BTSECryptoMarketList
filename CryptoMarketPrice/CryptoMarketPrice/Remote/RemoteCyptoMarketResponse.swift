//
//  RemoteCyptoMarketResponse.swift
//  CryptoMarketPrice
//
//  Created by Shun Lung Chen on 2023/8/16.
//

import Foundation

public struct RemoteCyptoMarketResponse: Decodable {
    public let code: Int?
    public let data: [RemoteCryptoMarket]?
    
    public init(code: Int?, data: [RemoteCryptoMarket]?) {
        self.code = code
        self.data = data
    }
}
