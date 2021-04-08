//
//  SearchSpeciesViewModel.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/04/08.
//

import RxSwift
import RxCocoa

class SearchSpeciesViewModel: ViewModelType {
    
    var bag: DisposeBag = DisposeBag()
    var input = Input()
    var output = Output()

    struct Input {
        var searchingText = PublishSubject<String>()
        var isSearchActive = PublishSubject<Bool>()
    }
    
    struct Output {
        var searchResult = BehaviorRelay<[String]>(value: C.PuppyInfo.species)
    }
    
    init() {
        input.searchingText
            .subscribe(onNext: { [weak self] text in
                if text == "" {
                    self?.output.searchResult.accept(C.PuppyInfo.species)
                } else {
                    let result = self?.filterSpecies(from: text)
                    self?.output.searchResult.accept(result ?? [])
                }
            })
            .disposed(by: bag)
    }
    
    private func filterSpecies(from inputText: String) -> [String] {
        let searchResults = C.PuppyInfo.species.filter {
            let match = $0.range(of: inputText, options: .caseInsensitive)
            return match != nil
        }
        return searchResults
    }
}
