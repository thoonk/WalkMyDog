//
//  SelectPuppyViewModel.swift
//  WalkMyDog
//
//  Created by thoonk on 2022/03/01.
//

import RxSwift
import RxRelay
import CoreLocation

final class SelectPuppyViewModel: ViewModelType {
    var bag = DisposeBag()
    
    var input: Input
    var output: Output
    
    struct Input {
        var fetchData: AnyObserver<Void>
        let checkedPuppies = PublishSubject<[Puppy]>()
        let startButtonTapped = PublishSubject<Void>()
    }
    
    struct Output {
        let isLoading: BehaviorSubject<Bool>
        var puppyData: PublishRelay<[Puppy]>
        var errorMessage: PublishRelay<String>
        var location: PublishRelay<CLLocation>
    }
    
    init() {
        let fetching = PublishSubject<Void>()
        let fetchData: AnyObserver<Void> = fetching.asObserver()
        let isLoading = BehaviorSubject<Bool>(value: false)
        let puppyData = PublishRelay<[Puppy]>()
        let error = PublishRelay<String>()

        let location = PublishRelay<CLLocation>()
        
        input = Input(
            fetchData: fetchData
        )
        
        fetching
            .do(onNext: { _ in isLoading.onNext(true) })
            .flatMapLatest { _ in
                return Observable.create() { emitter in
                    emitter.onNext([
                        Puppy(name: "앙꼬", age: "2016년 12월 11일", gender: false, weight: 10.5, species: "퍼그")
                    ])
                    
                    return Disposables.create()
                }
            }
            .do(onNext: { _ in isLoading.onNext(false) })
            .subscribe(onNext: { data in
                puppyData.accept(data)
            })
            .disposed(by: bag)

        output = Output(
            isLoading: isLoading,
            puppyData: puppyData,
            errorMessage: error,
            location: location
        )
    }
}
