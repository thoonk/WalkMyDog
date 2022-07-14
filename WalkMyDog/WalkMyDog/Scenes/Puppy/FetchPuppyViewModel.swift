//
//  FetchPuppyViewModel.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/22.
//

import Foundation
import RxSwift
import RxRelay

class FetchPuppyViewModel: ViewModelType {
    
    var bag: DisposeBag = DisposeBag()
    let imageService: ImageServiceProtocol
    
    struct Input {
        var fetchData: AnyObserver<Void>
    }
    
    struct Output {
        // 반려견 정보
        let profileImage: PublishRelay<UIImage?>
        let puppyNameText: Observable<String>
        let puppySpeciesText: Observable<String>
        let puppyWeightText: Observable<String>
        let puppyBirthText: Observable<String>
        let puppyGender: Observable<Bool>
    }
    
    let input: Input
    let output: Output
    
    init(
        with selectedItem: Puppy,
        imageService: ImageServiceProtocol = ImageService()
    ) {
        self.imageService = imageService
        
        let puppyInfo = Observable.just(selectedItem)
        
        let puppyName = puppyInfo.map { $0.name }
        let puppySpecies = puppyInfo.map { $0.species }
        let puppyWeight = puppyInfo.map { "\($0.weight)" }
        let puppyBirth = puppyInfo.map { $0.age }
        let puppyGender = puppyInfo.map { $0.gender }
        let puppyImageUrl = puppyInfo.map { $0.imageURL }
        
        let puppyImage = PublishRelay<UIImage?>()
        
        let fetching = PublishSubject<Void>()
        let fetchData: AnyObserver<Void> = fetching.asObserver()
        
        input = Input(fetchData: fetchData)
        
        fetching
            .withLatestFrom(puppyImageUrl)
            .bind { url in
                if let url = url,
                   let image = imageService.loadImage(with: url) {
                    puppyImage.accept(image)
                } else {
                    puppyImage.accept(UIImage(named: "puppyProfileImage"))
                }
            }
            .disposed(by: bag)
        
        self.output = Output(
            profileImage: puppyImage,
            puppyNameText: puppyName,
            puppySpeciesText: puppySpecies,
            puppyWeightText: puppyWeight,
            puppyBirthText: puppyBirth,
            puppyGender: puppyGender
        )
    }
}
