//
//  SettingTableViewCell.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/04/01.
//

import UIKit
import SnapKit

class SettingTableViewCell: UITableViewCell {
    static let identifier = "SettingTableViewCell"
    
    lazy var titleLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont(name: "NanumSquareRoundR", size: 17.0) ?? UIFont.systemFont(ofSize: 17.0)

        return label
    }()
    
    lazy var subTitleLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont(name: "NanumSquareRoundR", size: 17.0) ?? UIFont.systemFont(ofSize: 17.0)

        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLayout() {
        [titleLabel, subTitleLabel].forEach { contentView.addSubview($0) }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20.0)
            $0.centerY.equalToSuperview()
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(10.0)
            $0.trailing.equalToSuperview().inset(20.0)
            $0.centerY.equalToSuperview()
        }
    }
    
    func bindData(title: String, subTitle: String) {
        titleLabel.text = title
        subTitleLabel.text =  UserDefaults.standard.string(forKey: "pmRcmdCriteria")
    }
}
