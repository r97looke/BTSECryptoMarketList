//
//  CryptoMarketPriceViewController.swift
//  CryptoMarketPriceApp
//
//  Created by Shun Lung Chen on 2023/8/16.
//

import UIKit
import SnapKit

final class CryptoMarketPriceViewController: UIViewController {
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let viewModel: CryptoMarketPriceViewModel
    
    init(viewModel: CryptoMarketPriceViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    private let segmentedControl = UISegmentedControl(items: ["Spots", "Future"])
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = .white
        
        view.addSubview(segmentedControl)
        segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            make.centerX.equalToSuperview()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.loadCryptoMarket()
    }
    

}
