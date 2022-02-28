//
//  EditRecordViewModel.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/03/03.
//

import Foundation
import RxSwift
import RxCocoa

final class EditRecordViewModel: ViewModelType {
    
    var bag: DisposeBag = DisposeBag()
    var input = Input()
    var output = Output()
    
    struct Input {
        let timeStamp = PublishSubject<String>()
        let walkedInterval = PublishSubject<String>()
        let walkedDistance = PublishSubject<String>()
        let saveBtnTapped = PublishSubject<Void>()
    }
    
    struct Output {
        let goToHome = PublishRelay<Void>()
        let enableSaveBtn = BehaviorRelay<Bool>(value: false)
        let errorMessage = PublishRelay<String>()
    }
    
    init(with selectedPuppies: [Puppy]) {
        Observable.combineLatest(
            input.timeStamp,
            input.walkedInterval,
            input.walkedDistance
        )
            .map { !$0.0.isEmpty && !$0.1.isEmpty && !$0.2.isEmpty }
            .bind(to: output.enableSaveBtn)
            .disposed(by: bag)
        
        input.saveBtnTapped.withLatestFrom(
            Observable.combineLatest(
                input.timeStamp,
                input.walkedInterval,
                input.walkedDistance
            ))
            .bind { [weak self] timeStamp, interval, distance in
                for puppy in selectedPuppies {
                    let calories = self?.computeCalories(
                        weight: puppy.weight,
                        interval: Int(interval)!
                    )
                    let record = Record(
                        timeStamp: timeStamp,
                        walkInterval: interval,
                        walkDistance: distance,
                        walkCalories: calories!
                    )

//                    FIRStoreManager.shared.createRecordInfo(
//                        for: record,
//                        with: .record(puppyId: puppy.id!)
//                    ) { isSuccess, id, err in
//                        if isSuccess == true {
//                            self?.output.goToHome.accept(())
//                        } else {
//                            self?.output.errorMessage.accept(err!.localizedDescription)
//                        }
//                    }
                }
            }
            .disposed(by: bag)
    }
    /// 반려견의 MET가 따로 없어 실제로 반려견을 데리고 측정한 평균 결과를 이용하여 계산하는 함수
    /// - Oxygen(ml) = MET * (3.5ml * kg * min)
    /// - Kcal = Oxygen(L) * 5
    private func computeCalories(weight: Double, interval: Int) -> Double {
        let calories = ((2.5 * (3.5 * weight * Double(interval))) / 1000) * 5
        return round(calories * 100) / 100
    }
}

