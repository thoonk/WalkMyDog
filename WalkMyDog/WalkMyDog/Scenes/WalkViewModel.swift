//
//  WalkViewModel.swift
//  WalkMyDog
//
//  Created by thoonk on 2022/02/28.
//

import Foundation
import RxSwift
import CoreLocation
import RxRelay
import GoogleMaps

final class WalkViewModel: ViewModelType {
    var bag: DisposeBag = DisposeBag()
    
    var input: Input
    var output = Output()
    
    struct Input {
        let location: ReplaySubject<CLLocation>
    }
    
    struct Output {
        let location = PublishRelay<CLLocation>()
    }
    
    init() {
        let locationManager = LocationManager.shared
        
        input = Input(
            location: locationManager.location
        )
        
        input.location
            .debug()
            .delay(.seconds(1), scheduler: MainScheduler.instance)
            
//            .flatMapLatest { location -> Observable<CLLocation> in Observable.just(input.location) }
            .subscribe(onNext: { [weak self] loc in
                self?.output.location.accept(loc)
            })
            .disposed(by: bag)
        
        
//        input.location
//            .debug()
//            .flatMapLatest { location -> Observable<GMSCameraPosition> in
//                Observable.of(
//                GMSCameraPosition(
//                    latitude: location.coordinate.latitude,
//                    longitude: location.coordinate.latitude,
//                    zoom: 15.0
//                ))
//            }
//            .subscribe(onNext: { [weak self] pos in
//                self?.output.cameraPosition.accept(pos)
//            })
//            .disposed(by: bag)
        
    }
}
