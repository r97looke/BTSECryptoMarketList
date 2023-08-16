//
//  Helpers.swift
//  CryptoMarketPriceTests
//
//  Created by Shun Lung Chen on 2023/8/16.
//

import Foundation

func anyURL() -> URL {
    return URL(string: "http://www.any-url")!
}

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: -1)
}
