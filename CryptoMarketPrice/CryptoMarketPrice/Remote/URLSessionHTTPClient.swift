//
//  URLSessionHTTPClient.swift
//  CryptoMarketPrice
//
//  Created by Shun Lung Chen on 2023/8/16.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    private struct InvalidDataResponseCombinationError: Error { }
    
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
        session.dataTask(with: URLRequest(url: url)) { data, response, error in
            if let clientError = error {
                completion(.failure(clientError))
            }
            else if let data = data, let httpURLResponse = response as? HTTPURLResponse {
                completion(.success((data, httpURLResponse)))
            }
            else {
                completion(.failure(InvalidDataResponseCombinationError()))
            }
        }.resume()
    }
}
