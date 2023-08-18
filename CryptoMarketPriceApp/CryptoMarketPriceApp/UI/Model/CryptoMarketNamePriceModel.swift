//
//  CryptoMarketNamePriceModel.swift
//  CryptoMarketPriceApp
//
//  Created by Shun Lung Chen on 2023/8/16.
//

import Foundation

struct CryptoMarketNamePriceModel {
    let nameText: String
    let price: Double?
    
    var priceText: String {
        if let price = price {
            return "\(price)"
        }
        else {
            return "--"
        }
    }
}
