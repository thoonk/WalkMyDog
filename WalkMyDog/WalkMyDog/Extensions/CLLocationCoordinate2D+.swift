//
//  CLLocationCoordinate2D+.swift
//  WalkMyDog
//
//  Created by thoonk on 2022/03/13.
//

import CoreLocation

extension CLLocationCoordinate2D {
    func isEqual(to coordinate: CLLocationCoordinate2D) -> Bool {
        if self.latitude != coordinate.latitude &&
            self.longitude != coordinate.longitude {
            return false
        }
        return true
    }
    
    var isDefaultCoordinate: Bool {
        if self.latitude == 0.0 &&
            self.longitude == 0.0 {
            return true
        }
        return false
    }
}
