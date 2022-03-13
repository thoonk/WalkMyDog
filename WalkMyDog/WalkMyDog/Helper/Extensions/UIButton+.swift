//
//  UIButton+.swift
//  WalkMyDog
//
//  Created by thoonk on 2022/03/06.
//

import UIKit

extension UIButton {
    func setImage(systemName: String, size: CGFloat) {
        contentHorizontalAlignment = .fill
        contentVerticalAlignment = .fill
        
        imageView?.contentMode = .scaleAspectFill
        
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.plain()
            config.contentInsets = .zero
            config.image = UIImage(systemName: systemName)
            config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: size)
            
            self.configuration = config
        } else {
            imageEdgeInsets = .zero
            setImage(UIImage(systemName: systemName), for: .normal)
            setPreferredSymbolConfiguration(.init(pointSize: size), forImageIn: .normal)
        }
    }
}

