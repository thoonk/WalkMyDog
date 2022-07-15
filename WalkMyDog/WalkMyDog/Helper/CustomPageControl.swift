//
//  CustomPageControl.swift
//  WalkMyDog
//
//  Created by thoonk on 2022/03/21.
//

import UIKit

final class CustomPageControl: UIPageControl {
    let activeImage = UIImage(named: "activePageControl")!.withRenderingMode(.alwaysOriginal)
    let inactiveImage = UIImage(named: "inactivePageControl")!.withRenderingMode(.alwaysOriginal)
    
    override var numberOfPages: Int {
        didSet {
            updateDots()
        }
    }
    
    override var currentPage: Int {
        didSet {
            updateDots()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
         
        configurePageControl()
    }
}

private extension CustomPageControl {
    func configurePageControl() {
        if #available(iOS 14.0, *) {
            for index in 0..<numberOfPages {
                let image = index == currentPage ? activeImage : inactiveImage
                setIndicatorImage(image, forPage: index)
            }

            pageIndicatorTintColor = .systemGray6
            currentPageIndicatorTintColor = UIColor(hex: "666666")
        } else {
            self.pageIndicatorTintColor = .clear
            self.currentPageIndicatorTintColor = .clear
            self.clipsToBounds = false
        }
    }

    func updateDots() {
        if #available(iOS 14.0, *) {
            configurePageControl()
        } else {
            for (index, subview) in subviews.enumerated() {
                let imageView: UIImageView
                if let existingImageview = getImageView(forSubview: subview) {
                    imageView = existingImageview
                } else {
                    imageView = UIImageView(image: inactiveImage)

                    imageView.center = subview.center
                    subview.addSubview(imageView)
                    subview.clipsToBounds = false
                }
                imageView.image = currentPage == index ? activeImage : inactiveImage
            }
        }

    }

    func getImageView(forSubview view: UIView) -> UIImageView? {
        if let imageView = view as? UIImageView {
            return imageView
        } else {
            let view = view.subviews.first { view -> Bool in
                return view is UIImageView
            } as? UIImageView

            return view
        }
    }
}
