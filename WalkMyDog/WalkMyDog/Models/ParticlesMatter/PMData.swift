//
//  PMData.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/16.
//

import Foundation

struct PMData: Codable {
    var list: [List]
}

struct List: Codable {
    var dt: TimeInterval
    var components: Components
}

struct Components: Codable {
    var pm25: Double
    var pm10: Double
    
    private enum CodingKeys: String, CodingKey {
        case pm25 = "pm2_5"
        case pm10
    }
}

