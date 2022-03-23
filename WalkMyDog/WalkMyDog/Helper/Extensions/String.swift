//
//  String.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/03/09.
//

import UIKit

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
    
    func height(constrainedBy width: CGFloat, with font: UIFont) -> CGFloat {
           let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
           let boundingBox = self.boundingRect(
               with: constraintRect,
               options: .usesLineFragmentOrigin,
               attributes: [NSAttributedString.Key.font: font],
               context: nil
           )
           return boundingBox.height
       }
       
       func width(constrainedBy height: CGFloat, with font: UIFont) -> CGFloat {
           let constrainedRect = CGSize(width: .greatestFiniteMagnitude, height: height)
           let boundingBox = self.boundingRect(
               with: constrainedRect,
               options: .usesLineFragmentOrigin,
               attributes: [NSAttributedString.Key.font: font],
               context: nil
           )
           return boundingBox.width
       }
}
