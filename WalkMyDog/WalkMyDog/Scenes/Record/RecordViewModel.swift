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
        let deleteBtnTapped = PublishSubject<Void>()
        let recordSubject = PublishSubject<Record>()
        var fetchRecord = PublishSubject<Void>()
        var currentDate = PublishSubject<Date>()
    }
    
    struct Output {
        let recordData = PublishRelay<[Record]>()
        let timeStamp = PublishRelay<[Date]>()
        let sumInterval = PublishRelay<String>()
        let avgInterval = PublishRelay<String>()
        let sumDist = PublishRelay<String>()
        let avgDist = PublishRelay<String>()
        let errorMessage = PublishRelay<String>()
    }
    
    init(with puppyInfo: Puppy) {
        let fetching = PublishSubject<Void>()
        let isActivating = BehaviorSubject<Bool>(value: false)
        input.fetchRecord = fetching.asObserver()
        
        fetching
            .do(onNext: { _ in isActivating.onNext(true)})
            .flatMap {
                FIRStoreManager.shared.fetchAllRecordInfo(from: .record(puppyId: puppyInfo.id!))
            }
            .do(onNext: { _ in isActivating.onNext(false)})
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
        
        Observable.combineLatest(input.currentDate, output.recordData)
            .bind { [weak self] (current, record) in
                var dist = [Int]()
                var interval = [Int]()

                for i in record.indices {
                    if current.isEqual(to: record[i].timeStamp.toDate()) {
                        dist.append(Int(record[i].walkDistance)!)
                        interval.append(Int(record[i].walkInterval)!)
                    }
                }
                
                if dist.count > 0 {
                    let sumInterval = interval.reduce(0,+)
                    let sumDist = dist.reduce(0,+)
                    let avgInterval = sumInterval/interval.count
                    let avgDist = sumDist/dist.count
                    
                    self?.output.sumInterval.accept("\(sumInterval/60) : \(sumInterval%60)")
                    self?.output.sumDist.accept("\(round(Double(sumDist)/1000*100)/100)km")
                    self?.output.avgInterval.accept("\(avgInterval/60) : \(avgInterval%60)")
                    self?.output.avgDist.accept("\(round(Double(avgDist)/1000*100)/100)km")
                } else {
                    self?.output.sumInterval.accept("00:00")
                    self?.output.sumDist.accept("0 km")
                    self?.output.avgInterval.accept("00:00")
                    self?.output.avgDist.accept("0 km")
                }
            }.disposed(by: bag)
        
        input.deleteBtnTapped.withLatestFrom(input.recordSubject)
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
