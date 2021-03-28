//
//  EditPuppyViewModelTests.swift
//  WalkMyDogTests
//
//  Created by 김태훈 on 2021/03/26.
//

import XCTest
import RxTest
import RxBlocking
import RxSwift
import Nimble
@testable import WalkMyDog

class EditPuppyViewModelTests: XCTestCase {

    var viewModel: EditPuppyViewModel!
    var puppyData: Puppy!
    var bag: DisposeBag!
    var scheduler: TestScheduler!
    
    override func setUp() {
        super.setUp()

        viewModel = EditPuppyViewModel()
        bag = DisposeBag()
        scheduler = TestScheduler(initialClock: 0)
    }
    
    override func tearDown() {
        viewModel = nil
        bag = DisposeBag()
        scheduler = nil
        super.tearDown()
    }
    
    func testEnableSaveBtn() {
        scheduler.createHotObservable([.next(1, ""), .next(3, "name"), .next(5, "이름"), .next(7, "강쥐"), .next(9, "테스트")])
            .bind(to: viewModel.input.name)
            .disposed(by: bag)
        
        scheduler.createHotObservable([.next(1, "8.0"), .next(3, ""), .next(5, "12"), .next(7, "9.2"), .next(9, "10")])
            .bind(to: viewModel.input.weight)
            .disposed(by: bag)
        
        scheduler.createHotObservable([.next(1, "2015년 2월 3일"), .next(3, "2021년 1월 25일"), .next(5, ""), .next(7, "2020년 9월 5일"), .next(9, "2019년 3월 1일")])
            .bind(to: viewModel.input.age)
            .disposed(by: bag)
        
        scheduler.createHotObservable([.next(1, "견종"), .next(3, "퍼그"), .next(5, "치와와"), .next(7, ""), .next(9, "시추")])
            .bind(to: viewModel.input.species)
            .disposed(by: bag)
        
        scheduler.start()
        
        let observer = scheduler.createObserver(Bool.self)
        viewModel.output.enableSaveBtn
            .subscribe(observer)
            .disposed(by: bag)
        
        expect(observer.events).to(equal([.next(9, true)]))
    }
}

