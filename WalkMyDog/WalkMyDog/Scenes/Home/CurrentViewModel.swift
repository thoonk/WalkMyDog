//
//  CurrentViewModel.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/16.
//

import Foundation
import RxSwift
import CoreLocation

class CurrentViewModel: ViewModelType {
    
    private var weatherSubject = PublishSubject<WeatherCurrent>()
    private var pmSubject = PublishSubject<PMModel>()
    
    var bag: DisposeBag = DisposeBag()
    
    struct Input {
        let location: ReplaySubject<CLLocation>
        let placemark: ReplaySubject<CLPlacemark>
    }
    
    struct Output {
        let isLoading: BehaviorSubject<Bool>
        let locationName: Observable<String>
        let conditionName: Observable<String>
        let temperature: Observable<String>
        
        let pm10Status: Observable<String>
        let pm25Status: Observable<String>
        
        let errorMessage: Observable<String>
    }
    
    func bind(input: Input) -> Output {
        
        let error = PublishSubject<String>()
        let isLoading = BehaviorSubject<Bool>(value: false)
        input.location
            .take(1)
            .flatMapLatest { (location) -> Observable<WeatherCurrent> in
                CurrentAPIManger.shared.fetchWeatherData(lat: "\(location.coordinate.latitude)", lon: "\(location.coordinate.longitude)")
            }.subscribe(onNext: { [weak self] data in
                self?.weatherSubject.onNext(data)
            }, onError: { err in
                error.onNext(err.localizedDescription)
            }).disposed(by: bag)
        
        input.location
            .take(1)
            .do(onNext: { _ in isLoading.onNext(true) })
            .flatMapLatest { (location) -> Observable<PMModel> in
                CurrentAPIManger.shared.fetchPMData(lat: "\(location.coordinate.latitude)", lon: "\(location.coordinate.longitude)")
            }
            .do(onNext: { _ in isLoading.onNext(false) })
            .subscribe(onNext: { [weak self] data in
                self?.pmSubject.onNext(data)
            }, onError: { err in
                error.onNext(err.localizedDescription)
            }).disposed(by: bag)
        
        let locationName = input.placemark
            .map { (placemark) in
                "\(placemark.administrativeArea ?? "-") \(placemark.locality ?? "") \(placemark.subLocality ?? "")"
            }
        
        let conditionName = weatherSubject
            .map { data in
                data.conditionName
            }
        
        let temperature = weatherSubject
            .map { data in
                data.temperatureString
            }
                
        let pm10Status = pmSubject
            .map { data in
                data.pm10Status
            }
        
        let pm25Status = pmSubject
            .map { data in
                data.pm25Status
            }
                
        return Output(isLoading: isLoading,
                      locationName: locationName,
                      conditionName: conditionName,
                      temperature: temperature,
                      pm10Status: pm10Status,
                      pm25Status: pm25Status,
                      errorMessage: error)
    }
}
