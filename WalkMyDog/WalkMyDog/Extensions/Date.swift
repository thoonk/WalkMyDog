//
//  Date.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/16.
//

import Foundation

extension Date {
    func toLocalized(with id: String, by dateFormat: String) -> String {
        let formatter = DateFormatter()
        if dateFormat == "day" {
            formatter.dateFormat = "EEEE"
        } else if dateFormat == "normal" {
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
        } else if dateFormat == "short" {
            formatter.dateFormat = "yyyy-MM-dd"
        }
        formatter.timeZone = TimeZone(identifier: id)
        return formatter.string(from: self)
    }
    
    func computeAge(with date: String) -> Int {
        let year = date[date.startIndex..<date.index(date.startIndex, offsetBy: 4)]
        let now = Calendar.current.component(.year, from: self)
        return now - Int(year)!
    }
    
    func setDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일"
        let dateString = formatter.string(from: self)
        return dateString
    }
    
    func setDateTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 M월 d일 EEEE HH:mm"
        let dateString = dateFormatter.string(from: self)
        return dateString
    }
    
    func setDay() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        let dateString = formatter.string(from: self)
        return dateString
    }
    
    func isEqual(to date: Date) -> Bool {
        let calendar = Calendar.current
        let component1 = calendar.dateComponents([.year, .month], from: self)
        let component2 = calendar.dateComponents([.year, .month], from: date)
        
        return component1 == component2 ? true : false
    }
}

