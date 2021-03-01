//
//  PuppyModel.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/05.
//  

import Foundation

struct Puppy: Codable {
    var id: Int
    var name: String
    var age: String
    var gender: Bool
    var weight: Double
    var species: String
    var imageUrl: String
}

struct Record: Codable {
    let timeStamp: Date
//    let walkInterval: Int
}
