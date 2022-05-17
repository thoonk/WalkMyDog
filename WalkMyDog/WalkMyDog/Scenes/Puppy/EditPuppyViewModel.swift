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
    var puppyRealmService: PuppyRealmServiceProtocol
    
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
        puppyRealmService: PuppyRealmServiceProtocol = PuppyRealmService()
    ) {
        self.puppyRealmService = puppyRealmService
        
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
                if selectedItem == nil {
                    self?.puppyRealmService.insert(
                        name: name,
                        age: age,
                        gender: gender,
                        weight: Double(weight) ?? 0,
                        species: species,
                        imageURL: nil
                    )
                } else {
                    self?.puppyRealmService.update(
                        with: selectedItem!,
                        name: name,
                        age: age,
                        gender: gender,
                        weight: Double(weight) ?? 0,
                        species: species,
                        imageURL: nil
                    )
                }
            }
            .disposed(by: bag)
        
        input.deleteBtnTapped
            .withLatestFrom(input.profileImage)
            .bind { [weak self] image in
                if let item = selectedItem {
                    if self?.puppyRealmService.remove(with: item) == true {
                        if image != nil {
                            // item.imageURL
                            // 로컬 이미지 삭제
                        }
                        self?.output.goToSetting.accept(())
                    } else {
                        self?.output.errorMessage.accept("반려견 데이터 삭제를 실패했습니다. 다시 시도해주시기 바랍니다.")
                    }

                }
            }
            .disposed(by: bag)
        
//        input.saveBtnTapped
//            .withLatestFrom(Observable.combineLatest(
//                                input.profileImage,
//                                input.name,
//                                input.weight,
//                                input.age,
//                                input.species,
//                                gender
//            ))
//            .bind { [weak self] (
//                image,
//                name,
//                weight,
//                age,
//                species,
//                gender
//            ) in
//                var puppy = Puppy(
//                    name: name,
//                    age: age,
//                    gender: gender,
//                    weight: Double(weight) ?? 0,
//                    species: species
//                )
//                // 반려견 정보 생성
//                if selectedItem == nil {
//                    FIRStoreManager.shared.createPuppyInfo(
//                        for: puppy,
//                        with: .puppies
//                    )  { isSuccess, id, err in
//                        if isSuccess == true {
//                            if image != nil {
//                                puppy.id = id
//                                StorageManager.shared.saveImage(
//                                    with: .uid,
//                                    id: id!,
//                                    image: image!
//                                ) { imageURL in
//                                    puppy.imageUrl = imageURL
//                                    FIRStoreManager
//                                        .shared
//                                        .updatePuppyInfo(for: puppy) { isSuccess, err in
//                                        if isSuccess == true {
//                                            self?.output.goToSetting.accept(())
//                                        } else {
//                                            self?.output.errorMessage.accept(err!.localizedDescription)
//                                        }
//                                    }
//                                }
//                            } else {
//                                self?.output.goToSetting.accept(())
//                            }
//                        } else {
//                            self?.output.errorMessage.accept(err!.localizedDescription)
//                        }
//                    }
//                }
//                // 반려견 정보 수정
//                else {
//                    puppy.id = selectedItem!.id
//                    // 프로필 이미지를 바꾼 경우
//                    if image != nil {
//                        StorageManager.shared.saveImage(
//                            with: .uid,
//                            id: puppy.id!,
//                            image: image!) { imageURL in
//                            puppy.imageUrl = imageURL
//                            FIRStoreManager
//                                .shared
//                                .updatePuppyInfo(for: puppy) { isSuccess, err in
//                                if isSuccess == true {
//                                    self?.output
//                                        .goToSetting
//                                        .accept(())
//                                } else {
//                                    self?.output
//                                        .errorMessage
//                                        .accept(err!.localizedDescription)
//                                }
//                            }
//                        }
//                    }
//                    // 프로필 이미지가 기본 이미지일 때
//                    else {
//                        FIRStoreManager
//                            .shared
//                            .updatePuppyInfo(for: puppy) { isSuccess, err in
//                            if isSuccess == true {
//                                self?.output
//                                    .goToSetting
//                                    .accept(())
//                            } else {
//                                self?.output
//                                    .errorMessage
//                                    .accept(err!.localizedDescription)
//                            }
//                        }
//                    }
//                }
//            }
//            .disposed(by: bag)
        
//        input.deleteBtnTapped
//            .withLatestFrom(input.profileImage)
//            .bind { [weak self] image in
//                FIRStoreManager
//                    .shared
//                    .deletePuppyInfo(for: selectedItem!) { isSuccess, err in
//                    if isSuccess == true {
//                        if image != nil {
//                            StorageManager
//                                .shared
//                                .deleteImage(
//                                    with: .uid,
//                                    id: selectedItem!.id!
//                                ) { isSuccess, err in
//                                if isSuccess == true {
//                                    self?.output.goToSetting.accept(())
//                                } else {
//                                    self?.output.errorMessage.accept(err!.localizedDescription)
//                                }
//                            }
//                        } else {
//                            self?.output.goToSetting.accept(())
//                        }
//                    } else {
//                        self?.output.errorMessage.accept(err!.localizedDescription)
//                    }
//                }
//            }
//            .disposed(by: bag)
    }
}

private extension EditPuppyViewModel {
    func saveImage(with image: UIImage, fileName: String) -> URL? {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let fileURL = documentsURL.appendingPathComponent(fileName)
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            try? imageData.write(to: fileURL, options: .atomic)
            return fileURL
        }
        return nil
    }
    
    func loadImage(with fileUrlString: String) -> UIImage? {
        guard let url = URL(string: fileUrlString) else { return nil }
        do {
            let imageData = try Data(contentsOf: url)
            return UIImage(data: imageData)
        } catch {
            print("Load Image Error: \(error.localizedDescription)")
        }
        
        return nil
    }
}
