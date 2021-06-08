//
//  SelectSpeciesDelegate.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/03/19.
//

import Foundation

/// 반려견의 종 선택 후 선택한 객체를 전달하기 위한 프로토콜
protocol SelectSpeciesDelegate: AnyObject {
    func didSelectSpecies(with: String)
}
