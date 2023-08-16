//
//  ReceiveCryptoMarketPricesFromRemoteUseCaseTests.swift
//  CryptoMarketPriceTests
//
//  Created by Shun Lung Chen on 2023/8/16.
//

import XCTest

protocol WebsocketClient {
    
}

final class WebsocketClientSpy: WebsocketClient {
    
    var connectCallCount = 0
}

protocol CryptoMarketPricesReceiver {
    
}

final class RemoteCryptoMarketPricesReceiver: CryptoMarketPricesReceiver {
    
    let url: URL
    let client: WebsocketClient
    
    init(url: URL, client: WebsocketClient) {
        self.url = url
        self.client = client
    }
}

final class ReceiveCryptoMarketPricesFromRemoteUseCaseTests: XCTestCase {

    func test_init_doesNotRequestConnect() {
        let client = WebsocketClientSpy()
        let _ = RemoteCryptoMarketPricesReceiver(url: anyWebsocketURL(), client: client)
        
        XCTAssertEqual(client.connectCallCount, 0)
    }
    
    // MARK: Helpers
    private func anyWebsocketURL() -> URL {
        return URL(string: "wss://any-url")!
    }
}
