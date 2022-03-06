//
//  MKMapView+Rx.swift
//  WalkMyDog
//
//  Created by thoonk on 2022/03/06.
//

import MapKit
import RxSwift
import RxCocoa

func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }
    return returnValue
}

extension Reactive where Base: MKMapView {
    var delegate: DelegateProxy<MKMapView, MKMapViewDelegate> {
        return RxMKMapViewDelegateProxy.proxy(for: base)
    }
    
    var regionDidChangeAnimated: ControlEvent<Bool> {
        let source = delegate
            .methodInvoked(#selector(MKMapViewDelegate.mapView(_:regionDidChangeAnimated:)))
            .map { a in
                return try castOrThrow(Bool.self, a[1])
            }
        return ControlEvent(events: source)
    }
    
    func setDelegate(_ delegate: MKMapViewDelegate) -> Disposable {
        return RxMKMapViewDelegateProxy.installForwardDelegate(
            delegate,
            retainDelegate: false,
            onProxyForObject: self.base
        )
    }
}
