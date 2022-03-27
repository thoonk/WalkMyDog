//
//  MainViewModel.swift
//  WalkMyDog
//
//  Created by thoonk on 2021/02/21.
//

import Foundation
import RxSwift
import RxCocoa

enum MainModel {
    case puppyInfo([Puppy])
    case puppyCalendar(Puppy, [Record])
}

final class MainViewModel: ViewModelType {
    var bag: DisposeBag = DisposeBag()
    var input: Input
    var output: Output
    
    struct Input {
        var fetchData: AnyObserver<Void>
    }
    
    struct Output {
        let isLoading: BehaviorSubject<Bool>
        let puppyData: PublishRelay<[Puppy]>
        let cellData: PublishRelay<[MainModel]>
        let errorMessage: PublishRelay<String>
    }
    
    init(){
        let fetching = PublishSubject<Void>()
        let fetchData: AnyObserver<Void> = fetching.asObserver()
        let isLoading = BehaviorSubject<Bool>(value: false)
        let puppyData = PublishRelay<[Puppy]>()
        let cellData = PublishRelay<[MainModel]>()
        let error = PublishRelay<String>()
        
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
        
        let puppies = [
        Puppy(name: "앙꼬", age: "2016.12.11", gender: false, weight: 10.5, species: "퍼그"),
        Puppy(name: "앙꼬", age: "2016.12.11", gender: false, weight: 10.5, species: "퍼그"),
        Puppy(name: "앙꼬", age: "2016.12.11", gender: false, weight: 10.5, species: "퍼그")
        ]
        
        let records = [
            Record(
                timeStamp: Date(),
                interval: 1800,
                distance: 1.5,
                calories: 254,
                startLocation: Coordinate(32.923, 234.2323),
                endLocation: Coordinate(32.923, 234.2323))
        ]
        
        // 임시 데이터
        fetching
            .do(onNext: { _ in isLoading.onNext(true) })
            .flatMapLatest { _ in
                
                return Observable<[MainModel]>.create() { emitter in
                    emitter.onNext([
                        .puppyInfo(puppies),
                        .puppyCalendar(puppies[0], records)
                    ])

                    return Disposables.create()
                }
            }
            .do(onNext: { _ in isLoading.onNext(false) })
            .subscribe(onNext: { data in
                cellData.accept(data)
            })
            .disposed(by: bag)
                
        output = Output(
            isLoading: isLoading,
            puppyData: puppyData,
            cellData: cellData,
            errorMessage: error
        )
    }
}

