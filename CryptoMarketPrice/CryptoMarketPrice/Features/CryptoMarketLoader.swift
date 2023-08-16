//
//  CryptoMarketLoader.swift
//  CryptoMarketPrice
//
//  Created by Shun Lung Chen on 2023/8/16.
//

import Foundation

public protocol CryptoMarketLoader {
    typealias LoadResult = Swift.Result<[CryptoMarket], Error>
    
    func load(completion: @escaping (LoadResult) -> Void)
}
