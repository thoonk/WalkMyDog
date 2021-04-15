//
//  PMModel.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/16.
//
import Foundation

enum RCMDCriteria: Int {
    case none = -1
    case love = 0
    case happy = 1
    case bad = 2
    case worst = 3
}

struct PMModel {
    let dateTime: String
    let pm10: Double
    let pm25: Double

    var pm10Status: RCMDCriteria {
        switch pm10 {
        case 0...30.99:
            return RCMDCriteria.love
        case 31...50.99:
            return RCMDCriteria.happy
        case 51...100.99:
            return RCMDCriteria.bad
        case 101...:
            return RCMDCriteria.worst
        default:
            return RCMDCriteria.none
        }
    }
    
    var pm25Status: RCMDCriteria {
        switch pm25 {
        case 0...15.99:
            return RCMDCriteria.love
        case 16...25.99:
            return RCMDCriteria.happy
        case 26...50.99:
            return RCMDCriteria.bad
        case 51...:
            return RCMDCriteria.worst
        default:
            return RCMDCriteria.none
        }
    }
    
    var pmStatus: RCMDCriteria {
        if pm10Status.rawValue == pm25Status.rawValue {
            return pm10Status
        } else if pm10Status.rawValue > pm25Status.rawValue {
            return pm10Status
        } else {
            return pm25Status
        }
    }
    
    var rcmdStatus: String {
        switch pmStatus {
        case RCMDCriteria.love, RCMDCriteria.happy:
            return "산책을 나가기 좋은 날씨에요😆"
        case RCMDCriteria.bad:
            return "오늘은 웬만하면 나가지 마세요😔"
        case RCMDCriteria.worst:
            return "이불 밖은 위험해요😴"
        default:
            return "산책 추천이 비활성되어 있습니다."
        }
    }
        
    var rcmdImage: String {
        let rcmdCriteria = UserDefaults.standard.value(forKey: "pmRcmdCriteria") as! String
        switch pmStatus {
        case RCMDCriteria.love, RCMDCriteria.happy:
            return "check-mark-48"
        case RCMDCriteria.bad:
            if rcmdCriteria == "나쁨" {
                return "check-mark-48"
            } else {
                return ""
            }
        case RCMDCriteria.worst:
            return ""
        default:
            return ""
        }
    }

    var pm10Image: String {
        switch pm10 {
        case 0...30.99:
            return "love-48"
        case 31...50.99:
            return "happy-48"
        case 51...100.99:
            return "sad-48"
        case 101...:
            return "angry-48"
        default:
            return "puzzled-48"
        }
    }
    
    var pm25Image: String {
        switch pm25 {
        case 0...15.99:
            return "love-48"
        case 16...25.99:
            return "happy-48"
        case 26...50.99:
            return "sad-48"
        case 51...:
            return "angry-48"
        default:
            return "puzzled-48"
        }
    }
}
