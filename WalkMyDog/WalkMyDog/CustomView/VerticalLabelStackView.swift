//
//  VerticalLabelStackView.swift
//  WalkMyDog
//
//  Created by thoonk on 2022/08/21.
//

import SnapKit
import UIKit

final class VerticalLabelStackView: UIStackView {
    lazy var formLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "NanumSquareRoundR", size: 15.0)
        label.textColor = UIColor(hex: "666666")
        label.textAlignment = .center
        label.numberOfLines = 1
        label.sizeToFit()
        
        return label
    }()
    
    lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "NanumSquareRoundB", size: 20.0)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 1
        label.sizeToFit()
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
    }
    
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with formText: String, valueText: String) {
        self.formLabel.text = formText
        self.valueLabel.text = valueText
    }
    
    func setupLayout() {
        addArrangedSubview(formLabel)
        addArrangedSubview(valueLabel)
        
        axis = .vertical
        alignment = .fill
        distribution = .fillEqually
        spacing = 5.0
        
        layoutMargins = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        isLayoutMarginsRelativeArrangement = true
    }
}
