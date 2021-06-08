//
//  WeatherData.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/16.
//

import Foundation

/// 날씨 예보 모델
struct WeatherFcstData: Codable {
    var timezone: String // "Asia/Seoul"
    var daily: [Daily]
}

/// 현재 날씨 모델
struct WeatherCurrentData: Codable {
    var main: Main
    var weather: [Weather]
}

/// 매일의 날씨 예보 모델
struct Daily: Codable {
    var dt: TimeInterval
    var temp: Temp
    var weather: [Weather]
}

/// 매일의 최저, 최고 온도 모델
struct Temp: Codable {
    var min: Double
    var max: Double
}

/// 날씨 모델
struct Weather: Codable {
    var id: Int // Weather condition id
    var description: String // Weather condition
}

/// 현재 날씨의 기온 모델
struct Main: Codable {
    var temp: Double
}
