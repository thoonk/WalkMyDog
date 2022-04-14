//
//  RecordRealmService.swift
//  WalkMyDog
//
//  Created by thoonk on 2022/04/14.
//

import Foundation

protocol RecordRealmServiceProtocol {
    func insert(
        timeStamp: Date,
        interval: Int,
        distance: Double,
        calories: Double,
        startLocation: Location,
        endLocation: Location,
        fecesLocation: [Location]?,
        peeLocation: [Location]?
    ) -> Bool
    func fetchRecords() -> [Record]?
    func remove(with record: Record) -> Bool
}

final class RecordRealmService: RealmService<Record>, RecordRealmServiceProtocol {
    func insert(
        timeStamp: Date,
        interval: Int,
        distance: Double,
        calories: Double,
        startLocation: Location,
        endLocation: Location,
        fecesLocation: [Location]? = nil,
        peeLocation: [Location]? = nil
    ) -> Bool {
        do {
            if let id = try increamentID(Record.self) {
                let record = Record(
                    id: id,
                    timeStamp: timeStamp,
                    interval: interval,
                    distance: distance,
                    calories: calories,
                    startLocation: startLocation,
                    endLocation: endLocation,
                    fecesLocation: fecesLocation,
                    peeLocation: peeLocation
                )
                
                try saveObject(record)
                return true
            }
            return false
        } catch {
            return false
        }
    }
    
    func fetchRecords() -> [Record]? {
        guard let records = fetchObjects(Record.self) as? [Record] else {
            return nil
        }
        return records
    }
    
    func remove(with record: Record) -> Bool {
        do {
            try removeObject(record)
            return true
        } catch {
            return false
        }
    }
}
