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
    
    init() {
        let fetching = PublishSubject<Void>()
        let isLoading = BehaviorSubject<Bool>(value: false)
        let error = PublishSubject<String>()
        let fetchFcst: AnyObserver<Void> = fetching.asObserver()
        let fcstData = PublishSubject<[FcstModel]>()
        
        let locationManager = LocationManager.shared
        input = Input(location: locationManager.location, placemark: locationManager.placemark, fetchFcst: fetchFcst)
        
        fetching.withLatestFrom(input.location)
            .debug()
            .do(onNext: { _ in isLoading.onNext(true) })
            .flatMapLatest { (location) -> Observable<[FcstModel]> in
                return FcstAPIManager.shared.fetchFcstData(lat: "\(location.coordinate.latitude)", lon: "\(location.coordinate.longitude)")
            }
            .do(onNext: { _ in isLoading.onNext(false) })
            .subscribe(onNext: { data in
                if data == nil {
                    error.onNext("새로고침 부탁드려요!")
                }
                fcstData.onNext(data)
                
//                var changedData = data
//                var first = changedData.removeFirst()
//                first.weekWeather?.dateTime = "오늘"
//                changedData.insert(first, at: 0)
//                self?.fcstSubject.onNext(changedData)
            }, onError: { err in
                error.onNext(err.localizedDescription)
            }).disposed(by: bag)
        
        let loaded = isLoading.asObserver()
        
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
