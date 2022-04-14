//
//  PuppyModel.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/05.
//  

import Foundation
import RealmSwift
import CoreLocation

protocol Identifiable {
    var id: String? { get set }
}

/// 반려견의 정보 모델
final class Puppy: Object {
    dynamic var id: Int
    dynamic var name: String
    dynamic var age: String // 2016.12.11
    dynamic var weight: Double
    dynamic var gender: Bool
    dynamic var species: String
    dynamic var imageURL: String?
    
    var genderText: String {
        return gender ? "남아" : "여아"
    }
    
    init(
        id: Int = 0,
        name: String,
        age: String,
        gender: Bool,
        weight: Double,
        species: String,
        imageURL: String? = nil
    ) {
        self.id = id
        self.name = name
        self.age = age
        self.gender = gender
        self.weight = weight
        self.species = species
        self.imageURL = imageURL
    }
}

/// 반려견의 산책 기록 모델
final class Record: Object {
    dynamic var id: Int = 0
    dynamic var timeStamp: Date = Date()
    dynamic var distance: Double = 0.0
    dynamic var interval: Int = 0
    dynamic var calories: Double = 0.0
    dynamic var startLocation: Location?
    dynamic var endLocation: Location?
    dynamic var fecesLocation: [Location]?
    dynamic var peeLocation: [Location]?
    
    init(
        id: Int = 0,
        timeStamp: Date,
        interval: Int,
        distance: Double,
        calories: Double,
        startLocation: Location,
        endLocation: Location,
        fecesLocation: [Location]? = [],
        peeLocation: [Location]? = []
    ) {
        self.id = id
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

final class Location: Object {
    dynamic var latitude: Double = 0.0
    dynamic var longitude: Double = 0.0
    
    var clLocation: CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    init(clLocation: CLLocation) {
        self.latitude = clLocation.coordinate.latitude
        self.longitude = clLocation.coordinate.longitude
    }
}

///
//struct Puppy: Codable, Identifiable {
//    var id: String? = nil
//    var name: String
//    var age: String
//    var gender: Bool
//    var weight: Double
//    var species: String
//    var imageUrl: String?
//
//    var genderText: String {
//        return gender ? "남아" : "여아"
//    }
//
//    init(
//        name: String,
//        age: String,
//        gender: Bool,
//        weight: Double,
//        species: String
//    ) {
//        self.name = name
//        self.age = age
//        self.gender = gender
//        self.weight = weight
//        self.species = species
//    }
//}
//
//typealias Coordinate = (latitude: Double, longitude: Double)
//
///
//struct Record {
//    var id: String? = nil
//    let timeStamp: Date
//    let interval: Int
//    let distance: Double
//    let calories: Double
//    var startLocation: Coordinate
//    var endLocation: Coordinate
//    var fecesLocation: [Coordinate]?
//    var peeLocation: [Coordinate]?
//
//    init(
//        timeStamp: Date,
//        interval: Int,
//        distance: Double,
//        calories: Double,
//        startLocation: Coordinate,
//        endLocation: Coordinate,
//        fecesLocation: [Coordinate]? = nil,
//        peeLocation: [Coordinate]? = nil
//    ) {
//        self.timeStamp = timeStamp
//        self.interval = interval
//        self.distance = distance
//        self.calories = calories
//        self.startLocation = startLocation
//        self.endLocation = endLocation
//        self.fecesLocation = fecesLocation
//        self.peeLocation = peeLocation
//    }
//}
