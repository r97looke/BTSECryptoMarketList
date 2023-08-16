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
    
    func test_receive_cryptoMarketPrices() {
        let session = URLSession(configuration: .ephemeral)
        let client = URLSessionWebsocketClient(session: session)
        let receiver = RemoteCryptoMarketPricesReceiver(url: testWebsocketEndpointURL(), client: client)
        
        let exp = expectation(description: "Wait receive message")
        let delegate = RemoteCryptoMarketPricesReceiverDelegateSpy(exp: exp)
        receiver.delegate = delegate
        
        receiver.startReceive()
        
        wait(for: [exp], timeout: 10.0)
        receiver.stopReceive()
    }

    // MARK: Helpers
    private func testCryptoMarketsEndpointURL() -> URL {
        return URL(string: "https://api.btse.com/futures/api/inquire/initial/market")!
    }
    
    private func testWebsocketEndpointURL() -> URL {
        return URL(string: "wss://ws.btse.com/ws/futures")!
    }
    
    private class RemoteCryptoMarketPricesReceiverDelegateSpy: CryptoMarketPricesReceiverDelegate {
        
        let exp: XCTestExpectation
        
        init(exp: XCTestExpectation) {
            self.exp = exp
        }
        
        func receiverDidClose() {
            XCTFail("Expect open got close instead")
        }
        
        func receiverDidOpen() {
            
        }
        
        func receiverSubscribeError() {
            XCTFail("Expect success got subscribe error instead")
        }
        
        func receiverSubscribeSuccess() {
            
        }
        
        func receiverReceiveError() {
            XCTFail("Expect success got receive error instead")
        }
        
        func receiverReceiveInvalidData() {
        }
        
        func receiverReceive(prices: [String : CryptoMarketPrice]) {
            exp.fulfill()
        }
    }
}
