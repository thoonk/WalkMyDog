//
//  UIImage.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/03/09.
//

import Foundation
import UIKit

extension UIImage {
    /// image를 원하는 사이즈로 조절하는 함수
    func resized(to newSize: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: newSize).image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
