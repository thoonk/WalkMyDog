//
//  FIRStoreRef.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/17.
//

import Foundation
import FirebaseAuth

enum FIRStoreRef {
    case user
    case puppies
    case puppy(puppyId: String)
    case records(puppyId: String)
    case record(puppyId: String, recordId: String)
}

extension FIRStoreRef {
    var uid: String {
        guard let currentUser = Auth.auth().currentUser else {
            return "Unknown User"
        }
        return currentUser.uid
    }
    
    var path: String {
        switch self {
        case .user:
            return "users/\(uid)"
        case .puppies:
            return "users/\(uid)/puppies"
        case let .puppy(id):
            return "users/\(uid)/puppies/\(id)"
        case let .records(puppyId):
            return "users/\(uid)/puppies/\(puppyId)/record"
        case let .record(puppyId, recordId):
            return "users/\(uid)/puppies/\(puppyId)/record/\(recordId)"
        }
    }
}
