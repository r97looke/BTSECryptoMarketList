//
//  ReceiveCryptoMarketPricesFromRemoteUseCaseTests.swift
//  CryptoMarketPriceTests
//
//  Created by Shun Lung Chen on 2023/8/16.
//

import XCTest

protocol WebsocketClientDelegate: AnyObject {
    func websocketDidClose()
    func websocketDidOpen()
    func websocketSendError()
    func websocketSendSuccess()
    func websocketReceiveError()
}

protocol WebsocketClient {
    var delegate: WebsocketClientDelegate? { set get }
    
    func connect(url: URL)
    
    func send(data: Data)
    
    func receive()
}

final class WebsocketClientSpy: WebsocketClient {
    
    weak var delegate: WebsocketClientDelegate?
    
    var requestConnectURLs = [URL]()
    
    var sentDatas = [Data]()
    
    var receiveCallCount = 0
    
    func connect(url: URL) {
        requestConnectURLs.append(url)
    }
    
    func send(data: Data) {
        sentDatas.append(data)
    }
    
    func receive() {
        receiveCallCount += 1
    }
    
    func completeConnect(with error: Error) {
        delegate?.websocketDidClose()
    }
    
    func completeConnectSuccess() {
        delegate?.websocketDidOpen()
    }
    
    func completeSend(with error: Error) {
        delegate?.websocketSendError()
    }
    
    func completeSendSuccess() {
        delegate?.websocketSendSuccess()
    }
    
    func completeReceive(with error: Error) {
        delegate?.websocketReceiveError()
    }
}

protocol CryptoMarketPricesReceiverDelegate: AnyObject {
    func receiverDidClose()
    func receiverDidOpen()
    func receiverSubscribeError()
    func receiverSubscribeSuccess()
    func receiverReceiveError()
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
    func websocketDidClose() {
        delegate?.receiverDidClose()
    }
    
    func websocketDidOpen() {
        delegate?.receiverDidOpen()
        
        let subscribeJSON: [String : Any] = ["op": "subscribe",
                                             "args": ["coinIndex"]]
        
        client.send(data: try! JSONSerialization.data(withJSONObject: subscribeJSON))
    }
    
    func websocketSendError() {
        delegate?.receiverSubscribeError()
    }
    
    func websocketSendSuccess() {
        delegate?.receiverSubscribeSuccess()
        
        client.receive()
    }
    
    func websocketReceiveError() {
        delegate?.receiverReceiveError()
    }
}

final class CryptoMarketPricesReceiverDelegateSpy: CryptoMarketPricesReceiverDelegate {
    enum Message: Equatable {
        case close
        case open
        case subscribeError
        case subscribeSuccess
        case receiveError
    }
    
    var message = [Message]()
    
    func receiverDidClose() {
        message.append(.close)
    }
    
    func receiverDidOpen() {
        message.append(.open)
    }
    
    func receiverSubscribeError() {
        message.append(.subscribeError)
    }
    
    func receiverSubscribeSuccess() {
        message.append(.subscribeSuccess)
    }
    
    func receiverReceiveError() {
        message.append(.receiveError)
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
    
    func test_startReceive_delegateCloseOnConnectError() {
        let url = anyWebsocketURL()
        let client = WebsocketClientSpy()
        let sut = RemoteCryptoMarketPricesReceiver(url: url, client: client)
        let delegateSpy = CryptoMarketPricesReceiverDelegateSpy()
        sut.delegate = delegateSpy
        
        sut.startReceive()
        
        client.completeConnect(with: anyNSError())
        XCTAssertEqual(delegateSpy.message, [.close])
    }
    
    func test_startReceive_delegateOpenOnConnectSuccess() {
        let url = anyWebsocketURL()
        let client = WebsocketClientSpy()
        let sut = RemoteCryptoMarketPricesReceiver(url: url, client: client)
        let delegateSpy = CryptoMarketPricesReceiverDelegateSpy()
        sut.delegate = delegateSpy
        
        sut.startReceive()
        
        client.completeConnectSuccess()
        XCTAssertEqual(delegateSpy.message, [.open])
    }
    
    func test_startReceive_sendSubscribeCoinIndexOnOpen() {
        let url = anyWebsocketURL()
        let client = WebsocketClientSpy()
        let sut = RemoteCryptoMarketPricesReceiver(url: url, client: client)
        let delegateSpy = CryptoMarketPricesReceiverDelegateSpy()
        sut.delegate = delegateSpy
        
        sut.startReceive()
        
        client.completeConnectSuccess()
        XCTAssertEqual(client.sentDatas, [makeSubscribeJSON()])
    }
    
    func test_startReceive_delegateErrorOnSubscribeCoinIndexError() {
        let url = anyWebsocketURL()
        let client = WebsocketClientSpy()
        let sut = RemoteCryptoMarketPricesReceiver(url: url, client: client)
        let delegateSpy = CryptoMarketPricesReceiverDelegateSpy()
        sut.delegate = delegateSpy
        
        sut.startReceive()
        
        client.completeConnectSuccess()
        client.completeSend(with: anyNSError())
        XCTAssertEqual(delegateSpy.message, [.open, .subscribeError])
    }
    
    func test_startReceive_delegateSuccesOnSubscribeCoinIndexSuccess() {
        let url = anyWebsocketURL()
        let client = WebsocketClientSpy()
        let sut = RemoteCryptoMarketPricesReceiver(url: url, client: client)
        let delegateSpy = CryptoMarketPricesReceiverDelegateSpy()
        sut.delegate = delegateSpy
        
        sut.startReceive()
        
        client.completeConnectSuccess()
        client.completeSendSuccess()
        XCTAssertEqual(delegateSpy.message, [.open, .subscribeSuccess])
    }
    
    func test_startReceive_requestsReceiveOnSubscribeCoinIndexSuccess() {
        let url = anyWebsocketURL()
        let client = WebsocketClientSpy()
        let sut = RemoteCryptoMarketPricesReceiver(url: url, client: client)
        let delegateSpy = CryptoMarketPricesReceiverDelegateSpy()
        sut.delegate = delegateSpy
        
        sut.startReceive()
        
        client.completeConnectSuccess()
        client.completeSendSuccess()
        XCTAssertEqual(client.receiveCallCount, 1)
    }
    
    func test_startReceive_delegateErrorOnReceiveError() {
        let url = anyWebsocketURL()
        let client = WebsocketClientSpy()
        let sut = RemoteCryptoMarketPricesReceiver(url: url, client: client)
        let delegateSpy = CryptoMarketPricesReceiverDelegateSpy()
        sut.delegate = delegateSpy
        
        sut.startReceive()
        
        client.completeConnectSuccess()
        client.completeSendSuccess()
        client.completeReceive(with: anyNSError())
        XCTAssertEqual(delegateSpy.message, [.open, .subscribeSuccess, .receiveError])
    }
    
    // MARK: Helpers
    private func anyWebsocketURL() -> URL {
        return URL(string: "wss://any-url")!
    }
    
    private func makeSubscribeJSON() -> Data {
        let subscribeJSON: [String : Any] = ["op": "subscribe",
                                             "args": ["coinIndex"]]
        return try! JSONSerialization.data(withJSONObject: subscribeJSON)
    }
}
