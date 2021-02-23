//
//  EditPuppyViewController.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/22.
//

import UIKit
import RxSwift
import RxCocoa

class EditPuppyViewController: UIViewController {
    
    var fetchPuppyViewModel: FetchPuppyViewModel?
    var createPuppyViewModel = CreatePuppyViewModel()
    var editPuppyViewModel = EditPuppyViewModel()
    var bag = DisposeBag()
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var speciesTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var birthTextField: UITextField!
    @IBOutlet weak var boyButton: RadioButton!
    @IBOutlet weak var girlButton: RadioButton!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    override func awakeFromNib() {
        self.view.layoutIfNeeded()
        
        if fetchPuppyViewModel == nil {
            boyButton.isSelected = true
            girlButton.isSelected = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        boyButton.alternateBtn = [girlButton]
        girlButton.alternateBtn = [boyButton]
        
        if fetchPuppyViewModel == nil {
            deleteButton.isEnabled = false
        } else {
            deleteButton.isEnabled = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if fetchPuppyViewModel != nil {
            setFetchViewModelBindings()
            setEditViewModelBindings()
        } else {
            setCreateViewModelBindings()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bag = DisposeBag()
    }
    
    func setCreateViewModelBindings() {
        
        // INPUT
        nameTextField.rx.text.orEmpty
            .bind(to: createPuppyViewModel.input.name)
            .disposed(by: bag)
        
        speciesTextField.rx.text.orEmpty
            .bind(to: createPuppyViewModel.input.species)
            .disposed(by: bag)
        
        birthTextField.rx.text.orEmpty
            .bind(to: createPuppyViewModel.input.age)
            .disposed(by: bag)
        
        weightTextField.rx.text.orEmpty
            .bind(to: createPuppyViewModel.input.weight)
            .disposed(by: bag)
        
        boyButton.rx.tap
            .bind(to: createPuppyViewModel.input.boyBtnTapped)
            .disposed(by: bag)
        
        girlButton.rx.tap
            .bind(to: createPuppyViewModel.input.girlBtnTapped)
            .disposed(by: bag)
        
        saveButton.rx.tap
            .bind(to: createPuppyViewModel.input.saveBtnTapped)
            .disposed(by: bag)
        
        // OUTPUT
        createPuppyViewModel.output.enableAddBtn
            .map { $0 }
            .observe(on: MainScheduler.instance)
            .bind(to: saveButton.rx.isEnabled)
            .disposed(by: bag)
        
        createPuppyViewModel.output.goToSetting
            .observe(on: MainScheduler.instance)
            .bind(onNext: goToSetting)
            .disposed(by: bag)
    }
    
    func setEditViewModelBindings() {
        
    }
    
    func setFetchViewModelBindings() {
        
        guard let viewModel = fetchPuppyViewModel
        else {
            self.showAlert("반려견 정보 로딩 실패", "반려견 정보를 불러올 수 없습니다.")
            return }
        
        viewModel.output.puppyNameText
            .bind(to: nameTextField.rx.text)
            .disposed(by: bag)
            
        viewModel.output.puppySpeciesText
            .bind(to: speciesTextField.rx.text)
            .disposed(by: bag)
        
        viewModel.output.puppyWeightText
            .bind(to: weightTextField.rx.text)
            .disposed(by: bag)
        
        viewModel.output.puppyBirthText
            .bind(to: birthTextField.rx.text)
            .disposed(by: bag)
        
        viewModel.output.puppyGender
            .bind(to: boyButton.rx.isSelected)
            .disposed(by: bag)
        
        viewModel.output.puppyGender
            .map { !$0 }
            .bind(to: girlButton.rx.isSelected)
            .disposed(by: bag)
    }
    
    func goToSetting() {
        navigationController?.popViewController(animated: true)
    }
}
