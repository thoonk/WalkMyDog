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
        let myLocationButtonTapped = PublishSubject<(Void)>()
        let pausePlayButtonTapped = PublishSubject<(Void)>()
        let stopButtonTapped = PublishSubject<(Void)>()
        let cameraButtonTapped = PublishSubject<(Void)>()
        let fecesButtonTapped = PublishSubject<(Void)>()
    }
    
    struct Output {
        let location = PublishRelay<CLLocationCoordinate2D>()
        let annotationLocation = PublishRelay<CLLocationCoordinate2D>()
    }
    
    init() {
        let locationManager = LocationManager.shared
        
        input = Input(
            location: locationManager.location
        )
        
        input.myLocationButtonTapped
            .withLatestFrom(input.location)
            .subscribe(onNext: { [weak self] loc in
                self?.output.location.accept(loc.coordinate)
            })
            .disposed(by: bag)
        
        input.fecesButtonTapped
            .withLatestFrom(input.location)
            .subscribe(onNext: { [weak self] loc in
                self?.output.annotationLocation.accept(loc.coordinate)
            })
            .disposed(by: bag)
    }
}
