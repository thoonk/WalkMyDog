//
//  Date.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/16.
//

import Foundation

extension Date {
    /// UTC인 시간을 지역화하는 함수
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
    
    /// 반려견의 생년월일을 이용해서 나이를 계산하는 함수
    func computeAge(with date: String) -> String {
        let dateArray = date.split(separator: ".").map { Int(String($0)) }
        let year = dateArray[0] ?? 0
        let month = dateArray[1] ?? 0
        let day = dateArray[2] ?? 0

//        let year = date[date.startIndex..<date.index(date.startIndex, offsetBy: 4)]
        
        let startComponents = Calendar.current.date(from: DateComponents(year: year, month: month, day: day))!
        let dateComponents = Calendar.current.dateComponents([.year, .month], from: startComponents, to: self)
        
        return "\(dateComponents.year ?? 0)년 \(dateComponents.month ?? 0)개월"
    }
    
    func computePersonAge(with date: String) -> String {
        let dateArray = date.split(separator: ".").map { Int(String($0)) }
        
        let year = dateArray[0] ?? 0
        let month = dateArray[1] ?? 0
        let day = dateArray[2] ?? 0
        let startComponents = Calendar.current.date(from: DateComponents(year: year, month: month, day: day))!

        let dateComponents = Calendar.current.dateComponents([.year], from: startComponents, to: self)
        
        // 16 x log10(puppyAge) + 31 = person age
        let personAge = 16 * log10(Double(dateComponents.year ?? 0)) + 31
        return "\(Int(personAge))살"
    }
    
    /// Date를 원하는 String 타입으로 변경하는 함수
    func setDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        let dateString = formatter.string(from: self)
        return dateString
    }
    
    /// Date를 원하는 String 타입으로 변경하는 함수(시간 단위까지)
    func setDateTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 M월 d일 EEEE HH:mm"
        let dateString = dateFormatter.string(from: self)
        return dateString
    }
    
    /// 산책 기록 정보의 합계, 평균을 구하기 위해 현재 달에 해당하는 날짜를 선별하는 함수
    func isEqual(to date: Date) -> Bool {
        let calendar = Calendar.current
        let component1 = calendar.dateComponents([.year, .month, .day], from: self)
        let component2 = calendar.dateComponents([.year, .month, .day], from: date)
        
        return component1 == component2 ? true : false
    }
}

