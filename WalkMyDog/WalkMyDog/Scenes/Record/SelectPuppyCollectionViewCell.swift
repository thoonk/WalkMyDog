//
//  SelectPuppyCollectionViewCell.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/03/04.
//

import UIKit
import RxSwift
import SnapKit

final class SelectPuppyCollectionViewCell: UICollectionViewCell {
    static let identifier = "SelectPuppyCollectionViewCell"
    private var imageService: ImageServiceProtocol = ImageService()

    lazy var puppyNameLabel: UILabel = {
        let label = UILabel()
        label.text = "앙꼬"
        label.textColor = UIColor(hex: "666666")
        label.font = UIFont(name: "NanumSquareRoundR", size: 12)
        label.sizeToFit()
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        
        return label
    }()
    
    lazy var puppyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.layer.borderWidth = 3.5
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    var bag = DisposeBag()
    
    override var isSelected: Bool {
        didSet {
            guard oldValue != isSelected else { return }
            
            if isSelected {
                puppyImageView.layer.borderColor = UIColor(hex: "D45F97").cgColor
            } else {
                puppyImageView.layer.borderColor = UIColor.clear.cgColor
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupLayout()
        setupAttribute()
    }
    
    override func prepareForReuse() {
        bag = DisposeBag()
    } 
    
    func bindData(with data: Puppy) {
        self.puppyNameLabel.text = data.name
        
        if let urlString = data.imageURL,
           let image = imageService.loadImage(with: urlString) {
            self.puppyImageView.image = image
        } else {
            self.puppyImageView.image = UIImage(named: "dog-48")
        }
    }
}

private extension SelectPuppyCollectionViewCell {
    func setupLayout() {
        [puppyImageView, puppyNameLabel]
            .forEach { self.addSubview($0) }
        
        puppyImageView.snp.makeConstraints {
            $0.top.equalToSuperview()
//            $0.leading.trailing.equalToSuperview()//.inset(10.0)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(self.contentView.bounds.size.height * 0.7)
        }
        
        puppyNameLabel.snp.makeConstraints {
            $0.top.equalTo(puppyImageView.snp.bottom).offset(5.0)
            $0.leading.trailing.equalTo(puppyImageView)
            $0.bottom.equalToSuperview()
        }
    }
    
    func setupAttribute() {
        self.puppyImageView.layer.cornerRadius = puppyImageView.bounds.height / 2
    }
}
