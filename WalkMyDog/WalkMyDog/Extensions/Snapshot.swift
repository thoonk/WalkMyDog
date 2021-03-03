//
//  Snapshot.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/18.
//

import Foundation
import FirebaseFirestore

enum SnapshotError: Error {
    case decodingError
}

extension DocumentSnapshot {
    
    func decode<T: Decodable>(as objectType: T.Type, includingId: Bool = true) throws -> T {
        
        guard var documentJson = data() else { throw SnapshotError.decodingError }
        if includingId {
            documentJson["id"] = documentID
        }
        
        let documentData = try JSONSerialization.data(withJSONObject: documentJson, options: [])
        let decodedObject = try JSONDecoder().decode(objectType, from: documentData)
        return decodedObject
    }
}
