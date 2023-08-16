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
        return viewController
    }
}
