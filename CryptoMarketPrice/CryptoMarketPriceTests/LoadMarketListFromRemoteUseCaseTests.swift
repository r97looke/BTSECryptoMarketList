//
//  LoadMarketListFromRemoteUseCaseTests.swift
//  CryptoMarketPriceTests
//
//  Created by Shun Lung Chen on 2023/8/16.
//

import XCTest

struct CryptoMarket {
    let symbol: String
    let future: Bool
}

final class HTTPClientSpy {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    var requestURLs = [URL]()
    var requestCompletions = [(Result) -> Void]()
    
    func get(from url: URL, completion: @escaping (Result) -> Void) {
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

final class RemoteCryptoMarketLoader {
    enum LoadError: Swift.Error {
        case invalidData
        case connectivity
    }
    
    typealias LoadResult = Swift.Result<[CryptoMarket], Error>
    
    private let url: URL
    private let client: HTTPClientSpy
    
    init(url: URL, client: HTTPClientSpy) {
        self.url = url
        self.client = client
    }
    
    func load(completion: @escaping (LoadResult) -> Void) {
        client.get(from: url) { result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
                
            case .success:
                completion(.failure(LoadError.invalidData))
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
        
        let exp = expectation(description: "Wait load to complete")
        var receivedError: Error?
        sut.load() { result in
            switch result {
            case let .failure(error):
                receivedError = error
                break
                
            default:
                XCTFail("Expect error, got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        client.complete(with: NSError(domain: "any error", code: -1))
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNotNil(receivedError)
    }
    
    func test_load_deliversErrorOnNon200HTTPURLResponse() {
        let (sut, client) = makeSUT()
        
        let exp = expectation(description: "Wait load to complete")
        var receivedError: Error?
        sut.load() { result in
            switch result {
            case let .failure(error):
                receivedError = error
                break
                
            default:
                XCTFail("Expect error, got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        client.complete(with: 199, data: Data())
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertNotNil(receivedError)
    }
    
    func test_load_deliversErrorON200HTTPURLResponseWithInvalidData() {
        let (sut, client) = makeSUT()
        
        let exp = expectation(description: "Wait load to complete")
        var receivedError: Error?
        sut.load() { result in
            switch result {
            case let .failure(error):
                receivedError = error
                break
                
            default:
                XCTFail("Expect error, got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        client.complete(with: 200, data: Data("invalid data".utf8))
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertNotNil(receivedError)
    }
    
    func test_load_deliversErrorON200HTTPURLResponseWithEmptyData() {
        let (sut, client) = makeSUT()
        
        let exp = expectation(description: "Wait load to complete")
        var receivedError: Error?
        sut.load() { result in
            switch result {
            case let .failure(error):
                receivedError = error
                break
                
            default:
                XCTFail("Expect error, got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        client.complete(with: 200, data: Data())
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertNotNil(receivedError)
    }
    
    // MARK: Helpers
    private func makeSUT(url: URL = URL(string: "http://any-url")!) -> (sut: RemoteCryptoMarketLoader, client: HTTPClientSpy) {
        let url = url
        let client = HTTPClientSpy()
        let sut = RemoteCryptoMarketLoader(url: url, client: client)
        
        return (sut, client)
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://www.any-url")!
    }

}
