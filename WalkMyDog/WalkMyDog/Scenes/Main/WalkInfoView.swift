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
        label.font = UIFont(name: "NanumSquareRoundR", size: 15.0)
        label.textColor = UIColor(hex: "666666")
        label.text = "앙꼬와\n내가 달린 거리"
        return label
    }()
    
    lazy var walkResultLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "NanumSquareRoundB", size: 15.0)
        label.text = "총 10km\n평균 2.5km"
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
    }
}
