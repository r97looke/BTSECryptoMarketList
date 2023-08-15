//
//  LoadMarketListFromRemoteUseCaseTests.swift
//  CryptoMarketPriceTests
//
//  Created by Shun Lung Chen on 2023/8/16.
//

import XCTest

final class HTTPClientSpy {
    var requestURLs = [URL]()
    
    func get(from url: URL) {
        requestURLs.append(url)
    }
}

final class RemoteCryptoMarketLoader {
    
    private let url: URL
    private let client: HTTPClientSpy
    
    init(url: URL, client: HTTPClientSpy) {
        self.url = url
        self.client = client
    }
    
    func load() {
        client.get(from: url)
    }
}

final class LoadMarketListFromRemoteUseCaseTests: XCTestCase {

    func test_init_doesNotGetDataFromURL() {
        let (_, client) = makeSUT(url: anyURL())
        
        XCTAssertEqual(client.requestURLs, [])
    }
    
    func test_load_requestsDataFromURL() {
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        
        XCTAssertEqual(client.requestURLs, [url])
    }
    
    func test_load_deliversErrorOnClientError() {
        
    }
    
    // MARK: Helpers
    private func makeSUT(url: URL) -> (sut: RemoteCryptoMarketLoader, client: HTTPClientSpy) {
        let url = url
        let client = HTTPClientSpy()
        let sut = RemoteCryptoMarketLoader(url: url, client: client)
        
        return (sut, client)
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://www.any-url")!
    }

}
