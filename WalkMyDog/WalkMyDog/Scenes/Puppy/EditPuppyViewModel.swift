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
    let puppyRealmService: PuppyRealmServiceProtocol
    let imageService: ImageServiceProtocol
    
    struct Input {
        let profileImage = PublishSubject<UIImage?>()
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
        let enableSaveBtn = BehaviorRelay<Bool>(value: false)
        let errorMessage = PublishRelay<String>()
        let goToSetting = PublishRelay<Void>()
    }
    
    init(
        with selectedItem: Puppy? = nil,
        puppyRealmService: PuppyRealmServiceProtocol = PuppyRealmService(),
        imageService: ImageServiceProtocol = ImageService()
    ) {
        self.puppyRealmService = puppyRealmService
        self.imageService = imageService
        
        let gender = BehaviorSubject<Bool>(value: true)
        
        Observable.combineLatest(
            input.name,
            input.weight,
            input.age,
            input.species
        )
            .map { !$0.0.isEmpty && !$0.1.isEmpty && !$0.2.isEmpty && !$0.3.isEmpty }
            .bind(to: output.enableSaveBtn)
            .disposed(by: bag)
        
        input.boyBtnTapped
            .subscribe(onNext: {
                gender.onNext(true)
            })
            .disposed(by: bag)
        
        input.girlBtnTapped
            .subscribe(onNext: {
                gender.onNext(false)
            })
            .disposed(by: bag)
        
        input.saveBtnTapped
            .withLatestFrom(Observable.combineLatest(
                input.profileImage,
                input.name,
                input.weight,
                input.age,
                input.species,
                gender
            ))
            .bind { [weak self] (
                image,
                name,
                weight,
                age,
                species,
                gender
            ) in
                // 신규 반려견 정보 저장
                if selectedItem == nil {
                    if let puppy = self?.puppyRealmService.insert(
                        name: name,
                        age: age,
                        gender: gender,
                        weight: Double(weight) ?? 0,
                        species: species,
                        imageURL: nil
                    ) {
                        var imageName: String? = nil
                        
                        if image != UIImage(named: "puppyProfileImage") {
                            imageName = name + "\(puppy.id)"
                            if imageService.save(image: image!, name: imageName!) {
                                self?.puppyRealmService.update(
                                    with: puppy,
                                    name: puppy.name,
                                    age: puppy.age,
                                    gender: puppy.gender,
                                    weight: puppy.weight,
                                    species: puppy.species,
                                    imageURL: imageName
                                )
                                
                                self?.output.goToSetting.accept(())
                            } else {
                                self?.output.errorMessage.accept("프로필 이미지 저장에 실패했습니다.\n 잠시 후 다시 시도해주세요.")
                            }
                        }
                    }
                }
                
                // 기존 반려견 정보 수정
                else {
                    var imageName: String? = nil
                    
                    if image != UIImage(named: "puppyProfileImage") {
                        
                        imageName = name + "\(selectedItem!.id)"
                        if imageService.save(image: image!, name: imageName!) {
                            self?.puppyRealmService.update(
                                with: selectedItem!,
                                name: name,
                                age: age,
                                gender: gender,
                                weight: Double(weight) ?? 0,
                                species: species,
                                imageURL: imageName
                            )
                            
                            self?.output.goToSetting.accept(())
                        } else {
                            self?.output.errorMessage.accept("프로필 이미지 저장에 실패했습니다.\n 잠시 후 다시 시도해주세요.")
                        }
                    }
                }
            }
            .disposed(by: bag)
        
        input.deleteBtnTapped
            .withLatestFrom(input.profileImage)
            .bind { [weak self] image in
                if let item = selectedItem {
                    if self?.puppyRealmService.remove(with: item) == true {
                        if item.imageURL != nil {
                            imageService.removeImage(with: item.imageURL!)
                        }
                        
                        self?.output.goToSetting.accept(())
                    } else {
                        self?.output.errorMessage.accept("반려견 데이터 삭제를 실패했습니다. 다시 시도해주시기 바랍니다.")
                    }
                }
            }
            .disposed(by: bag)
    }
}
