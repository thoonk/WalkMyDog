//
//  LocationManager.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/16.
//

import Foundation
import RxCocoa
import RxSwift
import RxCoreLocation
import CoreLocation

class LocationManager {
    
    static let shared = LocationManager()
    
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        return manager
    }()
    
    private (set) var location = ReplaySubject<CLLocation>.createUnbounded()
    private (set) var placemark = ReplaySubject<CLPlacemark>.createUnbounded()  
    private (set) var authorizedStatus = PublishSubject<Bool>()

    private var bag = DisposeBag()
    
    private init() {
        locationManager.rx
            .didChangeAuthorization
            .subscribe(onNext: { [weak self] _, status in
                switch status {
                case .denied:
                    self?.authorizedStatus.onNext(false)
                case .notDetermined:
                    self?.locationManager.requestWhenInUseAuthorization()
                case .restricted:
                    self?.authorizedStatus.onNext(false)
                case .authorizedAlways, .authorizedWhenInUse:
                    self?.locationManager.startUpdatingLocation()
                    self?.authorizedStatus.onCompleted()
                @unknown default:
                    print("Dev Alert: Unknown case of status in handleAuth\(status)")
                }
            })
            .disposed(by: bag)
        
        locationManager.rx
            .placemark
            .subscribe(onNext: { [weak self] placemark in
                self?.placemark.onNext(placemark)
            })
            .disposed(by: bag)
        
        locationManager.rx
            .location
            .take(1)
            .subscribe(onNext: { [weak self] location in
                self?.locationManager.stopUpdatingLocation()
                guard let location = location else { return }
                print("latitude: \(location.coordinate.latitude)")
                print("longitude: \(location.coordinate.longitude)")
                self?.location.onNext(location)
                self?.location.onCompleted()
            })
            .disposed(by: bag)
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
}
