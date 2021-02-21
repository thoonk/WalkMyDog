//
//  Snapshot.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/18.
//

import Foundation
import FirebaseFirestore

extension DocumentSnapshot {
    
    func decode<T: Decodable>(as objectType: T.Type) throws -> T {
        
        let documentJson = data()
        let documentData = try JSONSerialization.data(withJSONObject: documentJson, options: [])
        let decodedObject = try JSONDecoder().decode(objectType, from: documentData)
        return decodedObject
    }
}
