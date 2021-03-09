//
//  FetchAllRecordViewModel.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/03/02.
//

import Foundation
import RxSwift
import RxCocoa

class RecordViewModel: ViewModelType {
    
    var bag: DisposeBag = DisposeBag()
    var input = Input()
    var output = Output()
    
    struct Input {
        let deleteRecordBtnTapped = PublishSubject<Void>()
        let recordSubject = PublishSubject<Record>()
        var fetchRecord = PublishSubject<Void>()
    }
    
    struct Output {
        let recordData = PublishRelay<[Record]>()
        let timeStamp = PublishRelay<[Date]>()
        let errorMessage = PublishRelay<String>()
    }
    
    init(with puppyInfo: Puppy) {
        let fetching = PublishSubject<Void>()
        
        input.fetchRecord = fetching.asObserver()
        
        fetching
            .flatMap {
                FIRStoreManager.shared.fetchAllRecordInfo(from: .record(puppyId: puppyInfo.id!))
            }
            .subscribe(onNext: { [weak self] data in
                self?.output.recordData.accept(data)
            }, onError: { [weak self] err in
                self?.output.errorMessage.accept(err.localizedDescription)
            }).disposed(by: bag)
        
        output.recordData
            .subscribe(onNext: { [weak self] data in
                var times = [Date]()
                for record in data {
                    times.append(record.timeStamp.toDate())
                }
                self?.output.timeStamp.accept(times)
            }).disposed(by: bag)
        
        input.deleteRecordBtnTapped.withLatestFrom(input.recordSubject)
            .bind { [weak self] record in
                FIRStoreManager.shared.deleteRcordInfo(for: record, with: .record(puppyId: puppyInfo.id!)) { (isSuccess, err) in
                    if isSuccess == true {
                        self?.input.fetchRecord.onNext(())
                    } else {
                        self?.output.errorMessage.accept(err!.localizedDescription)
                    }
                }
            }.disposed(by: bag)
    }
}
