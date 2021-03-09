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
            dateFormatter.dateFormat = "yyyy-M-d HH:mm"
        } else if dateFormat == "short" {
            dateFormatter.dateFormat = "yyyy-M-d"
        }
        dateFormatter.timeZone = TimeZone(identifier: id)
        return dateFormatter.string(from: self)
    }
    
    func computeAge(with date: String) -> Int {
        let year = date[date.startIndex..<date.index(date.startIndex, offsetBy: 4)]
        let now = Calendar.current.component(.year, from: self)
        return now - Int(year)!
    }
    
    func setDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 M월 d일"
        let dateString = dateFormatter.string(from: self)
        return dateString
    }
    
    func setDateTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 M월 d일 EEEE HH:mm"
        let dateString = dateFormatter.string(from: self)
        return dateString
    }
    
    func setDay() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        let dateString = dateFormatter.string(from: self)
        return dateString
    }
}

