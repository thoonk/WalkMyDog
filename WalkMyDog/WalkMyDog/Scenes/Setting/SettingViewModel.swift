//
//  SettingViewModel.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/04/02.
//

import RxSwift
import RxCocoa
import RxDataSources

enum SectionItem {
    case settingItem(title: String, subTitle: String)
    case puppyItem(puppy: Puppy)
}

enum SettingSectionModel {
    case settingSection(title: String, items: [SectionItem])
    case puppySection(title: String, items: [SectionItem])
}

class SettingViewModel: ViewModelType {
    
    var bag: DisposeBag = DisposeBag()
    var input: Input
    var output: Output
    var puppyRealmService: PuppyRealmServiceProtocol
    
    struct Input {
        var fetchData: AnyObserver<Void>
    }
    
    struct Output {
        let isLoading: BehaviorSubject<Bool>
        var puppyData: PublishRelay<[Puppy]>
        let cellData: PublishRelay<[SettingSectionModel]>
        var errorMessage: PublishRelay<String>
    }
    
    init(puppyRealmService: PuppyRealmServiceProtocol = PuppyRealmService()){
        self.puppyRealmService = puppyRealmService
        
        let fetching = PublishSubject<Void>()
        let fetchData: AnyObserver<Void> = fetching.asObserver()
        let isLoading = BehaviorSubject<Bool>(value: false)
        let puppyData = PublishRelay<[Puppy]>()
        let error = PublishRelay<String>()
        let cellData = PublishRelay<[SettingSectionModel]>()

        input = Input(fetchData: fetchData)
                
        fetching
            .do(onNext: { _ in isLoading.onNext(true) })
            .flatMapLatest { _ in
                puppyRealmService.fetchAllPuppies()
            }
            .do(onNext: { _ in isLoading.onNext(false) })
            .subscribe(onNext: { data in
                let settingItem: [SectionItem] = [.settingItem(title: "산책 추천도", subTitle: "좋음"),]
                
                var puppyItem = [SectionItem]()
                data.forEach {
                    puppyItem.append(.puppyItem(puppy: $0))
                }
                
                let sectionData: [SettingSectionModel] = [
                    .settingSection(title: "설정", items: settingItem),
                    .puppySection(title: "반려견", items: puppyItem)
                ]
                
                cellData.accept(sectionData)
            })
            .disposed(by: bag)
        
//        fetching
//            .debug()
//            .do(onNext: { _ in isLoading.onNext(true) })
//            .flatMapLatest { _ in
//                FIRStoreManager.shared.fetchAllPuppyInfo()
//            }
//            .do(onNext: { _ in isLoading.onNext(false) })
//            .subscribe(onNext: { data in
//                let settingItem: [SectionItem] = [
//                    .SettingItem(title: "산책 추천도", subTitle: "좋음")
//                ]
//                sectionData.append(.SettingSection(title: "설정", items: settingItem))
//
//                var puppyItem = [SectionItem]()
//                data.forEach {
//                    puppyItem.append(.PuppyItem(puppy: $0))
//                }
//                sectionData.append(.PuppySection(title: "반려견", items: puppyItem))
//
//                print(sectionData)
//                cellData.accept(sectionData)
//            }, onError: { err in
//                error.accept(err.localizedDescription)
//            })
//            .disposed(by: bag)
        
        output = Output(
            isLoading: isLoading,
            puppyData: puppyData,
            cellData: cellData,
            errorMessage: error
        )
    }
}

extension SettingSectionModel: SectionModelType {
    typealias Item = SectionItem
    
    var title: String {
        switch self {
        case .settingSection(title: let title, items: _):
            return title
        case .puppySection(title: let title, items: _):
            return title
        }
    }
    
    var items: [SectionItem] {
        switch self {
        case .settingSection(title: _, items: let items):
            return items.map { $0 }
        case .puppySection(title: _, items: let items):
            return items.map { $0 }
        }
    }
    
    init(original: SettingSectionModel, items: [Item]) {
        switch original {
        case .settingSection(let title, _):
            self = .settingSection(title: title, items: items)
        case .puppySection(let title, _):
            self = .puppySection(title: title, items: items)
        }
    }
}
