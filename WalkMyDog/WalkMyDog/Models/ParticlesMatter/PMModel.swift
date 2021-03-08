//
//  PMModel.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/16.
//

import Foundation

struct PMModel {
    let dateTime: String
    let pm10: Double
    let pm25: Double

    var pm10Status: String {
        switch pm10 {
        case 0...30.99:
            return "happy-48"
        case 31...50.99:
            return "cool-48"
        case 51...100.99:
            return "sad-48"
        case 101...:
            return "angry-48"
        default:
            return "puzzled-50"
        }
    }
    
    var pm25Status: String {
        switch pm25 {
        case 0...15.99:
            return "happy-48"
        case 16...25.99:
            return "cool-48"
        case 26...50.99:
            return "sad-48"
        case 51...:
            return "angry-48"
        default:
            return "puzzled-50"
        }
    }
}
