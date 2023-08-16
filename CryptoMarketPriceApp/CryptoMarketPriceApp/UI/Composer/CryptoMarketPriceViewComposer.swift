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
            }
            
            DispatchQueue.main.async {
                viewController?.cryptoMarketNamePriceModels = cryptoMarketNamePriceModels
            }
        }
        
        return viewController
    }
}
