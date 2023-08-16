//
//  CryptoMarketPriceRemoteIntegrationTests.swift
//  CryptoMarketPriceRemoteIntegrationTests
//
//  Created by Shun Lung Chen on 2023/8/16.
//

import XCTest
import CryptoMarketPrice

final class CryptoMarketPriceRemoteIntegrationTests: XCTestCase {

    func test_load_cryptoMarkets() {
        let session = URLSession(configuration: .ephemeral)
        let client = URLSessionHTTPClient(session: session)
        let loader = RemoteCryptoMarketLoader(url: testCryptoMarketsEndpointURL(), client: client)
        
        let exp = expectation(description: "Wait load to complete")
        loader.load { result in
            switch result {
            case let .success(cryptoMarkets):
                XCTAssertFalse(cryptoMarkets.isEmpty)
                
            default:
                XCTFail("Expect success, got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
    }

    // MARK: Helpers
    private func testCryptoMarketsEndpointURL() -> URL {
        return URL(string: "https://api.btse.com/futures/api/inquire/initial/market")!
    }
}
