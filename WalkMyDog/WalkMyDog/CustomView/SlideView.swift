//
//  SlideView.swift
//  WalkMyDog
//
//  Created by thoonk on 2022/03/23.
//

import Foundation
import UIKit

final class SlideView: UIView {
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.image = UIImage(named: "launchImage")
        
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        self.addSubview(profileImageView)
        
        profileImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
