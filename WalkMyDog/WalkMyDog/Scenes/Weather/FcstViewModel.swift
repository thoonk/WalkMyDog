//
//  FcstAPIManager.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/16.
//

import Foundation
import RxSwift
import CoreLocation
import RxCocoa

final class FcstViewModel: ViewModelType {
        
    var input: Input
    var output: Output
    var bag: DisposeBag = DisposeBag()
    
    struct Input {
        let location: ReplaySubject<CLLocation>
        let placemark: ReplaySubject<CLPlacemark>
        var fetchFcst: AnyObserver<Void>
    }
    
    struct Output {
        let fcstData: Observable<[FcstModel]>
        let locationName: Observable<String>
        let loaded: Observable<Bool>
        let errorMessage: Observable<String>
    }
    
    init(with locationManager: LocationManager) {
        let fetching = PublishSubject<Void>()
        let fetchFcst: AnyObserver<Void> = fetching.asObserver()

        let isLoading = BehaviorSubject<Bool>(value: false)
        let loaded = isLoading.asObserver()
        
        let error = PublishSubject<String>()
        let fcstData = PublishSubject<[FcstModel]>()
        
        input = Input(location: locationManager.location, placemark: locationManager.placemark, fetchFcst: fetchFcst)
        
        fetching.withLatestFrom(input.location) // Observable.combineLatest(fetching, input.location)
            .debug()
            .do(onNext: { _ in isLoading.onNext(true) })
            .flatMapLatest { (location) -> Observable<[FcstModel]> in
                print("\(location.coordinate.latitude), \(location.coordinate.longitude)")
                return FcstAPIManager.shared.fetchFcstData(lat: "\(location.coordinate.latitude)", lon: "\(location.coordinate.longitude)")
            }
            .do(onNext: { _ in isLoading.onNext(false) })
            .subscribe(onNext: { data in
                if data.isEmpty {
                    error.onNext("새로고침 부탁드립니다!")
                } else {
                    var changedData = data
                    var first = changedData.removeFirst()
                    first.weekWeather?.dateTime = "오늘"
                    changedData.insert(first, at: 0)
                    fcstData.onNext(changedData)
                }
            }, onError: { err in
                error.onNext(err.localizedDescription)
            }).disposed(by: bag)
        
        let locationName = input.placemark
            .map { (placemark) in
                "\(placemark.administrativeArea ?? "-") \(placemark.locality ?? "") \(placemark.subLocality ?? "")"
            }

        self.output = Output(fcstData: fcstData,
                      locationName: locationName,
                      loaded: loaded,
                      errorMessage: error)
    }
}
