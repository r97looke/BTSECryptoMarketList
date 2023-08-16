//
//  CryptoMarketPriceViewModel.swift
//  CryptoMarketPriceApp
//
//  Created by Shun Lung Chen on 2023/8/16.
//

import Foundation
import CryptoMarketPrice
import RxSwift

final class CryptoMarketPriceViewModel {
    private let cryptoMarketLoader: CryptoMarketLoader
    private let cryptoMarketPricesReceiver: CryptoMarketPricesReceiver
    
    init(cryptoMarketLoader: CryptoMarketLoader, cryptoMarketPricesReceiver: CryptoMarketPricesReceiver) {
        self.cryptoMarketLoader = cryptoMarketLoader
        self.cryptoMarketPricesReceiver = cryptoMarketPricesReceiver
        self.cryptoMarketPricesReceiver.delegate = self
    }
    
    enum CryptoMarketType: Int {
        case spot = 0
        case future
    }
    
    var selectedCryptoMarketType: CryptoMarketType = .spot {
        didSet {
            if selectedCryptoMarketType == .spot {
                displayCryptoMarketNamePriceModels = spotCryptoMarketNamePriceModels
            }
            else {
                displayCryptoMarketNamePriceModels = futureCryptoMarketNamePriceModels
            }
        }
    }
    
    var onLoadingStateChange: ((Bool) -> Void)?
    
    var isLoading: Bool = false {
        didSet {
            onLoadingStateChange?(isLoading)
        }
    }
    
    var spotCryptoMarketNamePriceModels = [CryptoMarketNamePriceModel]()
    
    var futureCryptoMarketNamePriceModels = [CryptoMarketNamePriceModel]()
    
    var displayCryptoMarketNamePriceModelsObserver: (([CryptoMarketNamePriceModel]) -> Void)?
    
    var displayCryptoMarketNamePriceModels = [CryptoMarketNamePriceModel]() {
        didSet {
            displayCryptoMarketNamePriceModelsObserver?(displayCryptoMarketNamePriceModels)
        }
    }
    
    func loadCryptoMarket() {
        isLoading = true
        
        cryptoMarketLoader.load { [weak self] result in
            guard let self = self else { return }
            
            var receivedCryptoMarkets = [CryptoMarket]()
            switch result {
            case let .success(cryptoMarkets):
                receivedCryptoMarkets = cryptoMarkets
                self.startReceive()
                
            default:
                break
            }
            
            let spot = receivedCryptoMarkets.filter{ !$0.future }.map { market in
                CryptoMarketNamePriceModel(
                    nameText: market.symbol,
                    priceText: "--")
            }.sorted { model1, model2 in
                model1.nameText < model2.nameText
            }
            
            let future = receivedCryptoMarkets.filter{ $0.future }.map { market in
                CryptoMarketNamePriceModel(
                    nameText: market.symbol,
                    priceText: "--")
            }.sorted { model1, model2 in
                model1.nameText < model2.nameText
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.spotCryptoMarketNamePriceModels = spot
                self.futureCryptoMarketNamePriceModels = future
                if self.selectedCryptoMarketType == .spot {
                    self.displayCryptoMarketNamePriceModels = self.spotCryptoMarketNamePriceModels
                }
                else {
                    self.displayCryptoMarketNamePriceModels = self.futureCryptoMarketNamePriceModels
                }
                
                self.isLoading = false
            }
        }
    }
    
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
        let spot = spotCryptoMarketNamePriceModels
        let future = futureCryptoMarketNamePriceModels
        let updatedSpot = spot.map { model in
            if let cryptoMarketPrice = prices["\(model.nameText)_1"] {
                return CryptoMarketNamePriceModel(
                    nameText: model.nameText,
                    priceText: "\(cryptoMarketPrice.price)")
            }
            else {
                return model
            }
        }
        
        let updatedFuture = future.map { model in
            if let cryptoMarketPrice = prices["\(model.nameText)_1"] {
                return CryptoMarketNamePriceModel(
                    nameText: model.nameText,
                    priceText: "\(cryptoMarketPrice.price)")
            }
            else {
                return model
            }
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.spotCryptoMarketNamePriceModels = updatedSpot
            self.futureCryptoMarketNamePriceModels = updatedFuture
            if self.selectedCryptoMarketType == .spot {
                self.displayCryptoMarketNamePriceModels = self.spotCryptoMarketNamePriceModels
            }
            else if self.selectedCryptoMarketType == .future {
                self.displayCryptoMarketNamePriceModels = self.futureCryptoMarketNamePriceModels
            }
        }
    }
}
