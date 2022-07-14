//
//  UIScrollView+.swift
//  WalkMyDog
//
//  Created by thoonk on 2022/05/12.
//

import UIKit
import RxSwift
import RxCocoa

extension UIScrollView {
    var currentPage: Int {
        let pageWidth = self.frame.width
        let page = floor((self.contentOffset.x - pageWidth / 2) / pageWidth) + 1
        return Int(page)
    }
}

extension Reactive where Base: UIScrollView {
    var currentPage: Observable<Int> {
        return didEndDecelerating.map({
            let pageWidth = self.base.frame.width
            let page = floor((self.base.contentOffset.x - pageWidth / 2) / pageWidth) + 1
            return Int(page)
        })
    }
}
