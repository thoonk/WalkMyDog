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
    private var imageService: ImageServiceProtocol = ImageService()
    
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
           let image = imageService.loadImage(with: urlString) {
            puppyImageView.image = image
        } else {
            self.puppyImageView.image = UIImage(named: "dog-48")
        }
    }
}

private extension WalkPuppyCollectionViewCell {
    func setupLayout() {
        self.addSubview(puppyImageView)
        
        puppyImageView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(5.0)
        }
    }
    
    func setupAttribute() {
        self.puppyImageView.layer.cornerRadius = puppyImageView.bounds.height / 2
    }
}
