//
//  CryptoMarketNamePriceCell.swift
//  CryptoMarketPriceApp
//
//  Created by Shun Lung Chen on 2023/8/16.
//

import UIKit

class CryptoMarketNamePriceCell: UITableViewCell {
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var model: CryptoMarketNamePriceModel? {
        didSet {
            nameLabel.text = model?.nameText
            priceLabel.text = model?.priceText
        }
    }
    
    private let DefaultSpace: CGFloat = 8.0
    
    private let nameLabel = UILabel()
    private let priceLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    private func setupView() {
        contentView.layer.cornerRadius = 8.0
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .boldSystemFont(ofSize: 20)
        nameLabel.lineBreakMode = .byTruncatingTail
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(DefaultSpace)
            make.leading.equalToSuperview().offset(DefaultSpace)
            make.trailing.equalTo(contentView.snp.centerX).offset(-DefaultSpace)
            make.bottom.equalToSuperview().offset(-DefaultSpace)
        }
        
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.font = .boldSystemFont(ofSize: 20)
        priceLabel.textAlignment = .right
        priceLabel.lineBreakMode = .byTruncatingTail
        contentView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-DefaultSpace)
            make.centerY.equalToSuperview()
            make.leading.equalTo(contentView.snp.centerX).offset(DefaultSpace)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        model = nil
    }

}
