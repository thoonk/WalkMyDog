//
//  FetchAllRecordViewModel.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/03/02.
//

import Foundation
import RxSwift
import RxCocoa

final class RecordViewModel: ViewModelType {
    
    var bag: DisposeBag = DisposeBag()
    var input = Input()
    var output = Output()
    
    struct Input {
        let deleteBtnTapped = PublishSubject<Void>()
        let recordSubject = PublishSubject<Record>()
        var fetchRecord = PublishSubject<Void>()
        var currentDate = BehaviorSubject<Date>(value: Date())
    }
    
    struct Output {
        let recordData = PublishRelay<[Record]>()
        let timeStamp = PublishRelay<[Date]>()
        let sumInterval = PublishRelay<String>()
        let avgInterval = PublishRelay<String>()
        let sumDist = PublishRelay<String>()
        let avgDist = PublishRelay<String>()
        let sumCalorie = PublishRelay<String>()
        let avgCalorie = PublishRelay<String>()
        let errorMessage = PublishRelay<String>()
    }
    
    init(with puppyInfo: Puppy) {
        let fetching = PublishSubject<Void>()
        let isActivating = BehaviorSubject<Bool>(value: false)
        input.fetchRecord = fetching.asObserver()
        
//        fetching
//            .do(onNext: { _ in isActivating.onNext(true)})
//            .flatMap {
//                FIRStoreManager
//                    .shared
//                    .fetchAllRecordInfo(from: .record(puppyId: puppyInfo.id!))
//            }
//            .do(onNext: { _ in isActivating.onNext(false)})
//            .subscribe(onNext: { [weak self] data in
//                self?.output.recordData.accept(data)
//                var times = [Date]()
//                for record in data {
//                    times.append(record.timeStamp.toDate())
//                }
//                self?.output.timeStamp.accept(times)
//            }, onError: { [weak self] err in
//                self?.output.errorMessage.accept(err.localizedDescription)
//            })
//            .disposed(by: bag)
        
        /*
         현재 달에 해당하는 산책 기록을 필터링하여
         현재 달의 산책 시간, 거리, 칼로리를 계산하여 합계와 평균을 계산
         */
        Observable.combineLatest(input.currentDate, output.recordData)
            .bind { [weak self] (current, record) in
                var dist = [Int]()
                var interval = [Int]()
                var calorie = [Double]()

                for i in record.indices {
                    if current.isEqual(to: record[i].timeStamp.toDate()) {
                        let convertedDist = Int(record[i].walkDistance)!
                        let convertedInterval = Int(record[i].walkInterval)!
                        dist.append(convertedDist)
                        interval.append(convertedInterval)
                        calorie.append(record[i].walkCalories)
                    }
                }
                
                if !dist.isEmpty {
                    let sumInterval = interval.reduce(0,+)
                    let sumDist = dist.reduce(0,+)
                    let sumCalorie = calorie.reduce(0,+)
                    let avgInterval = sumInterval / interval.count
                    let avgDist = sumDist / dist.count
                    let avgCalorie = sumCalorie / Double(calorie.count)
                    
                    self?.output
                        .sumInterval
                        .accept("\(sumInterval/60) : \(sumInterval%60)")
                    self?.output
                        .sumDist
                        .accept("\(round(Double(sumDist)/1000*100)/100) km")
                    self?.output
                        .sumCalorie
                        .accept("\(round(sumCalorie*100) / 100) kcal")
                    self?.output
                        .avgInterval
                        .accept("\(avgInterval/60) : \(avgInterval%60)")
                    self?.output
                        .avgDist
                        .accept("\(round(Double(avgDist)/1000*100)/100) km")
                    self?.output
                        .avgCalorie
                        .accept("\(round(avgCalorie*100) / 100) kcal")
                } else {
                    self?.output.sumInterval.accept("00:00")
                    self?.output.sumDist.accept("0 km")
                    self?.output.sumCalorie.accept("0 kcal")
                    self?.output.avgInterval.accept("00:00")
                    self?.output.avgDist.accept("0 km")
                    self?.output.avgCalorie.accept("0 kcal")
                }
            }
            .disposed(by: bag)
        
//        input.deleteBtnTapped.withLatestFrom(input.recordSubject)
//            .bind { [weak self] record in
//                FIRStoreManager.shared.deleteRcordInfo(
//                    for: record,
//                    with: .record(puppyId: puppyInfo.id!)
//                ) { isSuccess, err in
//                    if isSuccess == true {
//                        self?.input.fetchRecord.onNext(())
//                    } else {
//                        self?.output.errorMessage.accept(err!.localizedDescription)
//                    }
//                }
//            }
//            .disposed(by: bag)
    }
}


