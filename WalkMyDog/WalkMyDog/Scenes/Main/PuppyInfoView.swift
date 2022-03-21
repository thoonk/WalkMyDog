//
//  PuppyInfoView.swift
//  WalkMyDog
//
//  Created by thoonk on 2022/03/21.
//

import Foundation
import UIKit
 
final class PuppyInfoView: UIView {
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 15)
        label.sizeToFit()
        label.text = "앙꼬"
        
        return label
    }()
    
    lazy var birthDateLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: "#C4C4C4")
        label.font = UIFont.systemFont(ofSize: 12)
        label.sizeToFit()
        label.text = "2016.12.11"
        
        return label
    }()
    
    lazy var sexAndWeightLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: "#D45F97")
        label.font = UIFont.systemFont(ofSize: 12)
        label.sizeToFit()
        label.text = "여아 / 10.2kg"
        
        return label
    }()
    
    lazy var puppyAgeFormLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: "666666")
        label.font = UIFont.systemFont(ofSize: 12)
        label.sizeToFit()
        label.text = "강아지 나이"
        
        return label
    }()
    
    lazy var personAgeFormLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: "666666")
        label.font = UIFont.systemFont(ofSize: 12)
        label.sizeToFit()
        label.text = "사람 나이"
        
        return label
    }()
    
    lazy var puppyAgeLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "customTintColor")
        label.font = UIFont.systemFont(ofSize: 12)
        label.sizeToFit()
        label.text = "2년 8개월"
        
        return label
    }()
    
    lazy var personAgeLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "customTintColor")
        label.font = UIFont.systemFont(ofSize: 12)
        label.sizeToFit()
        label.text = "25살"
        
        return label
    }()
    
    lazy var detailButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = UIColor(named: "customTintColor")
        button.titleLabel?.textColor = .white
        button.setTitle("더 보기", for: .normal)
        
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLayout() {
        
    }
}
