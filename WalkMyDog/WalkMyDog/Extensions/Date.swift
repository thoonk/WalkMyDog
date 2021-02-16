//
//  Date.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/16.
//

import Foundation

extension Date {
    func toLocalized(with id: String, by dateFormat: String) -> String {
        let dateFormatter = DateFormatter()
        if dateFormat == "day" {
            dateFormatter.dateFormat = "EEEE"
        } else if dateFormat == "normal" {
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        } else if dateFormat == "short" {
            dateFormatter.dateFormat = "yyyy-MM-dd"
        }
        dateFormatter.timeZone = TimeZone(identifier: id)
        return dateFormatter.string(from: self)
    }
}

