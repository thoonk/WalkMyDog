//
//  CheckPuppyViewModel.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/03/04.
//

import Foundation
import RxSwift
import RxCocoa

class CheckPuppyViewModel: ViewModelType {
    
    var bag: DisposeBag = DisposeBag()
    var output = Output()
    
    struct Input {}
    
    struct Output {
        var puppyData = PublishRelay<[Puppy]>()
        let errorMessage = PublishRelay<String>()
    }
    
    init(){

        _ = FIRStoreManager.shared.fetchAllPuppyInfo()
            .subscribe(onNext: { [weak self] data in
                self?.output.puppyData.accept(data)
            }, onError: { [weak self] err in
                self?.output.errorMessage.accept(err.localizedDescription)
            }).disposed(by: bag)
    }
}
