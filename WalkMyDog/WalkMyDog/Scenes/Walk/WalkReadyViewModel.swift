//
//  WalkReadyViewModel.swift
//  WalkMyDog
//
//  Created by thoonk on 2022/04/03.
//

import Foundation
import RxSwift
import CoreLocation
import RxRelay

final class WalkReadyViewModel: ViewModelType {
    var bag: DisposeBag = DisposeBag()
    
    struct Input {
        let location: ReplaySubject<CLLocation?>
        let startWalkingButtonTapped: PublishSubject<Void>
    }
    
    struct Output {
        let location = PublishRelay<CLLocationCoordinate2D>()
        let presentToWalk = PublishRelay<[Puppy]>()
    }
    
    var input: Input
    var output = Output()
    
    var selectedPuppies: [Puppy] = [
        Puppy(name: "앙꼬", age: "2016.12.11", gender: false, weight: 10.5, species: "퍼그")
    ]
    
    init() {
        let startWalkingButtonTapped = PublishSubject<Void>()
        
        input = Input(
            location: LocationManager.shared.location,
            startWalkingButtonTapped: startWalkingButtonTapped
         )
        
        input.location
            .bind { [weak self] loc in
                if let loc = loc,
                   loc.coordinate.isDefaultCoordinate == false {
                    self?.output.location.accept(loc.coordinate)
                }
            }
            .disposed(by: bag)
        
        input.startWalkingButtonTapped
            .subscribe(onNext: { [weak self] in
                if let puppies = self?.selectedPuppies {
                    self?.output.presentToWalk.accept(puppies)
                } else {
                    // 에러 메시지
                }
            })
            .disposed(by: bag)
    }
}
