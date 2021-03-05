//
//  EditPuppyViewModel.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/23.
//

import Foundation
import RxSwift
import RxCocoa

class EditPuppyViewModel: ViewModelType {
    
    var bag: DisposeBag = DisposeBag()
    
    var input = Input()
    var output = Output()
    
    struct Input {
        let profileImage = PublishSubject<UIImage>()
        let name = PublishSubject<String>()
        let weight = PublishSubject<String>()
        let age = PublishSubject<String>()
        let species = PublishSubject<String>()
        let boyBtnTapped = PublishSubject<(Void)>()
        let girlBtnTapped = PublishSubject<(Void)>()
        let saveBtnTapped = PublishSubject<(Void)>()
        let deleteBtnTapped = PublishSubject<(Void)>()
    }
    
    struct Output {
        let enableSaveBtn = PublishRelay<Bool>()
        let errorMessage = PublishRelay<String>()
        let goToSetting = PublishRelay<Void>()
    }
    
    init(with selectedItem: Puppy) {
//        let documentID = selectedItem.id
        let gender = BehaviorSubject<Bool>(value: true)
        
        Observable.combineLatest(input.name, input.weight, input.age, input.species)
            .map { !$0.0.isEmpty && !$0.1.isEmpty && !$0.2.isEmpty && !$0.3.isEmpty }
            .bind(to: output.enableSaveBtn)
            .disposed(by: bag)
        
        input.boyBtnTapped
            .subscribe(onNext: {
                gender.onNext(true)
            }).disposed(by: bag)
        
        input.girlBtnTapped
            .subscribe(onNext: {
                gender.onNext(false)
            }).disposed(by: bag)
        
        input.saveBtnTapped.withLatestFrom(Observable.combineLatest(input.name, input.weight, input.age, input.species, gender))
            .bind { [weak self] (name, weigt, age, species, gender) in
                
                var puppy = Puppy(name: name, age: age, gender: gender, weight: Double(weigt) ?? 0, species: species)
                puppy.id = selectedItem.id
                
                FIRStoreManager.shared.updatePuppyInfo(for: puppy) { (isSuccess, err) in
                    if isSuccess == true {
                        self?.output.goToSetting.accept(())
                    } else {
                        self?.output.errorMessage.accept(err!.localizedDescription)
                    }
                }
            }.disposed(by: bag)
        
        input.deleteBtnTapped
            .subscribe(onNext: { [weak self] in 
                FIRStoreManager.shared.deletePuppyInfo(for: selectedItem) { (isSuccess, err) in
                    if isSuccess == true {
                        self?.output.goToSetting.accept(())
                    } else {
                        self?.output.errorMessage.accept(err!.localizedDescription)
                    }
                }
            }).disposed(by: bag)
    }
}
