//
//  CustomPageControl.swift
//  WalkMyDog
//
//  Created by thoonk on 2022/03/21.
//

import UIKit

final class CustomPageControl: UIPageControl {
    
    let activeImage: UIImage = UIImage(named: "activePageControl")!
    let inactiveImage: UIImage = UIImage(named: "inactivePageControl")!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.pageIndicatorTintColor = .clear
        self.currentPageIndicatorTintColor = .clear
        self.clipsToBounds = false
    }
    
    func updateDots() {
        var i = 0
        for view in self.subviews {
            if let imageView = self.imageForSubview(view) {
                if i == self.currentPage {
                    imageView.image = self.activeImage
                } else {
                    imageView.image = self.inactiveImage
                }
                i = i + 1
            } else {
                var dotImage = self.inactiveImage
                if i == self.currentPage {
                    dotImage = self.activeImage
                }
                view.clipsToBounds = false
                view.addSubview(UIImageView(image:dotImage))
                i = i + 1
            }
        }
    }
    
    private func imageForSubview(_ view:UIView) -> UIImageView? {
        var dot:UIImageView?
        
        if let dotImageView = view as? UIImageView {
            dot = dotImageView
        } else {
            for foundView in view.subviews {
                if let imageView = foundView as? UIImageView {
                    dot = imageView
                    break
                }
            }
        }
        
        return dot
    }
}
