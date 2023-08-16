//
//  HTTPClient.swift
//  CryptoMarketPrice
//
//  Created by Shun Lung Chen on 2023/8/16.
//

import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    func get(from url: URL, completion: @escaping (Result) -> Void)
}
