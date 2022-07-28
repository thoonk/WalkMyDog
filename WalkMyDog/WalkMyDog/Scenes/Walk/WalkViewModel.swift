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

typealias AnnotationInfo = (location: CLLocation, type: AnnotationType)

final class WalkViewModel: ViewModelType {
    var bag: DisposeBag = DisposeBag()
    
    var input: Input    
    var timerService: TimerService
    var recordRealmService: RecordRealmServiceProtocol
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
        let enterForegroundAction = PublishSubject<(Int)>()
        let enterBackgroundAction = PublishSubject<(Void)>()
        let startLocation = PublishSubject<Location>()
        let endLocation = PublishSubject<Location>()
        let distance = BehaviorSubject<Double>(value: 0.0)
        let annotationType = PublishSubject<AnnotationType>()
    }
    
    struct Output {
        let location = PublishRelay<CLLocationCoordinate2D>()
        let path = PublishRelay<[CLLocationCoordinate2D]>()
        let annotationInfo = PublishRelay<(AnnotationInfo)>()
        let distanceRelay = BehaviorRelay<Double>(value: 0.0)
        let dismissRelay = PublishRelay<Void>()
        let puppyInfo = PublishRelay<[Puppy]>()
    }
    
    init(
        viewController: WalkViewController,
        puppies: [Puppy],
        timerService: TimerService = TimerService(),
        recordRealmService: RecordRealmServiceProtocol = RecordRealmService()
    ) {
        
        input = Input(
            location: LocationManager.shared.location
        )
        
        self.timerService = timerService
        self.timerService.delegate = viewController
        self.recordRealmService = recordRealmService
        let startTimeStamp = Date()
        
        var fecesLocations = [Location]()
        var peeLocatins = [Location]()

        Observable
            .combineLatest(input.location, input.pausePlayButtonTapped)
            .take(2)
            .bind { [weak self] location, state in
                if let location = location {
                    self?.input.startLocation.onNext(Location(clLocation: location))
                }
            }
            .disposed(by: bag)
        
        Observable
            .combineLatest(input.location, input.pausePlayButtonTapped)
            .bind { [weak self] loc, state in
                if let loc = loc,
                   loc.coordinate.isDefaultCoordinate == false
                {
                    self?.output.location.accept(loc.coordinate)
                    self?.input.endLocation.onNext(Location(clLocation: loc))
                    self?.output.puppyInfo.accept(puppies)
                    
                    if let previous = self?.previousLocation,
                       state == .play,
                       !previous.coordinate.isEqual(to: loc.coordinate) {
                        self?.output.path.accept([previous.coordinate, loc.coordinate])
                        
                        self?.accumulatedDistance += loc.distance(from: previous)
                        self?.input.distance.onNext(self?.accumulatedDistance ?? 0.0)
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
                    Defaults.shared.set(timerStatus: .run)
                case .pause:
                    self?.timerService.pauseTimer()
                    Defaults.shared.set(timerStatus: .pause)
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
        
        let compactLocation = input.location.asObservable().compactMap { $0 }
        
        input.fecesButtonTapped
            .withLatestFrom(Observable.combineLatest(compactLocation, input.annotationType))
            .subscribe(onNext: { [weak self] location, type in
                
                let recordLocation = Location(clLocation: location)
                
                switch type {
                case .feces:
                    fecesLocations.append(recordLocation)
                case .pee:
                    peeLocatins.append(recordLocation)
                }
                
                self?.output.annotationInfo.accept((location, type))
            })
            .disposed(by: bag)
        
        input.stopButtonTapped
            .debug()
            .withLatestFrom(
                Observable.combineLatest(
                    input.startLocation,
                    input.endLocation,
                    input.distance
                )
            )
            .bind { [weak self]
                startLocation,
                endLocation,
                distance in
                self?.timerService.stopTimer()
                
                let interval = Int(timerService.currentTime)
                
                for puppy in puppies {
                    let calories = self?.computeCalories(weight: puppy.weight, interval: interval)
                    
                    if self?.recordRealmService.insert(
                        selectedPuppy: puppy,
                        timeStamp: startTimeStamp,
                        interval: interval,
                        distance: distance,
                        calories: calories ?? 0.0,
                        startLocation: startLocation,
                        endLocation: endLocation,
                        fecesLocation: fecesLocations,
                        peeLocation: peeLocatins
                    ) == true {
                        print("Save Record Succeeded")
                    } else {
                        print("Save Record Failed")
                    }
                }
                
                self?.output.dismissRelay.accept(())
            }
            .disposed(by: bag)
        
        input.enterForegroundAction
            .bind { [weak self] timeInterval in
                self?.timerService.resetTimer(with: timeInterval)
            }
            .disposed(by: bag)
        
        input.enterBackgroundAction
            .bind { [weak self] _ in
                self?.timerService.stopTimer()
            }
            .disposed(by: bag)
    }
}

private extension WalkViewModel {
    func computeCalories(weight: Double, interval: Int) -> Double {
        let calories = ((2.5 * (3.5 * weight * Double(interval))) / 1000) * 5
        return round(calories * 100) / 100
    }
}
