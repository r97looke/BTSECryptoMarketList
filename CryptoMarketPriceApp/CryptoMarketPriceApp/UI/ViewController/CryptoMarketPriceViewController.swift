//
//  CryptoMarketPriceViewController.swift
//  CryptoMarketPriceApp
//
//  Created by Shun Lung Chen on 2023/8/16.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class CryptoMarketPriceViewController: UIViewController {
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let viewModel: CryptoMarketPriceViewModel
    private let disposeBag = DisposeBag()
    
    private var displayCryptoMarketNamePriceModels = [CryptoMarketNamePriceModel]()
    
    init(viewModel: CryptoMarketPriceViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    private let DefaultSpace: CGFloat = 8.0
    private let DefaultMargin: CGFloat = 16.0
    
    private let segmentedControl = UISegmentedControl(items: ["Spots", "Future"])
    private let tableView = UITableView()
    private let loadingView = UIActivityIndicatorView(style: .large)
    
    override func loadView() {
        super.loadView()
        
        let selectedCryptoMarketTypeObserver: Binder<CryptoMarketPriceViewModel.CryptoMarketType> = Binder(viewModel) { (viewModel, type) in
            viewModel.selectedCryptoMarketType = type
        }
        
        segmentedControl.rx.selectedSegmentIndex.asObservable().map { CryptoMarketPriceViewModel.CryptoMarketType(rawValue: $0) ?? .spot
        }.bind(to: selectedCryptoMarketTypeObserver).disposed(by: disposeBag)
        
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmentedControl)
        segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(DefaultMargin)
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
        }
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundView = nil
        tableView.backgroundColor = .clear
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60.0
        tableView.allowsSelection = false
        tableView.allowsFocus = false
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(DefaultSpace)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(DefaultMargin)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-DefaultMargin)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-DefaultMargin)
        }
        
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.color = .blue
        view.addSubview(loadingView)
        loadingView.snp.makeConstraints { make in
            make.center.equalTo(tableView)
            make.edges.equalTo(tableView)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        segmentedControl.selectedSegmentIndex = viewModel.selectedCryptoMarketType.rawValue
        
        tableView.register(CryptoMarketNamePriceCell.self, forCellReuseIdentifier: "\(type(of: CryptoMarketNamePriceCell.self))")
        
        tableView.dataSource = self
        
        viewModel.isLoading.bind(to: loadingView.rx.isAnimating).disposed(by: disposeBag)
        
        viewModel.displayCryptoMarketNamePriceModels.subscribe { [weak self] models in
            self?.displayCryptoMarketNamePriceModels = models
            self?.tableView.reloadData()
        }.disposed(by: disposeBag)
        
        viewModel.loadCryptoMarket()
    }
    
    @objc private func didChangeSegment() {
        viewModel.selectedCryptoMarketType = CryptoMarketPriceViewModel.CryptoMarketType(rawValue: segmentedControl.selectedSegmentIndex) ?? .spot
    }
}

// MARK: UITableViewDataSource
extension CryptoMarketPriceViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayCryptoMarketNamePriceModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = displayCryptoMarketNamePriceModels[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(type(of: CryptoMarketNamePriceCell.self))", for: indexPath) as! CryptoMarketNamePriceCell
        cell.model = model
        return cell
    }
}
