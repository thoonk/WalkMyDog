//
//  UIView.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/03/30.
//

import UIKit

extension UIView {
    /// 커스텀 뷰 설정하는 함수
    func setShadowLayer() {
//        self.layer.cornerRadius = 12
        self.clipsToBounds = true
        self.layer.masksToBounds = false
        self.layer.shadowRadius = 6
        self.layer.shadowOpacity = 0.6
        self.layer.shadowOffset = CGSize(width: 3, height: 3)
        self.layer.shadowColor = UIColor.black.cgColor
    }
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        if #available(iOS 11.0, *) {
            clipsToBounds = true
            layer.cornerRadius = radius
            layer.maskedCorners = CACornerMask(rawValue: corners.rawValue)
        } else {
            let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners,
                                    cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            layer.mask = mask
        }
    }
    
    /// AutoLayout 설정하는 함수
    func setAnchor(top: NSLayoutYAxisAnchor?,
                   leading: NSLayoutXAxisAnchor?,
                   bottom: NSLayoutYAxisAnchor?,
                   trailing: NSLayoutXAxisAnchor?,
                   padding: UIEdgeInsets = .zero,
                   size: CGSize = .zero
    ) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if top != nil {
            topAnchor.constraint(equalTo: top!, constant: padding.top).isActive = true
        }
        
        if leading != nil {
            leadingAnchor.constraint(equalTo: leading!, constant: padding.left).isActive = true
        }
        
        if bottom != nil {
            bottomAnchor.constraint(equalTo: bottom!, constant: -padding.bottom).isActive = true
        }
        
        if trailing != nil {
            trailingAnchor.constraint(equalTo: trailing!, constant: -padding.right).isActive = true
        }
        
        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        
        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }
}
