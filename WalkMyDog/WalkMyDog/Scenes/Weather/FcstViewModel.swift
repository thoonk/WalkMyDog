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

class FcstViewModel: ViewModelType {
    
    private var fcstSubject = PublishSubject<[FcstModel]>()
    
    var bag: DisposeBag = DisposeBag()
    
    struct Input {
        let location: ReplaySubject<CLLocation>
        let placemark: ReplaySubject<CLPlacemark>
    }
    
    struct Output {
        let fcstData: Observable<[FcstModel]>
        let locationName: Observable<String>
        let isLoading: BehaviorSubject<Bool>
        let errorMessage: Observable<String>
    }
    
    func bind(input: Input) -> Output {
        let isLoading = BehaviorSubject<Bool>(value: false)
        let error = PublishSubject<String>()
                
        input.location
            .take(1)
            .do(onNext: { _ in isLoading.onNext(true) })
            .flatMapLatest { (location) -> Observable<[FcstModel]> in
                return FcstAPIManager.shared.fetchFcstData(lat: "\(location.coordinate.latitude)", lon: "\(location.coordinate.longitude)")
            }
            .do(onNext: { _ in isLoading.onNext(false) })
            .subscribe(onNext: { [weak self] data in
                var changedData = data
                var first = changedData.removeFirst()
                first.weekWeather?.dateTime = "오늘"
                changedData.insert(first, at: 0)
                self?.fcstSubject.onNext(changedData)
            }, onError: { err in
                error.onNext(err.localizedDescription)
            }).disposed(by: bag)
        
        let fcstData = fcstSubject
        
        let locationName = input.placemark
            .map { (placemark) in
                "\(placemark.administrativeArea ?? "-") \(placemark.locality ?? "") \(placemark.subLocality ?? "")"
            }

        return Output(fcstData: fcstData,
                      locationName: locationName,
                      isLoading: isLoading,
                      errorMessage: error)
    }
}
