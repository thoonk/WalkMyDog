//
//  CurrentViewModel.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/16.
//

import Foundation
import RxSwift
import CoreLocation
import RxRelay

final class CurrentViewModel: ViewModelType {
    
    var input: Input
    var output: Output
    var bag: DisposeBag = DisposeBag()
    
    struct Input {
        let location: ReplaySubject<CLLocation?>
        let placemark: ReplaySubject<CLPlacemark>
    }
    
    struct Output {
        let location = PublishRelay<CLLocationCoordinate2D>()
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
        
        input = Input(
            location: locationManager.location,
            placemark: locationManager.placemark
        )
        
//        input.location
//            .do(onNext: { _ in isLoading.onNext(true) })
//            .compactMap { $0 }
//            .flatMapLatest { (location) -> Observable<WeatherCurrent> in
//                CurrentAPIManger.shared.fetchWeatherData(
//                    lat: "\(location.coordinate.latitude)",
//                    lon: "\(location.coordinate.longitude)"
//                )
//            }.subscribe(onNext: { data in
//                weatherSubject.onNext(data)
//            }, onError: { err in
//                error.onNext(err.localizedDescription)
//            }).disposed(by: bag)
        
//        input.location
//            .compactMap { $0 }
//            .flatMapLatest { (location) -> Observable<PMModel> in
//                CurrentAPIManger.shared.fetchPMData(
//                    lat: "\(location.coordinate.latitude)",
//                    lon: "\(location.coordinate.longitude)"
//                )
//            }
//            .do(onNext: { _ in isLoading.onNext(false) })
//            .subscribe(onNext: { data in
//                pmSubject.onNext(data)
//            }, onError: { err in
//                error.onNext(err.localizedDescription)
//            }).disposed(by: bag)
        
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
        
        let rcmdStatus: Observable<String> = Observable
            .combineLatest(pmSubject, weatherSubject)
            .map { (pm, weather) in
                if weather.conditionId <= 531 {
                    return "비가 내려요..🌧"
                } else {
                    return pm.rcmdStatus
                }
            }
        
        output = Output(
            isLoading: isLoading,
            locationName: locationName,
            conditionName: conditionName,
            temperature: temperature,
            pm10Image: pm10Image,
            pm25Image: pm25Image,
            rcmdStatus: rcmdStatus,
            errorMessage: error
        )
        
        input.location
            .bind { [weak self] loc in
                if let loc = loc,
                   loc.coordinate.isDefaultCoordinate == false {
                self?.output.location.accept(loc.coordinate)
                }
            }
            .disposed(by: bag)
    }
}
