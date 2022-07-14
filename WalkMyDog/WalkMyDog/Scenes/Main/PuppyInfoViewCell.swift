//
//  PuppyInfoViewCell.swift
//  WalkMyDog
//
//  Created by thoonk on 2022/03/21.
//

import Foundation
import UIKit
import RxSwift
 
final class PuppyInfoViewCell: UITableViewCell {
    static let identifier = "PuppyInfoViewCell"
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.sizeToFit()
        label.text = "앙꼬"
        
        return label
    }()
    
    lazy var birthImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "cake")
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    lazy var birthDateLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: "C4C4C4")
        label.font = UIFont.systemFont(ofSize: 12)
        label.sizeToFit()
        label.text = "2016.12.11"
        
        return label
    }()
    
    lazy var sexAndWeightLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: "D45F97")
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
    
    lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPage = 0
        pageControl.preferredIndicatorImage = UIImage(named: "inactivePageControl")
        pageControl.backgroundStyle = .automatic
        pageControl.currentPageIndicatorTintColor = UIColor(hex: "666666")
        
        return pageControl
    }()
    
    lazy var detailButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(named: "customTintColor")
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitle("더보기", for: .normal)
        button.tintColor = .white
        button.roundCorners(.allCorners, radius: 15.0)
        
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with puppy: Puppy) {
        nameLabel.text = puppy.name
        birthDateLabel.text = puppy.age
        sexAndWeightLabel.text = "\(puppy.genderText) / \(puppy.weight)kg"
        puppyAgeLabel.text = Date().computeAge(with: puppy.age)
        personAgeLabel.text = Date().computePersonAge(with: puppy.age)
        
//        pageControl.rx.controlEvent(.valueChanged)
//            .subscribe(onNext: { [weak self] in
//                guard let
//            })
    }
    
    func updatePageControlUI(currentPageIndex: Int) {
        (0..<pageControl.numberOfPages).forEach { index in
            let activePageImage = UIImage(named: "activePageControl")
            let inactivePageImage = UIImage(named: "inactivePageControl")
            let pageImage = index == currentPageIndex ? activePageImage : inactivePageImage
            pageControl.setIndicatorImage(pageImage, forPage: index)
        }
    }
}

private extension PuppyInfoViewCell {
    func setupLayout() {
        self.backgroundColor = .white
        
        let birthStackView = UIStackView(arrangedSubviews: [birthImageView, birthDateLabel])
        birthStackView.spacing = 5.0
        birthStackView.alignment = .leading
        birthStackView.distribution = .fillProportionally
        
        birthImageView.snp.makeConstraints {
            $0.width.height.equalTo(20)
        }
        
        let puppyAgeStackView = UIStackView(arrangedSubviews: [puppyAgeFormLabel, puppyAgeLabel])
        puppyAgeStackView.spacing = 5.0
        puppyAgeStackView.alignment = .leading
        puppyAgeStackView.distribution = .fillEqually 
        
        let personAgeStackView = UIStackView(arrangedSubviews: [personAgeFormLabel, personAgeLabel])
        personAgeStackView.spacing = 5.0
        personAgeStackView.alignment = .leading
        personAgeStackView.distribution = .fillEqually
        
        let ageStackView = UIStackView(arrangedSubviews: [puppyAgeStackView, personAgeStackView])
        ageStackView.axis = .vertical
        ageStackView.alignment = .fill
        ageStackView.distribution = .fillEqually
        
        [
            nameLabel,
            birthStackView,
            sexAndWeightLabel,
            ageStackView,
            pageControl,
            detailButton
        ]
            .forEach { contentView.addSubview($0) }
        
        nameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20.0)
            $0.leading.equalToSuperview().inset(20.0)
        }
        
        pageControl.snp.makeConstraints {
            $0.top.equalToSuperview().inset(15.0)
            $0.trailing.equalToSuperview().inset(10.0)
            $0.leading.greaterThanOrEqualTo(nameLabel.snp.trailing).offset(20.0)
        }
        
        birthStackView.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(10)
            $0.leading.equalTo(nameLabel.snp.leading)
            $0.width.greaterThanOrEqualTo(100.0)
            $0.height.greaterThanOrEqualTo(20.0)
        }
        
        sexAndWeightLabel.snp.makeConstraints {
            $0.top.equalTo(pageControl.snp.bottom).offset(15.0)
            $0.trailing.equalToSuperview().inset(20.0)
        }
        
        ageStackView.snp.makeConstraints {
            $0.top.equalTo(birthStackView.snp.bottom).offset(10.0)
            $0.leading.equalTo(birthStackView)
            $0.bottom.equalToSuperview().inset(10.0)
        }
        
        detailButton.snp.makeConstraints {
            $0.top.equalTo(sexAndWeightLabel.snp.bottom).offset(10.0)
            $0.trailing.equalTo(sexAndWeightLabel)
            $0.bottom.equalToSuperview().inset(10.0)
            $0.width.equalTo(70.0)
            $0.height.equalTo(45.0)
        }
    }
}
