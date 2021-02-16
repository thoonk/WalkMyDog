//
//  Model.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/05.
//  

import Foundation

struct User {
    let puppies: [Puppy]
}

struct Puppy {
    let name: String
    let age: Int
    let weight: Double
    let species: String
    let record: [Record]
}

struct Record {
    let timeStamp: Date
}
