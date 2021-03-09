//
//  String.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/03/09.
//

import Foundation

extension String {
    
    func toDate() -> Date {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy-MM-dd"
        
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
