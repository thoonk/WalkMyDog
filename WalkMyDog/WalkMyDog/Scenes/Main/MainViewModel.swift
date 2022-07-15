//
//  MainViewModel.swift
//  WalkMyDog
//
//  Created by thoonk on 2021/02/21.
//

import Foundation
import RxSwift
import RxCocoa
import CoreLocation

enum MainModel {
    case puppyInfo([Puppy])
    case puppyCalendar(Puppy?)
}

final class MainViewModel: ViewModelType {
    var bag: DisposeBag = DisposeBag()
    var input: Input
    var output: Output
    var puppyRealmService: PuppyRealmServiceProtocol
    var puppies = [Puppy]()

    struct Input {
        var fetchData: AnyObserver<Void>
        var currentIndex = PublishSubject<Int>()
        var settingButtonTapped = PublishSubject<Void>()
        var walkButtonTapped = PublishSubject<Void>()
    }
    
    struct Output {
        let isLoading: BehaviorSubject<Bool>
        let puppyData: PublishRelay<[Puppy]>
        let cellData: PublishRelay<[MainModel]>
        let errorMessage: PublishRelay<String>
        let presentToSetting: PublishRelay<Void>
        let presentToWalk: PublishRelay<Void>
    }
    
    init(puppyRealmService: PuppyRealmServiceProtocol = PuppyRealmService()) {
        self.puppyRealmService = puppyRealmService
        
        let fetching = PublishSubject<Void>()
        let fetchData: AnyObserver<Void> = fetching.asObserver()
        let isLoading = BehaviorSubject<Bool>(value: false)
        let puppyData = PublishRelay<[Puppy]>()
        let cellData = PublishRelay<[MainModel]>()
        let error = PublishRelay<String>()
        var puppiesInfo = [Puppy]()
        let presentToSetting = PublishRelay<Void>()
        let presentToWalk = PublishRelay<Void>()

        input = Input(fetchData: fetchData)
        
//        fetching
//            .do(onNext: { _ in isLoading.onNext(true) })
//            .flatMapLatest { _ in
////                FIRStoreManager.shared.fetchAllPuppyInfo()
//            }
//            .do(onNext: { _ in isLoading.onNext(false) })
//            .subscribe(onNext: { data in
//                puppyData.accept(data)
//            }, onError: { err in
//                error.accept(err.localizedDescription)
//            })
//            .disposed(by: bag)
        
        /*
         모든 반려견 정보 가져온 후 current Index로 현재 반려견 정보 출력
         */
        
        fetching
            .do(onNext: { _ in isLoading.onNext(true) })
            .flatMapLatest { _ in
                puppyRealmService.fetchAllPuppies()
            }
            .debug()
            .flatMap { puppies -> Observable<[MainModel]> in
                puppiesInfo = puppies
                return Observable<[MainModel]>.create() { emitter in
                                                
                    emitter.onNext([
                        .puppyInfo(puppies),
                        .puppyCalendar(puppies.first)
                    ])

                    return Disposables.create()
                }
            }
            .do(onNext: { _ in isLoading.onNext(false) })
            .subscribe(onNext: { data in
                cellData.accept(data)
            })
            .disposed(by: bag)
                    
        input.currentIndex
                    .flatMap { index in
                        return Observable<[MainModel]>.create() { emitter in

                            emitter.onNext([
                                .puppyInfo(puppiesInfo),
                                .puppyCalendar(puppiesInfo[index])
                            ])

                            return Disposables.create()
                        }
                    }
            .subscribe(onNext: { data in
                cellData.accept(data)
            })
            .disposed(by: bag)

        input.settingButtonTapped
            .bind {
                presentToSetting.accept(())
            }
            .disposed(by: bag)
        
        input.walkButtonTapped
            .bind {
                presentToWalk.accept(())
            }
            .disposed(by: bag)
                    
//        let puppies = [
//            Puppy(id: 0, name: "앙꼬", age: "2016.12.11", gender: false, weight: 10.5, species: "퍼그"),
//            Puppy(id: 1, name: "앙꼬", age: "2016.12.11", gender: false, weight: 10.5, species: "퍼그"),
//            Puppy(id: 2, name: "앙꼬", age: "2016.12.11", gender: false, weight: 10.5, species: "퍼그")
//        ]
        
//        let records = [
//            Record(
//                id: 0,
//                puppy: Puppy(id: 0, name: "앙꼬", age: "2016.12.11", gender: false, weight: 10.5, species: "퍼그"),
//                timeStamp: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
//                interval: 1800,
//                distance: 1500,
//                calories: 254,
//                startLocation: Location(clLocation: CLLocation(latitude: 32.923, longitude: 234.2323)),
//                endLocation: Location(clLocation: CLLocation(latitude: 32.923, longitude: 234.2323))),
//            Record(
//                id: 1,
//                puppy: Puppy(id: 0, name: "앙꼬", age: "2016.12.11", gender: false, weight: 10.5, species: "퍼그"),
//                timeStamp: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
//                interval: 1800,
//                distance: 1500,
//                calories: 254,
//                startLocation: Location(clLocation: CLLocation(latitude: 32.923, longitude: 234.2323)),
//                endLocation: Location(clLocation: CLLocation(latitude: 32.923, longitude: 234.2323)))
//        ]
        
        // 임시 데이터
        // 현재 캘린더 월에 해당하는 산책 데이터
//        fetching
//            .do(onNext: { _ in isLoading.onNext(true) })
//            .flatMapLatest { _ in
//                // Date 이용해서 산책 데이터 가져오기
//                return Observable<[MainModel]>.create() { emitter in
//                    emitter.onNext([
//                        .puppyInfo(puppies),
//                        .puppyCalendar(puppies[0])
//                    ])
//
//                    return Disposables.create()
//                }
//            }
//            .do(onNext: { _ in isLoading.onNext(false) })
//            .subscribe(onNext: { data in
//                cellData.accept(data)
//            }).disposed(by: bag)
                
        output = Output(
            isLoading: isLoading,
            puppyData: puppyData,
            cellData: cellData,
            errorMessage: error,
            presentToSetting: presentToSetting,
            presentToWalk: presentToWalk
        )
    }
}

