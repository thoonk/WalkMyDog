//
//  MKMapView+.swift
//  WalkMyDog
//
//  Created by thoonk on 2022/03/13.
//

import MapKit
import CoreLocation

extension MKMapView {
    func centerToLocation(
        _ location: CLLocationCoordinate2D,
        regionRadius: CLLocationDistance = 500
    ) {
        let region = MKCoordinateRegion(
            center: location,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius
        )
        setRegion(region, animated: true)
    }
}
