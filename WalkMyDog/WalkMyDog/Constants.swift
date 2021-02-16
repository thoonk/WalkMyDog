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
        static let identifier = "weatherCell"
    }
    
    struct Segue {
        static let homeToSetting = "fromHomeToSetting"
    }
}
