//
//  ReceiveCryptoMarketPricesFromRemoteUseCaseTests.swift
//  CryptoMarketPriceTests
//
//  Created by Shun Lung Chen on 2023/8/16.
//

import XCTest

protocol WebsocketClientDelegate: AnyObject {
    func websocketConnectError(error: Error)
}

protocol WebsocketClient {
    var delegate: WebsocketClientDelegate? { set get }
}

final class WebsocketClientSpy: WebsocketClient {
    
    weak var delegate: WebsocketClientDelegate?
    
    var requestConnectURLs = [URL]()
    
    func connect(url: URL) {
        requestConnectURLs.append(url)
    }
    
    func completeConnect(with error: Error) {
        delegate?.websocketConnectError(error: error)
    }
}

protocol CryptoMarketPricesReceiverDelegate: AnyObject {
    func receiverDidFinishConnect(with error: Error)
}

protocol CryptoMarketPricesReceiver: WebsocketClientDelegate {
    var delegate: CryptoMarketPricesReceiverDelegate? { get set }
}

final class RemoteCryptoMarketPricesReceiver: CryptoMarketPricesReceiver {
    
    let url: URL
    let client: WebsocketClientSpy
    weak var delegate: CryptoMarketPricesReceiverDelegate?
    
    init(url: URL, client: WebsocketClientSpy) {
        self.url = url
        self.client = client
        client.delegate = self
    }
    
    func startReceive() {
        client.connect(url: url)
    }
    
    // MARK: WebsocketClientDelegate
    func websocketConnectError(error: Error) {
        delegate?.receiverDidFinishConnect(with: error)
    }
}

final class CryptoMarketPricesReceiverDelegateSpy: CryptoMarketPricesReceiverDelegate {
    enum Message: Equatable {
        case connectError
    }
    
    var message = [Message]()
    
    func receiverDidFinishConnect(with error: Error) {
        message.append(.connectError)
    }
}

final class ReceiveCryptoMarketPricesFromRemoteUseCaseTests: XCTestCase {

    func test_init_doesNotRequestConnect() {
        let client = WebsocketClientSpy()
        let _ = RemoteCryptoMarketPricesReceiver(url: anyWebsocketURL(), client: client)
        
        XCTAssertEqual(client.requestConnectURLs, [])
    }
    
    func test_startReceive_requestConnectToTheURL() {
        let url = anyWebsocketURL()
        let client = WebsocketClientSpy()
        let sut = RemoteCryptoMarketPricesReceiver(url: url, client: client)
        
        sut.startReceive()
        
        XCTAssertEqual(client.requestConnectURLs, [url])
    }
    
    func test_startReceive_deliversErrorOnConnectError() {
        let url = anyWebsocketURL()
        let client = WebsocketClientSpy()
        let sut = RemoteCryptoMarketPricesReceiver(url: url, client: client)
        let delegateSpy = CryptoMarketPricesReceiverDelegateSpy()
        sut.delegate = delegateSpy
        
        sut.startReceive()
        
        client.completeConnect(with: anyNSError())
        XCTAssertEqual(delegateSpy.message, [.connectError])
    }
    
    // MARK: Helpers
    private func anyWebsocketURL() -> URL {
        return URL(string: "wss://any-url")!
    }
}
