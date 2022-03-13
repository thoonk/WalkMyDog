//
//  String.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/03/09.
//

import Foundation

extension String {
    /// String 값을 원하는 형식의 Date로 변경하는 함수
    func toDate() -> Date {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy-MM-dd"
        
        // self -> 2021년 4월 6일 화요일 10:36
        let dateSplit = self.split(separator: " ").map { String($0) }
        var year = dateSplit[0]
        var month = dateSplit[1]
        var day = dateSplit[2]
        
        year.remove(at: year.index(before: year.endIndex))
        month.remove(at: month.index(before: month.endIndex))
        day.remove(at: day.index(before: day.endIndex))
        
        let dateString = "\(year)-\(month)-\(day)"
        return formatter.date(from: dateString)!
    }
}
