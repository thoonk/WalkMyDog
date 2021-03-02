//
//  CreateRecordViewModel.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/03/02.
//

import Foundation
import RxSwift

class CreateRecordViewModel: ViewModelType {
    
    var bag: DisposeBag = DisposeBag()
    var input = Input()
    
    struct Input {
        let addRecordBtnTapped = PublishSubject<Void>()
    }
    
    struct Output {}
    
    init() {
//        let id = PublishSubject<Int>()
//
//        _ = FIRStoreManager.shared.incrementRecordId(with: .records(puppyId: 1))
//            .debug()
//            .subscribe(onNext: { num in
//                id.onNext(num)
//            }).disposed(by: bag)
        
        input.addRecordBtnTapped
            .subscribe(onNext: {
                let record = Record(id: 1, timeStamp: Date().description)
                FIRStoreManager.shared.createRecordInfo(for: record, with: .puppies, puppyId: 2)
            }).disposed(by: bag)
    }
}
