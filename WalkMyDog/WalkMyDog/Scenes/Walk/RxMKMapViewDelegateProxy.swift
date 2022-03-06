//
//  RxMKMapViewDelegateProxy.swift
//  WalkMyDog
//
//  Created by thoonk on 2022/03/06.
//

import MapKit
import RxSwift
import RxCocoa

extension MKMapView: HasDelegate {
    public typealias Delegate = MKMapViewDelegate
}

final class RxMKMapViewDelegateProxy: DelegateProxy<MKMapView, MKMapViewDelegate>, DelegateProxyType, MKMapViewDelegate {
        
    weak private(set) var mapView: MKMapView?
    
    init(mapView: ParentObject) {
        self.mapView = mapView
        super.init(parentObject: mapView, delegateProxy: RxMKMapViewDelegateProxy.self)
    }
    
    static func registerKnownImplementations() {
        self.register { RxMKMapViewDelegateProxy(mapView: $0) }
    }
}
