//
//  CryptoMarketPrice.swift
//  CryptoMarketPrice
//
//  Created by Shun Lung Chen on 2023/8/16.
//

import Foundation

public struct CryptoMarketPrice: Equatable {
    public let id: String?
    public let name: String?
    public let type: Int?
    public let price: Double
    
    public init(id: String?, name: String?, type: Int?, price: Double) {
        self.id = id
        self.name = name
        self.type = type
        self.price = price
    }
}
