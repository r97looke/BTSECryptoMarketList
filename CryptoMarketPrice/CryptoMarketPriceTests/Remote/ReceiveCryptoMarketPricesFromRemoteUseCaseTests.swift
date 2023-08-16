//
//  ReceiveCryptoMarketPricesFromRemoteUseCaseTests.swift
//  CryptoMarketPriceTests
//
//  Created by Shun Lung Chen on 2023/8/16.
//

import XCTest
import CryptoMarketPrice

private extension RemoteCryptoMarketPrice {
    func toModel() -> CryptoMarketPrice {
        return CryptoMarketPrice(
            id: id,
            name: name,
            type: type,
            price: price)
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

protocol WebsocketClientDelegate: AnyObject {
    func websocketDidClose()
    func websocketDidOpen()
    func websocketSendError()
    func websocketSendSuccess()
    func websocketReceiveError()
    func websocketReceive(data: Data)
}

protocol WebsocketClient {
    var delegate: WebsocketClientDelegate? { set get }
    
    func connect(url: URL)
    
    func disconnect()
    
    func send(data: Data)
    
    func receive()
}

protocol CryptoMarketPricesReceiverDelegate: AnyObject {
    func receiverDidClose()
    func receiverDidOpen()
    func receiverSubscribeError()
    func receiverSubscribeSuccess()
    func receiverReceiveError()
    func receiverReceiveInvalidData()
    func receiverReceive(prices: [String : CryptoMarketPrice])
}

protocol CryptoMarketPricesReceiver: WebsocketClientDelegate {
    var delegate: CryptoMarketPricesReceiverDelegate? { get set }
}

final class RemoteCryptoMarketPricesReceiver: CryptoMarketPricesReceiver {
    
    private let url: URL
    private var client: WebsocketClient
    weak var delegate: CryptoMarketPricesReceiverDelegate?
    
    init(url: URL, client: WebsocketClient) {
        self.url = url
        self.client = client
        self.client.delegate = self
    }
    
    func startReceive() {
        client.connect(url: url)
    }
    
    func stopReceive() {
        client.disconnect()
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
    
    func websocketReceive(data: Data) {
        if !data.isEmpty, let message = try? JSONDecoder().decode(RemoteCryptoMarketPricesMessage.self, from: data), let remotePrices = message.data, !remotePrices.isEmpty {
            var prices = [String : CryptoMarketPrice]()
            for (key, remote) in remotePrices {
                prices[key] = remote.toModel()
            }
            delegate?.receiverReceive(prices: prices)
        }
        else {
            delegate?.receiverReceiveInvalidData()
        }
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
    
    func test_startReceive_delegateInvalidDataOnReceiveEmptyData() {
        let url = anyWebsocketURL()
        let client = WebsocketClientSpy()
        let sut = RemoteCryptoMarketPricesReceiver(url: url, client: client)
        let delegateSpy = CryptoMarketPricesReceiverDelegateSpy()
        sut.delegate = delegateSpy
        
        sut.startReceive()
        
        client.completeConnectSuccess()
        client.completeSendSuccess()
        client.completeReceive(with: Data())
        XCTAssertEqual(delegateSpy.message, [.open, .subscribeSuccess, .receiveInvalidData])
    }
    
    func test_startReceive_delegateInvalidDataOnReceiveInvalidData() {
        let url = anyWebsocketURL()
        let client = WebsocketClientSpy()
        let sut = RemoteCryptoMarketPricesReceiver(url: url, client: client)
        let delegateSpy = CryptoMarketPricesReceiverDelegateSpy()
        sut.delegate = delegateSpy
        
        sut.startReceive()
        
        client.completeConnectSuccess()
        client.completeSendSuccess()
        client.completeReceive(with: Data("invalid data".utf8))
        XCTAssertEqual(delegateSpy.message, [.open, .subscribeSuccess, .receiveInvalidData])
    }
    
    func test_startReceive_delegateItemsOnReceiveValidData() {
        let prices = testCryptoMarketPrices()
        let url = anyWebsocketURL()
        let client = WebsocketClientSpy()
        let sut = RemoteCryptoMarketPricesReceiver(url: url, client: client)
        let delegateSpy = CryptoMarketPricesReceiverDelegateSpy()
        sut.delegate = delegateSpy
        
        sut.startReceive()
        
        client.completeConnectSuccess()
        client.completeSendSuccess()
        client.completeReceive(with: makeCryptoMarketPricesJSON(cryptoMarketPrices: prices))
        XCTAssertEqual(delegateSpy.message, [.open, .subscribeSuccess, .receivePrices(prices)])
    }
    
    func test_stopReceive_requestDisconnect() {
        let prices = testCryptoMarketPrices()
        let url = anyWebsocketURL()
        let client = WebsocketClientSpy()
        let sut = RemoteCryptoMarketPricesReceiver(url: url, client: client)
        let delegateSpy = CryptoMarketPricesReceiverDelegateSpy()
        sut.delegate = delegateSpy
        
        sut.startReceive()
        client.completeConnectSuccess()
        client.completeSendSuccess()
        client.completeReceive(with: makeCryptoMarketPricesJSON(cryptoMarketPrices: prices))
        sut.stopReceive()
        XCTAssertEqual(client.disconnectCallCount, 1)
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
    
    private final class CryptoMarketPricesReceiverDelegateSpy: CryptoMarketPricesReceiverDelegate {
        enum Message: Equatable {
            case close
            case open
            case subscribeError
            case subscribeSuccess
            case receiveError
            case receiveInvalidData
            case receivePrices([String : CryptoMarketPrice])
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
        
        func receiverReceiveInvalidData() {
            message.append(.receiveInvalidData)
        }
        
        func receiverReceive(prices: [String : CryptoMarketPrice]) {
            message.append(.receivePrices(prices))
        }
    }
}
