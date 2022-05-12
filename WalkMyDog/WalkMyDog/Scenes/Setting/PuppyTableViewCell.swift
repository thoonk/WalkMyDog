//
//  PuppyTableViewCell.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/21.
//

import UIKit
import SnapKit

class PuppyTableViewCell: UITableViewCell {
    static let identifier = "PuppyTableViewCell"

    lazy var puppyNameLabel: UILabel = {
       let label = UILabel()
        label.text = "반려견 이름"
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        self.accessoryType = .disclosureIndicator
    }
    
    func setupLayout() {
        contentView.addSubview(puppyNameLabel)
        
        puppyNameLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20.0)
            $0.trailing.greaterThanOrEqualToSuperview().inset(10.0)
            $0.centerY.equalToSuperview()
        }
    }
    
    func bindData(with data: Puppy) {
        puppyNameLabel.text = data.name
    }
}
