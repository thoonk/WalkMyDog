//
//  PMData.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/16.
//

import Foundation

// 미세먼지 모델
struct PMData: Codable {
    var list: [List]
}

// 미세먼지 리스트
struct List: Codable {
    var dt: TimeInterval // UTC
    var components: Components
}

// 미세먼지 측정치 모델
struct Components: Codable {
    var pm25: Double // 초미세먼지 수치
    var pm10: Double // 미세먼지 수치
    
    private enum CodingKeys: String, CodingKey {
        case pm25 = "pm2_5"
        case pm10
    }
}

