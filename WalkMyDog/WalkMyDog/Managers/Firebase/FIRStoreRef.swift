//
//  FIRStoreRef.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/17.
//

import Foundation
import FirebaseAuth

enum FIRStoreRef {
    case uid
    case user
    case puppies
    case record(puppyId: String)
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
        case .uid:
            return "\(uid)"
        case .user:
            return "users/\(uid)"
        case .puppies:
            return "users/\(uid)/puppies"
        case let .record(puppyId):
            return "users/\(uid)/puppies/\(puppyId)/record"
        }
    }
}
