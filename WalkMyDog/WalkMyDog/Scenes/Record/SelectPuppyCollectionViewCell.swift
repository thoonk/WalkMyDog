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

    lazy var puppyNameLabel: UILabel = {
        let label = UILabel()
        label.text = "앙꼬"
        
        return label
    }()
    
    lazy var puppyImageView: UIImageView = {
        let imageView = UIImageView()
        
        return imageView
    }()
    
    var bag = DisposeBag()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupLayout()
    }
    
    override func prepareForReuse() {
        bag = DisposeBag()
    }
    
    func bindData(with data: Puppy) {
        self.puppyNameLabel.text = data.name
        if let urlString = data.imageURL,
           let url = URL(string: urlString) {
            self.puppyImageView.kf.setImage(with: url)
        } else {
            self.puppyImageView.image = UIImage(named: "dog-48")
        }
    }
}

private extension SelectPuppyCollectionViewCell {
    func setupLayout() {
        let stackView = UIStackView(arrangedSubviews: [puppyImageView, puppyNameLabel])
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.alignment = .fill
        stackView.spacing = 5.0
        
        self.addSubview(stackView)
        
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(5.0)
            $0.centerX.centerY.equalToSuperview()
        }
    }
}
