//
//  WalkStartCountViewModel.swift
//  WalkMyDog
//
//  Created by thoonk on 2022/07/07.
//

import Foundation
import RxSwift
import RxRelay

final class WalkStartCountViewModel: ViewModelType {
    var bag: DisposeBag = DisposeBag()
    
    struct Input {
        
    }

    struct Output {
        let timerCount = PublishRelay<Int>()
        let presentToWalk = PublishRelay<Void>()
    }
    
    var input = Input()
    var output = Output()
    let imageService: ImageServiceProtocol
    
    init(
        selectedPuppies: [Puppy],
        imageService: ImageServiceProtocol = ImageService()
    ) {
        self.imageService = imageService
        
        let totalCount = 3
        Observable<Int>.timer(.seconds(0), period: .seconds(1), scheduler: MainScheduler.instance)
            .take(totalCount + 1)
            .subscribe(onNext: { [weak self] timePassed in
                let currentCount = totalCount - timePassed
                if currentCount > 0 {
                    self?.output.timerCount.accept(currentCount)
                }
            }, onCompleted: { [weak self] in
                self?.output.presentToWalk.accept(())
            })
            .disposed(by: bag)
    }
}
