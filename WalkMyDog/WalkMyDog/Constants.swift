//
//  Constants.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/16.
//

import Foundation

struct C {
    static let apiKey = "APIKey"
    static let baseUrl = "https://api.openweathermap.org/data/2.5"
    
    struct Cell {
        static let weather = "weatherCell"
        static let puppy = "puppyCell"
        static let profile = "puppyProfileCell"
        static let record = "recordCell"
        static let check = "checkPuppyCell"
    }
    
    struct Segue {
        static let homeToSetting = "fromHomeToSetting"
        static let settingToEdit = "fromSettingToEdit"
        static let homeToRecord = "fromHomeToRecord"
        static let recordToEdit = "fromRecordToEdit"
        static let checkToEdit = "fromCheckToEdit"
    }
}
 
