//
//  CryptoMarketPriceViewModel.swift
//  CryptoMarketPriceApp
//
//  Created by Shun Lung Chen on 2023/8/16.
//

import Foundation
import CryptoMarketPrice

final class CryptoMarketPriceViewModel {
    private let cryptoMarketLoader: CryptoMarketLoader
    private let cryptoMarketPricesReceiver: CryptoMarketPricesReceiver
    
    init(cryptoMarketLoader: CryptoMarketLoader, cryptoMarketPricesReceiver: CryptoMarketPricesReceiver) {
        self.cryptoMarketLoader = cryptoMarketLoader
        self.cryptoMarketPricesReceiver = cryptoMarketPricesReceiver
        self.cryptoMarketPricesReceiver.delegate = self
    }
    
    var cryptoMarketNamePriceModels = [CryptoMarketNamePriceModel]()
    
    var onLoadingStateChange: ((Bool) -> Void)?
    var onCryptoMarketLoaded: (([CryptoMarket]) -> Void)?
    
    func loadCryptoMarket() {
        onLoadingStateChange?(true)
        
        cryptoMarketLoader.load { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(cryptoMarkets):
                self.onCryptoMarketLoaded?(cryptoMarkets)
                self.startReceive()
                
            default:
                self.onCryptoMarketLoaded?([])
            }
            
            self.onLoadingStateChange?(false)
        }
    }
    
    var onCryptoMarketPricesUpdate: (([String : CryptoMarketPrice]) -> Void)?
    
    func startReceive() {
        cryptoMarketPricesReceiver.startReceive()
    }
    
    func stopReceive() {
        cryptoMarketPricesReceiver.stopReceive()
    }
}

// MARK: CryptoMarketPricesReceiverDelegate
extension CryptoMarketPriceViewModel: CryptoMarketPricesReceiverDelegate {
    
    func receiverDidClose() {
        
    }
    
    func receiverDidOpen() {
        
    }
    
    func receiverSubscribeError() {
        
    }
    
    func receiverSubscribeSuccess() {
        
    }
    
    func receiverReceiveError() {
        
    }
    
    func receiverReceiveInvalidData() {
        
    }
    
    func receiverReceive(prices: [String : CryptoMarketPrice]) {
        onCryptoMarketPricesUpdate?(prices)
    }
}
