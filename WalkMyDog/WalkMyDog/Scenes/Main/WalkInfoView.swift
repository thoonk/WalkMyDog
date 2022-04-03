//
//  WalkInfoView.swift
//  WalkMyDog
//
//  Created by thoonk on 2022/03/26.
//

import SnapKit
import UIKit

final class WalkInfoView: UIStackView {
    lazy var walkFormLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "NanumSquareRoundR", size: 8.0)
        label.textColor = UIColor(hex: "666666")
        label.text = "앙꼬와\n내가 달린 거리"
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    lazy var walkResultLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "NanumSquareRoundB", size: 10.0)
        label.textColor = .black
        label.text = "총 10km\n평균 2.5km"
        label.textAlignment = .center
        label.numberOfLines = 2
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
    
    func setupLayout() {
        addArrangedSubview(walkFormLabel)
        addArrangedSubview(walkResultLabel)
        
        axis = .vertical
        alignment = .fill
        distribution = .fillEqually
        spacing = 5.0
        
        layer.borderWidth = 0.5
        layer.borderColor = UIColor(hex: "C4C4C4").cgColor
        roundCorners(.allCorners, radius: 15.0)
        
        layoutMargins = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        isLayoutMarginsRelativeArrangement = true
    }
}
