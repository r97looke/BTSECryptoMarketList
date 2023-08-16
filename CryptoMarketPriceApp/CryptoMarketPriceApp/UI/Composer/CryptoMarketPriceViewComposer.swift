//
//  CryptoMarketPriceViewComposer.swift
//  CryptoMarketPriceApp
//
//  Created by Shun Lung Chen on 2023/8/16.
//

import Foundation
import CryptoMarketPrice

class CryptoMarketPriceViewComposer {
    
    static func compose(cryptoMarketLoader: CryptoMarketLoader, cryptoMarketPricesReceiver: CryptoMarketPricesReceiver) -> CryptoMarketPriceViewController {
        let viewModel = CryptoMarketPriceViewModel(cryptoMarketLoader: cryptoMarketLoader, cryptoMarketPricesReceiver: cryptoMarketPricesReceiver)
        let viewController = CryptoMarketPriceViewController(viewModel: viewModel)
        
        viewModel.onLoadingStateChange = { [weak viewController] isLoading in
            DispatchQueue.main.async {
                viewController?.isLoadingCryptoMarket = isLoading
            }
        }
        
        viewModel.onCryptoMarketLoaded = { [weak viewModel, weak viewController] cryptoMarkets in
            guard let viewModel = viewModel, let viewController = viewController else { return }
            
            let spotCryptoMarketNamePriceModels = cryptoMarkets.filter { !$0.future }
                .map { CryptoMarketNamePriceModel(
                    nameText: $0.symbol,
                    priceText: "--")
                }.sorted { model1, model2 in
                    return model1.nameText < model2.nameText
                }
            
            let futureCryptoMarketNamePriceModels = cryptoMarkets.filter { $0.future }
                .map { CryptoMarketNamePriceModel(
                    nameText: $0.symbol,
                    priceText: "--")
                }.sorted { model1, model2 in
                    return model1.nameText < model2.nameText
                }
            
            DispatchQueue.main.async { [weak viewModel, weak viewController] in
                guard let viewModel = viewModel, let viewController = viewController else { return }
                
                viewModel.spotCryptoMarketNamePriceModels = spotCryptoMarketNamePriceModels
                viewModel.futureCryptoMarketNamePriceModels = futureCryptoMarketNamePriceModels
                if viewModel.selectedCryptoMarketType == .spot {
                    viewController.displayCryptoMarketNamePriceModels = spotCryptoMarketNamePriceModels
                }
                else if viewModel.selectedCryptoMarketType == .future {
                    viewController.displayCryptoMarketNamePriceModels = futureCryptoMarketNamePriceModels
                }
            }
        }
        
        viewModel.onCryptoMarketPricesUpdate = { [weak viewModel, weak viewController] prices in
            guard let viewModel = viewModel, let viewController = viewController else { return }
            
            let spotCryptoMarketNamePriceModels = viewModel.spotCryptoMarketNamePriceModels
            let updatedSpotCryptoMarketNamePriceModels = spotCryptoMarketNamePriceModels.map { model in
                if let cryptoMarketPrice = prices["\(model.nameText)_1"] {
                    return CryptoMarketNamePriceModel(
                        nameText: model.nameText,
                        priceText: "\(cryptoMarketPrice.price)")
                }
                else {
                    return model
                }
            }
            
            let futureCryptoMarketNamePriceModels = viewModel.futureCryptoMarketNamePriceModels
            let updatedFutureCryptoMarketNamePriceModels = futureCryptoMarketNamePriceModels.map { model in
                if let cryptoMarketPrice = prices["\(model.nameText)_1"] {
                    return CryptoMarketNamePriceModel(
                        nameText: model.nameText,
                        priceText: "\(cryptoMarketPrice.price)")
                }
                else {
                    return model
                }
            }
            
            DispatchQueue.main.async { [weak viewModel, weak viewController] in
                guard let viewModel = viewModel, let viewController = viewController else { return }
                
                viewModel.spotCryptoMarketNamePriceModels = updatedSpotCryptoMarketNamePriceModels
                viewModel.futureCryptoMarketNamePriceModels = updatedFutureCryptoMarketNamePriceModels
                if viewModel.selectedCryptoMarketType == .spot {
                    viewController.displayCryptoMarketNamePriceModels = viewModel.spotCryptoMarketNamePriceModels
                }
                else if viewModel.selectedCryptoMarketType == .future {
                    viewController.displayCryptoMarketNamePriceModels = viewModel.futureCryptoMarketNamePriceModels
                }
            }
        }
        
        viewModel.onSelectCryptoMarketTypeChange = { [weak viewModel, weak viewController] in
            guard let viewModel = viewModel, let viewController = viewController else { return }
            
            if viewModel.selectedCryptoMarketType == .spot {
                viewController.displayCryptoMarketNamePriceModels = viewModel.spotCryptoMarketNamePriceModels
            }
            else if viewModel.selectedCryptoMarketType == .future {
                viewController.displayCryptoMarketNamePriceModels = viewModel.futureCryptoMarketNamePriceModels
            }
            
        }
        
        return viewController
    }
}
