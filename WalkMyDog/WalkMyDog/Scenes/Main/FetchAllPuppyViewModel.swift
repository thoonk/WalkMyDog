//
//  PuppyViewModel.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/21.
//

import Foundation
import RxSwift
import RxCocoa

final class FetchAllPuppyViewModel: ViewModelType {

    var bag: DisposeBag = DisposeBag()
    var input: Input
    var output: Output
    
    struct Input {
        var fetchData: AnyObserver<Void>
    }
    
    struct Output {
        let isLoading: BehaviorSubject<Bool>
        var puppyData: PublishRelay<[Puppy]>
        var errorMessage: PublishRelay<String>
    }
    
    init(){
        let fetching = PublishSubject<Void>()
        let fetchData: AnyObserver<Void> = fetching.asObserver()
        let isLoading = BehaviorSubject<Bool>(value: false)
        let puppyData = PublishRelay<[Puppy]>()
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
        
        // 임시 데이터
        fetching
            .do(onNext: { _ in isLoading.onNext(true) })
            .flatMapLatest { _ in
                return Observable.create() { emitter in
                    emitter.onNext([
                        Puppy(name: "앙꼬", age: "2016.12.11", gender: false, weight: 10.5, species: "퍼그")
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
            errorMessage: error
        )
    }
}
