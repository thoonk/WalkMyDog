//
//  FetchPuppyViewModel.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/22.
//

import Foundation
import RxSwift

class FetchPuppyViewModel: ViewModelType {
    
    var bag: DisposeBag = DisposeBag()
    
    struct Input {
        // 강쥐 정보
    }
    
    struct Output {
        // 강쥐 정보 등록
        let puppyNameText: Observable<String>
        let puppySpeciesText: Observable<String>
        let puppyWeightText: Observable<String>
        let puppyBirthText: Observable<String>
        let puppyGender: Observable<Bool>
    }
    
    let output: Output
    
    init(_ selectedItem: Puppy) {
        
        let puppyInfo = Observable.just(selectedItem)
        
        let puppyName = puppyInfo.map { $0.name }
        let puppySpecies = puppyInfo.map { $0.species }
        let puppyWeight = puppyInfo.map { "\($0.weight)" }
        let puppyBirth = puppyInfo.map { $0.age }
        let puppyGender = puppyInfo.map { $0.gender }
        
        self.output = Output(puppyNameText: puppyName, puppySpeciesText: puppySpecies, puppyWeightText: puppyWeight, puppyBirthText: puppyBirth, puppyGender: puppyGender)
    }
}
