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
    
    /// 경로 표시를 위한 이전 위치
    private var previousLocation = CLLocation()
    /// 시작 위치
    private var startLocation = CLLocation()
    /// 누적 거리
    private var accumulatedDistance: Double = 0.0
    /// pause 이후 play 였을 때 startLoc 초기화해야 함.
//    private var wasPaused: Bool = false
    
    struct Input {
        let location: ReplaySubject<CLLocation?>
        let myLocationButtonTapped = PublishSubject<(Void)>()
        let pausePlayButtonTapped = BehaviorSubject<(ButtonState)>(value: .play)
        let stopButtonTapped = PublishSubject<(Void)>()
        let cameraButtonTapped = PublishSubject<(Void)>()
        let fecesButtonTapped = PublishSubject<(Void)>()
    }
    
    struct Output {
        let location = PublishRelay<CLLocationCoordinate2D>()
        let path = PublishRelay<[CLLocationCoordinate2D]>()
        let annotationLocation = PublishRelay<CLLocationCoordinate2D>()
        let distanceRelay = BehaviorRelay<Double>(value: 0.0)
    }
    
    init() {
        let locationManager = LocationManager.shared
        
        input = Input(
            location: locationManager.location
        )
        
        // 처음 시작 위치 저장
//        input.location
//            .take(1)
//            .subscribe(onNext: { [weak self] loc in
//                if let loc = loc {
//                    self?.startLocation = loc
//                }
//            })
//            .disposed(by: bag)
        
        Observable
            .combineLatest(input.location, input.pausePlayButtonTapped)
            .debug()
            .bind { [weak self] loc, state in
                if let loc = loc,
                   !loc.coordinate.isDefaultCoordinate
                {
                    self?.output.location.accept(loc.coordinate)
                    
                    if let previous = self?.previousLocation,
                       state == .play,
                       !previous.coordinate.isEqual(to: loc.coordinate) {
                        self?.output.path.accept([previous.coordinate, loc.coordinate])
                        
                        self?.accumulatedDistance += loc.distance(from: previous)
                        self?.output.distanceRelay.accept(self?.accumulatedDistance ?? 0.0)
                    }
                    
                    self?.previousLocation = loc
                    
//                    if state == .pause {
//                        self?.accumulatedDistance += self?.startLocation.distance(from: loc) ?? 0.0
//                        self?.output.distanceRelay.accept(self?.accumulatedDistance ?? 0.0)
//                        self?.wasPaused = true
//                    } else {
//                        if self?.wasPaused == true {
//                            self?.startLocation = CLLocation()
//                            self?.wasPaused = false
//                        }
//                    }
                }
            }
            .disposed(by: bag)
        
        /*
         pause 버튼 탭 후 accumulatedDistacne += startLocation.distance(from: currentLocation)
         start 버튼 탭 후 startLocation = currentLocation
        */
        
//        input.location
//            .combiningLatest(input.pausePlayButtonTapped)
//            .compactMap { $0 }
//            .bind { [weak self] loc, state in
//
//            })
//            .disposed(by: bag)
        
        input.myLocationButtonTapped
            .withLatestFrom(input.location)
            .debug()
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] loc in
                self?.output.location.accept(loc.coordinate)
            })
            .disposed(by: bag)
        
        input.fecesButtonTapped
            .withLatestFrom(input.location)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] loc in
                self?.output.annotationLocation.accept(loc.coordinate)
            })
            .disposed(by: bag)
    }
}

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
