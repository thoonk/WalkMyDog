//
//  PuppyModel.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/05.
//  

import Foundation

protocol Identifiable {
    var id: String? { get set }
}

/// 반려견의 정보 모델
struct Puppy: Codable, Identifiable {
    var id: String? = nil
    var name: String
    var age: String
    var gender: Bool
    var weight: Double
    var species: String
    var imageUrl: String?
    
    var genderText: String {
        return gender ? "남아" : "여아"
    }
    
    init(
        name: String,
        age: String,
        gender: Bool,
        weight: Double,
        species: String
    ) {
        self.name = name
        self.age = age
        self.gender = gender
        self.weight = weight
        self.species = species
    }
}

typealias Coordinate = (latitude: Double, longitude: Double)

/// 반려견의 산책 기록 모델
struct Record {
    var id: String? = nil
    let timeStamp: Date
    let interval: Int
    let distance: Double
    let calories: Double
    var startLocation: Coordinate
    var endLocation: Coordinate
    var fecesLocation: [Coordinate]?
    var peeLocation: [Coordinate]?
    
    init(
        timeStamp: Date,
        interval: Int,
        distance: Double,
        calories: Double,
        startLocation: Coordinate,
        endLocation: Coordinate,
        fecesLocation: [Coordinate]? = nil,
        peeLocation: [Coordinate]? = nil
    ) {
        self.timeStamp = timeStamp
        self.interval = interval
        self.distance = distance
        self.calories = calories
        self.startLocation = startLocation
        self.endLocation = endLocation
        self.fecesLocation = fecesLocation
        self.peeLocation = peeLocation
    }
}
