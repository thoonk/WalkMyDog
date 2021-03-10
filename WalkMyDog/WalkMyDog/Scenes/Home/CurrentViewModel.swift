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
        
    var input: Input
    var output: Output
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
        
        let pm10Image: Observable<String>
        let pm25Image: Observable<String>
        let rcmdStatus: Observable<String>
        
        let errorMessage: Observable<String>
    }
    
    init(){
        let weatherSubject = PublishSubject<WeatherCurrent>()
        let pmSubject = PublishSubject<PMModel>()
        let error = PublishSubject<String>()
        let isLoading = BehaviorSubject<Bool>(value: false)
        let locationManager = LocationManager.shared
        
        input = Input(location: locationManager.location, placemark: locationManager.placemark)
        
        input.location
            .take(1)
            .flatMapLatest { (location) -> Observable<WeatherCurrent> in
                CurrentAPIManger.shared.fetchWeatherData(lat: "\(location.coordinate.latitude)", lon: "\(location.coordinate.longitude)")
            }.subscribe(onNext: { data in
                weatherSubject.onNext(data)
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
            .subscribe(onNext: { data in
                pmSubject.onNext(data)
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
                
        let pm10Image = pmSubject
            .map { data in
                data.pm10Image
            }
        
        let pm25Image = pmSubject
            .map { data in
                data.pm25Image
            }
        
        let rcmdStatus = pmSubject
            .map { data in
                data.rcmdStatus
            }
        
        
        output = Output(isLoading: isLoading,
                        locationName: locationName,
                        conditionName: conditionName,
                        temperature: temperature,
                        pm10Image: pm10Image,
                        pm25Image: pm25Image,
                        rcmdStatus: rcmdStatus,
                        errorMessage: error)
    }
}
