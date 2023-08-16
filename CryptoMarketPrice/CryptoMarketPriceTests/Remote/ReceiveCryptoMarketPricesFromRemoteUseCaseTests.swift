//
//  ReceiveCryptoMarketPricesFromRemoteUseCaseTests.swift
//  CryptoMarketPriceTests
//
//  Created by Shun Lung Chen on 2023/8/16.
//

import XCTest
import CryptoMarketPrice

final class ReceiveCryptoMarketPricesFromRemoteUseCaseTests: XCTestCase {

    func test_init_doesNotRequestConnect() {
        let (_, client, _) = makeSUT()
        
        XCTAssertEqual(client.requestConnectURLs, [])
    }
    
    func test_startReceive_requestConnectToTheURL() {
        let url = anyWebsocketURL()
        let (sut, client, _) = makeSUT(url: url)
        
        sut.startReceive()
        
        XCTAssertEqual(client.requestConnectURLs, [url])
    }
    
    func test_startReceive_delegateCloseOnConnectError() {
        let (sut, client, delegate) = makeSUT()
        
        sut.startReceive()
        
        client.completeConnect(with: anyNSError())
        XCTAssertEqual(delegate.message, [.close])
    }
    
    func test_startReceive_delegateOpenOnConnectSuccess() {
        let (sut, client, delegate) = makeSUT()
        
        sut.startReceive()
        
        client.completeConnectSuccess()
        XCTAssertEqual(delegate.message, [.open])
    }
    
    func test_startReceive_sendSubscribeCoinIndexOnOpen() {
        let (sut, client, _) = makeSUT()
        
        sut.startReceive()
        
        client.completeConnectSuccess()
        XCTAssertEqual(client.sentStrings.count, 1)
    }
    
    func test_startReceive_delegateErrorOnSubscribeCoinIndexError() {
        let (sut, client, delegate) = makeSUT()
        
        sut.startReceive()
        
        client.completeConnectSuccess()
        client.completeSend(with: anyNSError())
        XCTAssertEqual(delegate.message, [.open, .subscribeError])
    }
    
    func test_startReceive_delegateSuccesOnSubscribeCoinIndexSuccess() {
        let (sut, client, delegate) = makeSUT()
        
        sut.startReceive()
        
        client.completeConnectSuccess()
        client.completeSendSuccess()
        XCTAssertEqual(delegate.message, [.open, .subscribeSuccess])
    }
    
    func test_startReceive_requestsReceiveOnSubscribeCoinIndexSuccess() {
        let (sut, client, _) = makeSUT()
        
        sut.startReceive()
        
        client.completeConnectSuccess()
        client.completeSendSuccess()
        XCTAssertNotEqual(client.receiveCallCount, 0)
    }
    
    func test_startReceive_delegateErrorOnReceiveError() {
        let (sut, client, delegate) = makeSUT()
        
        sut.startReceive()
        
        client.completeConnectSuccess()
        client.completeSendSuccess()
        client.completeReceive(with: anyNSError())
        XCTAssertEqual(delegate.message, [.open, .subscribeSuccess, .receiveError])
    }
    
    func test_startReceive_delegateInvalidDataOnReceiveEmptyData() {
        let (sut, client, delegate) = makeSUT()
        
        sut.startReceive()
        
        client.completeConnectSuccess()
        client.completeSendSuccess()
        client.completeReceive(with: Data())
        XCTAssertEqual(delegate.message, [.open, .subscribeSuccess, .receiveInvalidData])
    }
    
    func test_startReceive_delegateInvalidDataOnReceiveInvalidData() {
        let (sut, client, delegate) = makeSUT()
        
        sut.startReceive()
        
        client.completeConnectSuccess()
        client.completeSendSuccess()
        client.completeReceive(with: Data("invalid data".utf8))
        XCTAssertEqual(delegate.message, [.open, .subscribeSuccess, .receiveInvalidData])
    }
    
    func test_startReceive_delegateItemsOnReceiveValidData() {
        let prices = testCryptoMarketPrices()
        let (sut, client, delegate) = makeSUT()
        
        sut.startReceive()
        
        client.completeConnectSuccess()
        client.completeSendSuccess()
        client.completeReceive(with: makeCryptoMarketPricesJSON(cryptoMarketPrices: prices))
        XCTAssertEqual(delegate.message, [.open, .subscribeSuccess, .receivePrices(prices)])
    }
    
    func test_stopReceive_requestDisconnect() {
        let prices = testCryptoMarketPrices()
        let (sut, client, _) = makeSUT()
        
        sut.startReceive()
        client.completeConnectSuccess()
        client.completeSendSuccess()
        client.completeReceive(with: makeCryptoMarketPricesJSON(cryptoMarketPrices: prices))
        sut.stopReceive()
        XCTAssertEqual(client.disconnectCallCount, 1)
    }
    
    // MARK: Helpers
    private func makeSUT(url: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteCryptoMarketPricesReceiver, client: WebsocketClientSpy, delegate: CryptoMarketPricesReceiverDelegateSpy){
        let url = url ?? anyWebsocketURL()
        let delegate = CryptoMarketPricesReceiverDelegateSpy()
        let client = WebsocketClientSpy()
        let sut = RemoteCryptoMarketPricesReceiver(url: url, client: client)
        sut.delegate = delegate
        
        trackForMemoryLeaks(delegate, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, client, delegate)
    }
    
    private func anyWebsocketURL() -> URL {
        return URL(string: "wss://any-url")!
    }
    
    private func makeSubscribeJSON() -> [String : Any] {
        let subscribeJSON: [String : Any] = ["op": "subscribe",
                                             "args": ["coinIndex"]]
        return subscribeJSON
    }
    
    private func testCryptoMarketPrice() -> (String, CryptoMarketPrice) {
        let cryptoMarketPrice = CryptoMarketPrice(
            id: "ANT",
            name: "ANT",
            type: 1,
            price: 3.273782)
        return ("\(cryptoMarketPrice.name!)_\(cryptoMarketPrice.type!)", cryptoMarketPrice)
    }
    
    private func testAnotherCryptoMarketPrice() -> (String, CryptoMarketPrice) {
        let cryptoMarketPrice = CryptoMarketPrice(
            id: "ONE",
            name: "ONE",
            type: 1,
            price: 0.0125329578)
        return ("\(cryptoMarketPrice.name!)_\(cryptoMarketPrice.type!)", cryptoMarketPrice)
    }
    
    private func testCryptoMarketPrices() -> [String : CryptoMarketPrice] {
        let price1 = testCryptoMarketPrice()
        let price2 = testAnotherCryptoMarketPrice()
        return [price1.0 : price1.1,
                price2.0 : price2.1]
    }
    
    private func makeCryptoMarketPricesJSON(cryptoMarketPrices : [String : CryptoMarketPrice]) -> Data {
        var remoteCryptoMarketPrices = [String: RemoteCryptoMarketPrice]()
        for (key, value) in cryptoMarketPrices {
            remoteCryptoMarketPrices[key] = value.toRemote()
        }
        var data: [String : Any] = [:]
        for (key, value) in remoteCryptoMarketPrices {
            data[key] = ["id" : value.id!,
                         "name" : value.name!,
                         "type" : value.type!,
                         "price" : value.price] as [String : Any]
        }
        let json: [String : Any] = [ "topic" : "coinIndex",
                                     "data" : data ]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private final class WebsocketClientSpy: WebsocketClient {
        
        weak var delegate: WebsocketClientDelegate?
        
        var requestConnectURLs = [URL]()
        
        var disconnectCallCount = 0
        
        var sentDatas = [Data]()
        
        var sentStrings = [String]()
        
        var receiveCallCount = 0
        
        func connect(url: URL) {
            requestConnectURLs.append(url)
        }
        
        func disconnect() {
            disconnectCallCount += 1
        }
        
        func send(data: Data) {
            sentDatas.append(data)
        }
        
        func send(string: String) {
            sentStrings.append(string)
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
        
        func completeReceive(with data: Data) {
            delegate?.websocketReceive(data: data)
        }
    }
}

private extension CryptoMarketPrice {
    func toRemote() -> RemoteCryptoMarketPrice {
        return RemoteCryptoMarketPrice(
            id: id,
            name: name,
            type: type,
            price: price)
    }
}
