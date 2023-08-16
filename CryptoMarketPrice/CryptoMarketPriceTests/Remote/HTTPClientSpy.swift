//
//  HTTPClientSpy.swift
//  CryptoMarketPriceTests
//
//  Created by Shun Lung Chen on 2023/8/16.
//

import Foundation
import CryptoMarketPrice

final class HTTPClientSpy: HTTPClient {
    var requestURLs = [URL]()
    var requestCompletions = [(Result) -> Void]()
    
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
        requestURLs.append(url)
        requestCompletions.append(completion)
    }
    
    func complete(with error: Error, at index: Int = 0) {
        requestCompletions[index](.failure(error))
    }
    
    func complete(with statusCode: Int, data: Data, at index: Int = 0) {
        let response = HTTPURLResponse(url: requestURLs[index], statusCode: statusCode, httpVersion: nil, headerFields: nil)!
        requestCompletions[index](.success((data, response)))
    }
}
