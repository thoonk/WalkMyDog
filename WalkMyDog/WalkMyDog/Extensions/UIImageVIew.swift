//
//  UIImageVIew.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/03/13.
//

import Foundation
import UIKit
import Kingfisher

extension UIImageView {
    func setImage(with urlString: String) {
        let imageCache = ImageCache.default
        let image = imageCache.retrieveImageInMemoryCache(forKey: urlString)
        if image != nil {
            self.image = image
        } else {
            let url = URL(string: urlString)
            let imageResource = ImageResource(downloadURL: url!, cacheKey: urlString)
            self.kf.setImage(with: imageResource)
        }
    }
}
