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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func prepareForReuse() {
        bag = DisposeBag()
    }
    
    func bindData(with data: Puppy) {
        self.puppyNameLabel.text = data.name
    }
}

private extension SelectPuppyCollectionViewCell {
    func setupLayout() {
        [puppyNameLabel, puppyImageView]
            .forEach { self.addSubview($0) }
        
        
    }
}
