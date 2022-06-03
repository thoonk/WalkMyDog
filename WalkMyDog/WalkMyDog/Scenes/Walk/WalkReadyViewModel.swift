//
//  WalkReadyViewModel.swift
//  WalkMyDog
//
//  Created by thoonk on 2022/04/03.
//

import Foundation
import RxSwift
import CoreLocation
import RxRelay
import RxDataSources

enum WalkReadyItem {
    case weatherItem(condition: String, temperature: String, pm10: String, pm25: String)
    case puppyItem(puppies: [Puppy])
}

enum WalkReadySectionModel {
    case weatherSection(items: [WalkReadyItem])
    case puppySection(items: [WalkReadyItem])
}

final class WalkReadyViewModel: ViewModelType {
    var bag: DisposeBag = DisposeBag()
    
    struct Input {
        let location: ReplaySubject<CLLocation?>
        var fetchData: AnyObserver<Void>
        let startWalkingButtonTapped: PublishSubject<Void>
    }
    
    struct Output {
        let location = PublishRelay<CLLocationCoordinate2D>()
        let presentToWalk = PublishRelay<[Puppy]>()
    }
    
    var input: Input
    var output = Output()
    var puppyRealmService: PuppyRealmServiceProtocol
    
    var selectedPuppies: [Puppy] = [
        Puppy(id: 0, name: "앙꼬", age: "2016.12.11", gender: false, weight: 10.5, species: "퍼그")
    ]
    
    init(puppyRealmService: PuppyRealmServiceProtocol = PuppyRealmService()) {
        self.puppyRealmService = puppyRealmService
        
        let locationManager = LocationManager.shared
        let weatherSubject = PublishSubject<WeatherCurrent>()
        let pmSubject = PublishSubject<PMModel>()
        let puppySubject = PublishSubject<[Puppy]>()
        let fetching = PublishSubject<Void>()
        let fetchData: AnyObserver<Void> = fetching.asObserver()
        let isLoading = BehaviorSubject<Bool>(value: false)
//        let cellData = PublishRelay<[WalkReadySectionModel]>()
        let error = PublishRelay<String>()
        let startWalkingButtonTapped = PublishSubject<Void>()
        
        input = Input(
            location: locationManager.location,
            fetchData: fetchData,
            startWalkingButtonTapped: startWalkingButtonTapped
         )
        
        input.location
            .bind { [weak self] loc in
                if let loc = loc,
                   loc.coordinate.isDefaultCoordinate == false {
                    self?.output.location.accept(loc.coordinate)
                }
            }
            .disposed(by: bag)
        
        input.location
            .do(onNext: { _ in isLoading.onNext(true) })
            .compactMap { $0 }
            .flatMapLatest { location -> Observable<WeatherCurrent> in
                CurrentAPIManger.shared.fetchWeatherData(
                    lat: "\(location.coordinate.latitude)",
                    lon: "\(location.coordinate.longitude)"
                )
            }
            .subscribe(onNext: { data in
                weatherSubject.onNext(data)
            })
            .disposed(by: bag)
        
        input.location
            .compactMap { $0 }
            .flatMapLatest { location -> Observable<PMModel> in
                CurrentAPIManger.shared.fetchPMData(
                    lat: "\(location.coordinate.latitude)",
                    lon: "\(location.coordinate.longitude)"
                )
            }
            .subscribe(onNext: { data in
                pmSubject.onNext(data)
            })
            .disposed(by: bag)
        
        fetching
            .flatMapLatest { _ in
                puppyRealmService.fetchAllPuppies()
            }
            .do(onNext: { _ in isLoading.onNext(false) })
            .bind { data in
                puppySubject.onNext(data)
            }
            .disposed(by: bag)
        
//        Observable.combineLatest(weatherSubject, pmSubject, puppySubject)
//            .bind { weather, pm, puppies in
//                let weatherItem: [WalkReadyItem] = [.weatherItem(
//                    condition: weather.conditionName, temperature: weather.temperatureString, pm10: pm.pm10Image, pm25: pm.pm25Image)]
//
//                let puppyItem: [WalkReadyItem] = [.puppyItem(puppies: puppies)]
//
//                let sectionData: [WalkReadySectionModel] =
//                [
//                    .weatherSection(items: weatherItem),
//                    .puppySection(items: puppyItem)
//                ]
//
//                cellData.accept(sectionData)
//            }
//            .disposed(by: bag)
        
        input.startWalkingButtonTapped
            .subscribe(onNext: { [weak self] in
                if let puppies = self?.selectedPuppies {
                    self?.output.presentToWalk.accept(puppies)
                } else {
                    // 에러 메시지
                }
            })
            .disposed(by: bag)
    }
}

extension WalkReadySectionModel: SectionModelType {
    typealias Item = WalkReadyItem
    
    var items: [Item] {
        switch self {
        case .weatherSection(items: let items):
            return items.map { $0 }
        case .puppySection(items: let items):
            return items.map { $0 }
        }
    }
    
    init(original: WalkReadySectionModel, items: [Item]) {
        switch original {
        case .weatherSection(let items):
            self = .weatherSection(items: items )
        case .puppySection(let items):
            self = .puppySection(items: items)
        }
    }
}
