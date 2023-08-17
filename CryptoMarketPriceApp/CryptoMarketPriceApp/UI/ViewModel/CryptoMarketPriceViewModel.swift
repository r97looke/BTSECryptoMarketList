//
//  CryptoMarketPriceViewModel.swift
//  CryptoMarketPriceApp
//
//  Created by Shun Lung Chen on 2023/8/16.
//

import Foundation
import CryptoMarketPrice
import RxSwift
import RxRelay

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
                displayCryptoMarketNamePriceModels.accept(spotCryptoMarketNamePriceModels)
            }
            else {
                displayCryptoMarketNamePriceModels.accept(futureCryptoMarketNamePriceModels)
            }
        }
    }
    
    let isLoading = PublishRelay<Bool>()
    
    private var spotCryptoMarketNamePriceModels = [CryptoMarketNamePriceModel]()
    
    private var futureCryptoMarketNamePriceModels = [CryptoMarketNamePriceModel]()
    
    let displayCryptoMarketNamePriceModels = PublishRelay<[CryptoMarketNamePriceModel]>()
    
    func loadCryptoMarket() {
        isLoading.accept(true)
        
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
                    self.displayCryptoMarketNamePriceModels.accept(self.spotCryptoMarketNamePriceModels)
                }
                else {
                    self.displayCryptoMarketNamePriceModels.accept(self.futureCryptoMarketNamePriceModels)
                }
                
                self.isLoading.accept(false)
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
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
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
            
            self.spotCryptoMarketNamePriceModels = updatedSpot
            self.futureCryptoMarketNamePriceModels = updatedFuture
            if self.selectedCryptoMarketType == .spot {
                self.displayCryptoMarketNamePriceModels.accept(self.spotCryptoMarketNamePriceModels)
            }
            else if self.selectedCryptoMarketType == .future {
                self.displayCryptoMarketNamePriceModels.accept(self.futureCryptoMarketNamePriceModels)
            }
        }
    }
}
