//
//  WeatherData.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/16.
//

import Foundation

struct WeatherFcstData: Codable {
    var timezone: String
    var daily: [Daily]
}

struct WeatherCurrentData: Codable {
    var main: Main
    var weather: [Weather]
}

struct Daily: Codable {
    var dt: TimeInterval
    var temp: Temp
    var weather: [Weather]
}

struct Temp: Codable {
    var min: Double
    var max: Double
}
    
struct Weather: Codable {
    var id: Int
    var description: String
}

struct Main: Codable {
    var temp: Double
}
