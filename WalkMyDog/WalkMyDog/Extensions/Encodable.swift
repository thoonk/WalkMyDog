//
//  Encodable.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/17.
//

import Foundation

enum FIRError: Error {
    case encodingError
}

extension Encodable {
    /// 객체를 json타입으로 인코딩하는 함수
    public func toJson(excluding keys: [String] = [String]()) throws -> [String: Any] {
        let objectData = try JSONEncoder().encode(self)
        let jsonObject = try JSONSerialization.jsonObject(with: objectData, options: [])
        guard var json = jsonObject as? [String: Any] else { throw FIRError.encodingError }
        
        /// id에 해당하는 프로퍼티의 값을 nil로 초기화
        for key in keys {
            json[key] = nil
        }
        
        return json
    }
}
