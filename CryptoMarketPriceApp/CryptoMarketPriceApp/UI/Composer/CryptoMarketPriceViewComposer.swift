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
        
        viewModel.onCryptoMarketLoaded = { [weak viewController] cryptoMarkets in
            let cryptoMarketNamePriceModels = cryptoMarkets.map {
                CryptoMarketNamePriceModel(
                    nameText: $0.symbol,
                    priceText: "--")
            }.sorted { model1, model2 in
                return model1.nameText < model2.nameText
            }
            
            DispatchQueue.main.async { [weak viewController] in
                viewModel.cryptoMarketNamePriceModels = cryptoMarketNamePriceModels
                viewController?.cryptoMarketNamePriceModels = cryptoMarketNamePriceModels
            }
        }
        
        viewModel.onCryptoMarketPricesUpdate = { [weak viewController] prices in
            let cryptoMarketNamePriceModels = viewModel.cryptoMarketNamePriceModels
            let updatedCryptoMarketNamePriceModels = cryptoMarketNamePriceModels.map { model in
                if let cryptoMarketPrice = prices["\(model.nameText)_1"] {
                    return CryptoMarketNamePriceModel(
                        nameText: model.nameText,
                        priceText: "\(cryptoMarketPrice.price)")
                }
                else {
                    return model
                }
            }
            
            DispatchQueue.main.async { [weak viewController] in
                viewModel.cryptoMarketNamePriceModels = updatedCryptoMarketNamePriceModels
                viewController?.cryptoMarketNamePriceModels = updatedCryptoMarketNamePriceModels
            }
        }
        
        return viewController
    }
}
