//
//  WalkPuppyCollectionViewCell.swift
//  WalkMyDog
//
//  Created by thoonk on 2022/06/30.
//

import UIKit
import SnapKit

final class WalkPuppyCollectionViewCell: UICollectionViewCell {
    static let identifier = "WalkPuppyCollectionViewCell"
    
    lazy var puppyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupLayout()
        setupAttribute()
    }
    
    func bind(data: Puppy) {
        if let urlString = data.imageURL,
           let url = URL(string: urlString) {
            self.puppyImageView.kf.setImage(with: url)
        } else {
            self.puppyImageView.image = UIImage(named: "dog-48")
        }
    }
}

private extension WalkPuppyCollectionViewCell {
    func setupLayout() {
        self.addSubview(puppyImageView)
        
        puppyImageView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(10.0)
        }
    }
    
    func setupAttribute() {
        self.puppyImageView.layer.cornerRadius = puppyImageView.bounds.height / 2
    }
}
