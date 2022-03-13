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
    var timerService: TimerService
    var output = Output()
    
    /// 경로 표시를 위한 이전 위치
    private var previousLocation: CLLocation?
    /// 누적 거리
    private var accumulatedDistance: Double = 0.0
    
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
    
    init(viewController: WalkViewController, timerService: TimerService = TimerService()) {
        input = Input(
            location: LocationManager.shared.location
        )
        
        self.timerService = timerService
        self.timerService.delegate = viewController
        
        Observable
            .combineLatest(input.location, input.pausePlayButtonTapped)
            .debug()
            .bind { [weak self] loc, state in
                if let loc = loc,
                   loc.coordinate.isDefaultCoordinate == false
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
                }
            }
            .disposed(by: bag)
        
        input.pausePlayButtonTapped
            .bind { [weak self] state in
                switch state {
                case .play:
                    self?.timerService.startTimer()
                case .pause:
                    self?.timerService.pauseTimer()
                }
            }
            .disposed(by: bag)
        
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
        
        input.stopButtonTapped
            .bind { [weak self] in
                self?.timerService.pauseTimer()
            }
            .disposed(by: bag)
    }
}
