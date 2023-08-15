//
//  LoadMarketListFromRemoteUseCaseTests.swift
//  CryptoMarketPriceTests
//
//  Created by Shun Lung Chen on 2023/8/16.
//

import XCTest

class HTTPClientSpy {
    var getCallCount = 0
}

class RemoteCryptoMarketLoader {
    
    let client: HTTPClientSpy
    
    init(client: HTTPClientSpy) {
        self.client = client
    }
}

final class LoadMarketListFromRemoteUseCaseTests: XCTestCase {

    func test_init_doesNotGetDataFromURL() {
        let client = HTTPClientSpy()
        let _ = RemoteCryptoMarketLoader(client: client)
        
        XCTAssertEqual(client.getCallCount, 0)
    }

}
