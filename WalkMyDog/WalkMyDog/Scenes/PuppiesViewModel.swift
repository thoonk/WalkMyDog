//
//  PuppyViewModel.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/21.
//

import Foundation
import RxSwift
import RxCocoa

class PuppiesViewModel: ViewModelType {

    var bag: DisposeBag = DisposeBag()
    var input: Input
    var output: Output
    
    struct Input {}
    
    struct Output {
        var puppyData: PublishRelay<[Puppy]>
        let errorMessage: PublishRelay<String>
    }
    
    init(){
        let error = PublishRelay<String>()
        let puppyData = PublishRelay<[Puppy]>()

        _ = FIRStoreManager.shared.fetchAllPuppyInfo()
            .subscribe(onNext: { data in
                puppyData.accept(data)
            }, onError: { err in
                error.accept(err.localizedDescription)
            }).disposed(by: bag)
        
        input = Input()
        output = Output(puppyData: puppyData, errorMessage: error)
    }
}
