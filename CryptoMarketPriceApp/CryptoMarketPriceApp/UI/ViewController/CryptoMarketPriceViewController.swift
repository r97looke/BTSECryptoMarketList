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
    
    init(viewModel: CryptoMarketPriceViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    private let DefaultSpace: CGFloat = 8.0
    private let DefaultMargin: CGFloat = 16.0
    
    private let segmentedControl = UISegmentedControl(items: ["Spots", "Future"])
    private let sortButton = UIButton()
    private let tableView = UITableView()
    private let loadingView = UIActivityIndicatorView(style: .large)
    private let emptyLabel = UILabel()
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = .white
        
        segmentedControl.backgroundColor = .lightGray
        segmentedControl.selectedSegmentTintColor = .white
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.black], for: .selected)
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.darkGray], for: .normal)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmentedControl)
        segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(DefaultMargin)
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
        }
        
        sortButton.backgroundColor = .lightGray
        sortButton.layer.cornerRadius = 8.0
        sortButton.layer.borderColor = UIColor.blue.cgColor
        sortButton.layer.borderWidth = 1.0
        sortButton.clipsToBounds = true
        sortButton.setTitleColor(.blue, for: .normal)
        sortButton.configuration = .bordered()
        sortButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sortButton)
        sortButton.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(DefaultSpace)
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
        }
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundView = nil
        tableView.backgroundColor = .white
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60.0
        tableView.allowsSelection = false
        tableView.allowsFocus = false
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(sortButton.snp.bottom).offset(DefaultSpace)
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
        
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.font = .boldSystemFont(ofSize: 24)
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = .red
        emptyLabel.numberOfLines = 0
        emptyLabel.text = "Can not get crypto market prices now. Please try again later!"
        emptyLabel.isHidden = true
        view.addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints { make in
            make.center.equalTo(tableView)
            make.leading.equalTo(tableView)
            make.trailing.equalTo(tableView)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.selectedTypeRelay.map { type in
            return type.rawValue
        }
        .bind(to: segmentedControl.rx.selectedSegmentIndex)
        .dispose()
        
        segmentedControl.rx.selectedSegmentIndex.map { raw in
            return CryptoMarketPriceViewModel.CryptoMarketType(rawValue: raw)!
        }
        .bind(to: viewModel.selectedTypeRelay)
        .disposed(by: disposeBag)
        
        viewModel.selectedSortMethodRelay.map { sortMethod in
            return sortMethod.displayText()
        }
        .bind(to: sortButton.rx.title(for: .normal))
        .dispose()
        
        sortButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.showSortByActionSheet()
        }).disposed(by: disposeBag)
        
        tableView.register(CryptoMarketNamePriceCell.self, forCellReuseIdentifier: "\(type(of: CryptoMarketNamePriceCell.self))")
        
        viewModel.isLoading.bind(to: loadingView.rx.isAnimating).disposed(by: disposeBag)
        viewModel.isLoading.filter { $0 }.bind(to: emptyLabel.rx.isHidden).disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(UIApplication.willResignActiveNotification).subscribe(onNext: { [weak self] _ in
            self?.viewModel.stopReceive()
        }).disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(UIApplication.didBecomeActiveNotification).subscribe(onNext: { [weak self] _ in
            self?.refresh()
        }).disposed(by: disposeBag)
    }
    
    @objc func refresh() {
        tableView.dataSource = nil
        tableView.delegate = nil
        
        let displayModelsDriver = viewModel.loadCryptoMarket()
        displayModelsDriver.drive(tableView.rx.items(cellIdentifier: "\(type(of: CryptoMarketNamePriceCell.self))", cellType: CryptoMarketNamePriceCell.self)) { (row, model, cell) in
            cell.model = model
        }.disposed(by: disposeBag)
        displayModelsDriver.map { !$0.isEmpty }.drive(emptyLabel.rx.isHidden).disposed(by: disposeBag)
    }
    
    private func showSortByActionSheet() {
        let alert = UIAlertController(title: "Sort By", message: nil, preferredStyle: .actionSheet)
        
        for sortMethod in CryptoMarketPriceViewModel.CryptoMarketSortMethod.allCases {
            let action = UIAlertAction(title: sortMethod.displayText(), style: .default) { _ in
                self.viewModel.selectedSortMethodRelay.accept(sortMethod)
                self.sortButton.rx.title(for: .normal).onNext(sortMethod.displayText())
            }
            alert.addAction(action)
        }
        
        present(alert, animated: true)
    }
}
