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
    case SettingItem(title: String, subTitle: String)
    case PuppyItem(puppy: Puppy)
}

enum SettingSectionModel {
    case SettingSection(title: String, items: [SectionItem])
    case PuppySection(title: String, items: [SectionItem])
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
        
        var sectionData = [SettingSectionModel]()
        
        fetching
            .do(onNext: { _ in isLoading.onNext(true) })
            .flatMapLatest { _ in
                puppyRealmService.fetchAllPuppies()
            }
            .debug()
            .do(onNext: { _ in isLoading.onNext(false) })
            .subscribe(onNext: { data in
                let settingItem: [SectionItem] = [.SettingItem(title: "산책 추천도", subTitle: "좋음")]
                sectionData.append(.SettingSection(title: "설정", items: settingItem))
                
                var puppyItem = [SectionItem]()
                data.forEach {
                    puppyItem.append(.PuppyItem(puppy: $0))
                }
                sectionData.append(.PuppySection(title: "반려견", items: puppyItem))
                
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
        case .SettingSection(title: let title, items: _):
            return title
        case .PuppySection(title: let title, items: _):
            return title
        }
    }
    
    var items: [SectionItem] {
        switch self {
        case .SettingSection(title: _, items: let items):
            return items.map { $0 }
        case .PuppySection(title: _, items: let items):
            return items.map { $0 }
        }
    }
    
    init(original: SettingSectionModel, items: [Item]) {
        switch original {
        case .SettingSection(let title, _):
            self = .SettingSection(title: title, items: items)
        case .PuppySection(let title, _):
            self = .PuppySection(title: title, items: items)
        }
    }
}
