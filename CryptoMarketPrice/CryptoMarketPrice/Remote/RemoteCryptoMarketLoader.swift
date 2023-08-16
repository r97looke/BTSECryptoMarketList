//
//  RemoteCryptoMarketLoader.swift
//  CryptoMarketPrice
//
//  Created by Shun Lung Chen on 2023/8/16.
//

import Foundation

public final class RemoteCryptoMarketLoader: CryptoMarketLoader {
    public enum LoadError: Swift.Error {
        case invalidData
        case connectivity
    }
    
    private let url: URL
    private let client: HTTPClient
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (CryptoMarketLoader.LoadResult) -> Void) {
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

private extension Array where Element == RemoteCryptoMarket {
    func toModel() -> [CryptoMarket] {
        return map { CryptoMarket(
            symbol: $0.symbol,
            future: $0.future)
        }
    }
}
