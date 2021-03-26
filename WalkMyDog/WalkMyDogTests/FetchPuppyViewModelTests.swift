//
//  FetchPuppyViewModelTests.swift
//  WalkMyDogTests
//
//  Created by 김태훈 on 2021/03/26.
//

import XCTest
import RxSwift
import RxTest
import RxBlocking
@testable import WalkMyDog

class FetchPuppyViewModelTests: XCTestCase {
    
    var viewModel: FetchPuppyViewModel!
    var puppyData: Puppy!
    var bag: DisposeBag!
    
    override func setUp() {
        super.setUp()
        puppyData = Puppy(name: "앙꼬", age: "2016년 12월 11일", gender: true, weight: 5, species: "퍼그")
        viewModel = FetchPuppyViewModel(with: puppyData)
        bag = DisposeBag()
    }
    
    override func tearDown() {
        viewModel = nil
        bag = DisposeBag()
        super.tearDown()
    }
    
    func testFetchPuppyViewModel() {
        let name = viewModel.output.puppyNameText
        let birth = viewModel.output.puppyBirthText
        let gender = viewModel.output.puppyGender
        let weight = viewModel.output.puppyWeightText
        let species = viewModel.output.puppySpeciesText
        
        XCTAssertEqual(try! name.toBlocking().first(), "앙꼬")
        XCTAssertEqual(try! birth.toBlocking().first(), "2016년 12월 11일")
        XCTAssertEqual(try! gender.toBlocking().first(), true)
        XCTAssertEqual(try! weight.toBlocking().first(), "5.0")
        XCTAssertEqual(try! species.toBlocking().first(), "퍼그")
    }
}
