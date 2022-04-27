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
    @Persisted(primaryKey: true) var id: Int
    @Persisted var name: String = ""
    @Persisted var age: String = Date().toLocalized(with: "KST", by: "short")
    @Persisted var weight: Double = 0.0
    @Persisted var gender: Bool = false
    @Persisted var species: String = ""
    @Persisted var imageURL: String?
    @Persisted var records = List<Record>()
    
    var genderText: String {
        return gender ? "남아" : "여아"
    }
    
    convenience init(
        id: Int,
        name: String,
        age: String,
        gender: Bool,
        weight: Double,
        species: String,
        imageURL: String? = nil
    ) {
        self.init()
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
    @Persisted(primaryKey: true) var id: Int
    @Persisted var timeStamp: Date = Date()
    @Persisted var distance: Double = 0.0
    @Persisted var interval: Int = 0
    @Persisted var calories: Double = 0.0
    @Persisted var startLocation: Location?
    @Persisted var endLocation: Location?
    @Persisted var fecesLocation = List<Location>()
    @Persisted var peeLocation = List<Location>()
    @Persisted var puppy: Puppy?
    
    convenience init(
        id: Int,
        puppy: Puppy,
        timeStamp: Date,
        interval: Int,
        distance: Double,
        calories: Double,
        startLocation: Location,
        endLocation: Location,
        fecesLocation: [Location]? = nil,
        peeLocation: [Location]? = nil
    ) {
        self.init()
        self.id = id
        self.puppy = puppy
        self.timeStamp = timeStamp
        self.interval = interval
        self.distance = distance
        self.calories = calories
        self.startLocation = startLocation
        self.endLocation = endLocation
        self.fecesLocation.append(objectsIn: fecesLocation ?? [])
        self.peeLocation.append(objectsIn: peeLocation ?? [])
    }
}

final class Location: Object {
    @objc dynamic var latitude: Double = 0.0
    @objc dynamic var longitude: Double = 0.0

    var clLocation: CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    convenience init(clLocation: CLLocation) {
        self.init()
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
