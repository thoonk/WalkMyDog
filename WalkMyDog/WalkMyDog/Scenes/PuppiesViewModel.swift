//
//  PuppyViewModel.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/21.
//

import Foundation
import RxSwift

class PuppiesViewModel: ViewModelType {
    
    var puppySubject = PublishSubject<[Puppy]>()
    
    var bag: DisposeBag = DisposeBag()
    
    struct Input {}
    
    struct Output {
        var puppyData: Observable<[Puppy]>
        let errorMessage: Observable<String>
    }
    
    func bind(input: Input) -> Output {
        
        let error = PublishSubject<String>()

        _ = FIRStoreManager.shared.fetchAllPuppyInfo()
            .subscribe(onNext: { [weak self] data in
                self?.puppySubject.onNext(data)
            }, onError: { err in
                error.onNext(err.localizedDescription)
            }).disposed(by: bag)
        
        let puppyData = puppySubject
        
        return Output(puppyData: puppyData, errorMessage: error)
    }
}
