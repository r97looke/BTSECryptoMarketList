//
//  LoadMarketListFromRemoteUseCaseTests.swift
//  CryptoMarketPriceTests
//
//  Created by Shun Lung Chen on 2023/8/16.
//

import XCTest

final class HTTPClientSpy {
    typealias GETResult = Error?
    
    var requestURLs = [URL]()
    var requestCompletions = [(GETResult) -> Void]()
    
    func get(from url: URL, completion: @escaping (GETResult) -> Void) {
        requestURLs.append(url)
        requestCompletions.append(completion)
    }
    
    func completeWith(error: Error, at index: Int = 0) {
        requestCompletions[index](error)
    }
}

final class RemoteCryptoMarketLoader {
    typealias LoadResult = Error?
    
    private let url: URL
    private let client: HTTPClientSpy
    
    init(url: URL, client: HTTPClientSpy) {
        self.url = url
        self.client = client
    }
    
    func load(completion: @escaping (LoadResult) -> Void) {
        client.get(from: url) { error in
            completion(error)
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
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        let exp = expectation(description: "Wait load to complete")
        var receivedError: Error?
        sut.load() { error in
            receivedError = error
            
            exp.fulfill()
        }
        
        client.completeWith(error: NSError(domain: "any error", code: -1))
        
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
