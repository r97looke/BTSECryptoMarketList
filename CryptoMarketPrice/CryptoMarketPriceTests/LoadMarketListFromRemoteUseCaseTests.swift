//
//  LoadMarketListFromRemoteUseCaseTests.swift
//  CryptoMarketPriceTests
//
//  Created by Shun Lung Chen on 2023/8/16.
//

import XCTest
import CryptoMarketPrice

struct RemoteCryptoMarket: Decodable {
    let symbol: String
    let future: Bool
}

struct RemoteCyptoMarketResponse: Decodable {
    let code: Int?
    let data: [RemoteCryptoMarket]?
}

private extension Array where Element == CryptoMarket {
    func toRemote() -> [RemoteCryptoMarket] {
        return map{ RemoteCryptoMarket(
            symbol: $0.symbol,
            future: $0.future)
        }
    }
}

private extension Array where Element == RemoteCryptoMarket {
    func toModel() -> [CryptoMarket] {
        return map { CryptoMarket(
            symbol: $0.symbol,
            future: $0.future)
        }
    }
}

protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    func get(from url: URL, completion: @escaping (Result) -> Void)
}

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

protocol CryptoMarketLoader {
    typealias LoadResult = Swift.Result<[CryptoMarket], Error>
    
    func load(completion: @escaping (LoadResult) -> Void)
}

final class RemoteCryptoMarketLoader: CryptoMarketLoader {
    enum LoadError: Swift.Error {
        case invalidData
        case connectivity
    }
    
    private let url: URL
    private let client: HTTPClientSpy
    
    init(url: URL, client: HTTPClientSpy) {
        self.url = url
        self.client = client
    }
    
    func load(completion: @escaping (CryptoMarketLoader.LoadResult) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .failure(error):
                completion(.failure(error))
                
            case let .success((data, httpURLResponse)):
                if httpURLResponse.statusCode == 200, !data.isEmpty, let remoteCryptoResponse = try? JSONDecoder().decode(RemoteCyptoMarketResponse.self, from: data), let remoteCryptoMarkets = remoteCryptoResponse.data, !remoteCryptoMarkets.isEmpty {
                    completion(.success(remoteCryptoMarkets.toModel()))
                }
                else {
                    completion(.failure(LoadError.invalidData))
                }
            }
        }
    }
}

final class LoadMarketListFromRemoteUseCaseTests: XCTestCase {

    func test_init_doesNotGetDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertEqual(client.requestURLs, [])
    }
    
    func test_load_requestsDataFromURL() {
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)
        
        sut.load() { _ in }
        
        XCTAssertEqual(client.requestURLs, [url])
    }
    
    func test_load_twice_requestsDataFromURLTwice() {
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)
        
        sut.load() { _ in }
        sut.load() { _ in }
        
        XCTAssertEqual(client.requestURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(RemoteCryptoMarketLoader.LoadError.invalidData)) {
            client.complete(with: anyNSError())
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPURLResponse() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(RemoteCryptoMarketLoader.LoadError.invalidData)) {
            client.complete(with: 199, data: Data())
        }
    }
    
    func test_load_deliversErrorON200HTTPURLResponseWithInvalidData() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(RemoteCryptoMarketLoader.LoadError.invalidData)) {
            client.complete(with: 200, data: Data("invalid data".utf8))
        }
    }
    
    func test_load_deliversErrorON200HTTPURLResponseWithEmptyData() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(RemoteCryptoMarketLoader.LoadError.invalidData)) {
            client.complete(with: 200, data: Data())
        }
    }
    
    func test_load_deliversItemsON200HTTPURLResponseWithValidData() {
        let cryptoMarkets = testCryptoMarkets()
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .success(cryptoMarkets)) {
            client.complete(with: 200, data: makeCryptoMarketsJSON(cryptoMarkets: cryptoMarkets))
        }
    }
    
    func test_load_doesNotDeliverResultAfterSUTHasBeenDeallocate() {
        let client = HTTPClientSpy()
        var sut: RemoteCryptoMarketLoader? = RemoteCryptoMarketLoader(url: anyURL(), client: client)
        
        var receivedResult: RemoteCryptoMarketLoader.LoadResult?
        sut?.load() { result in
            receivedResult = result
        }
        
        sut = nil
        client.complete(with: anyNSError())
        XCTAssertNil(receivedResult)
    }
    
    // MARK: Helpers
    private func makeSUT(url: URL = URL(string: "http://any-url")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteCryptoMarketLoader, client: HTTPClientSpy) {
        let url = url
        let client = HTTPClientSpy()
        let sut = RemoteCryptoMarketLoader(url: url, client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }
    
    private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should be deallocated. There may be a memory leak.", file: file, line: line)
        }
    }
    
    private func expect(_ sut: RemoteCryptoMarketLoader, toCompleteWith expectedResult: RemoteCryptoMarketLoader.LoadResult, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait load to complete")
        sut.load() { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedCryptoMarkets), .success(expectedCryptoMarkets)):
                XCTAssertEqual(receivedCryptoMarkets, expectedCryptoMarkets, file: file, line: line)
                
            case (.failure, .failure):
                break
                
            default:
                XCTFail("Expect \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    private func testCryptoMarket() -> CryptoMarket {
        return CryptoMarket(symbol: "CYBER", future: false)
    }
    
    private func testAnotherCryptoMarket() -> CryptoMarket {
        return CryptoMarket(symbol: "BTC-PERP", future: true)
    }
    
    private func testCryptoMarkets() -> [CryptoMarket] {
        return [testCryptoMarket(), testAnotherCryptoMarket()]
    }
    
    private func makeCryptoMarketsJSON(cryptoMarkets: [CryptoMarket]) -> Data {
        var data = [[String : Any]]()
        for cryptoMarket in cryptoMarkets {
            data.append(["symbol" : cryptoMarket.symbol,
                         "future" : cryptoMarket.future])
        }
        let JSON: [String: Any] = ["code" : 1,
                                   "data" : data]
        return try! JSONSerialization.data(withJSONObject: JSON)
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://www.any-url")!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: -1)
    }

}
