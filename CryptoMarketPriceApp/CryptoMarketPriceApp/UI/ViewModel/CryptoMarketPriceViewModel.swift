//
//  CryptoMarketPriceViewModel.swift
//  CryptoMarketPriceApp
//
//  Created by Shun Lung Chen on 2023/8/16.
//

import Foundation
import CryptoMarketPrice
import RxSwift
import RxCocoa

final class CryptoMarketPriceViewModel {
    enum CryptoMarketType: Int {
        case spot = 0
        case future
    }
    
    enum CryptoMarketSortMethod: Int, CaseIterable {
        case nameAsceding = 0
        case nameDesceding
        case priceAsceding
        case priceDesceding
        
        func displayText() -> String {
            switch self {
            case .nameAsceding:
                return "Name Asceding"
                
            case .nameDesceding:
                return "Name Desceding"
                
            case .priceAsceding:
                return "Price Asceding"
                
            case .priceDesceding:
                return "Price Desceding"
            }
        }
    }
    
    struct SpotFuture {
        let spot: [CryptoMarketNamePriceModel]
        let future: [CryptoMarketNamePriceModel]
    }
    
    private let cryptoMarketLoader: CryptoMarketLoader
    private let cryptoMarketPricesReceiver: CryptoMarketPricesReceiver
    private let disposeBag = DisposeBag()
    
    // MARK: Inputs
    let selectedTypeRelay = BehaviorRelay<CryptoMarketType>(value: .spot)
    let selectedSortMethodRelay = BehaviorRelay<CryptoMarketSortMethod>(value: .nameAsceding)
    
    // MARK: Outputs
    let isLoading = PublishRelay<Bool>()
    
    // MARK: Internal
    private let spotFutureRelay = PublishRelay<SpotFuture>()
    private var spotFutureSubscribeDisposable: Disposable?
    private var displayModelsDriver: Driver<[CryptoMarketNamePriceModel]>?
    
    private var spotFuture: SpotFuture = SpotFuture(spot: [], future: [])
    
    init(cryptoMarketLoader: CryptoMarketLoader, cryptoMarketPricesReceiver: CryptoMarketPricesReceiver) {
        self.cryptoMarketLoader = cryptoMarketLoader
        self.cryptoMarketPricesReceiver = cryptoMarketPricesReceiver
        self.cryptoMarketPricesReceiver.delegate = self
    }
    
    func loadCryptoMarket() -> Driver<[CryptoMarketNamePriceModel]> {
        if spotFutureSubscribeDisposable == nil {
            spotFutureSubscribeDisposable = spotFutureRelay.subscribe { [weak self] sportFuture in
                self?.spotFuture = sportFuture
            }
            spotFutureSubscribeDisposable?.disposed(by: disposeBag)
        }
        
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
                    price: nil)
            }
            
            let future = receivedCryptoMarkets.filter{ $0.future }.map { market in
                CryptoMarketNamePriceModel(
                    nameText: market.symbol,
                    price: nil)
            }
            
            let spotFuture = SpotFuture(spot: spot, future: future)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.spotFutureRelay.accept(spotFuture)
                
                self.isLoading.accept(false)
            }
        }
        
        if displayModelsDriver != nil {
            return displayModelsDriver!
        }
        
        displayModelsDriver = Observable.combineLatest(selectedTypeRelay, selectedSortMethodRelay, spotFutureRelay) { type, sortMethod, spotFuture in
            if type == .spot {
                if sortMethod == .nameDesceding {
                    return spotFuture.spot.sorted { $0.nameText > $1.nameText }
                }
                else if sortMethod == .priceAsceding {
                    return spotFuture.spot.sorted { ($0.price ?? 0) < ($1.price ?? 0) }
                }
                else if sortMethod == .priceDesceding {
                    return spotFuture.spot.sorted { ($0.price ?? 0) > ($1.price ?? 0) }
                }
                else {
                    return spotFuture.spot.sorted { $0.nameText < $1.nameText }
                }
            }
            else {
                if sortMethod == .nameDesceding {
                    return spotFuture.future.sorted { $0.nameText > $1.nameText }
                }
                else if sortMethod == .priceAsceding {
                    return spotFuture.future.sorted { ($0.price ?? 0) < ($1.price ?? 0) }
                }
                else if sortMethod == .priceDesceding {
                    return spotFuture.future.sorted { ($0.price ?? 0) > ($1.price ?? 0) }
                }
                else {
                    return spotFuture.future.sorted { $0.nameText < $1.nameText }
                }
            }
        }.asDriver(onErrorJustReturn: [])
        return displayModelsDriver!
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
            
            let spotFuture = self.spotFuture
            let spot = spotFuture.spot
            let future = spotFuture.future
            let updatedSpot = spot.map { model in
                if let cryptoMarketPrice = prices["\(model.nameText)_1"] {
                    return CryptoMarketNamePriceModel(
                        nameText: model.nameText,
                        price: cryptoMarketPrice.price)
                }
                else {
                    return model
                }
            }
            
            let updatedFuture = future.map { model in
                if let cryptoMarketPrice = prices["\(model.nameText)_1"] {
                    return CryptoMarketNamePriceModel(
                        nameText: model.nameText,
                        price: cryptoMarketPrice.price)
                }
                else {
                    return model
                }
            }
            
            let updatedSpotFuture = SpotFuture(spot: updatedSpot, future: updatedFuture)
            self.spotFutureRelay.accept(updatedSpotFuture)
        }
    }
}
