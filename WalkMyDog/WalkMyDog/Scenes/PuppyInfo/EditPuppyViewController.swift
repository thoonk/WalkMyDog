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
    
    var puppyInfo: Puppy?
    var createPuppyViewModel = CreatePuppyViewModel()
    var fetchPuppyViewModel: FetchPuppyViewModel?
    var editPuppyViewModel: EditPuppyViewModel?
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
        
        if puppyInfo == nil {
            boyButton.isSelected = true
            girlButton.isSelected = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        boyButton.alternateBtn = [girlButton]
        girlButton.alternateBtn = [boyButton]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if puppyInfo != nil {
            deleteButton.isEnabled = true

            setFetchViewModelBindings()
            setEditViewModelBindings()
        } else {
            deleteButton.isEnabled = false

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
        createPuppyViewModel.output.enableSaveBtn
            .observe(on: MainScheduler.instance)
            .bind(to: saveButton.rx.isEnabled)
            .disposed(by: bag)
        
        createPuppyViewModel.output.goToSetting
            .observe(on: MainScheduler.instance)
            .bind(onNext: goToSetting)
            .disposed(by: bag)
    }
    
    func setEditViewModelBindings() {
        editPuppyViewModel = EditPuppyViewModel(with: puppyInfo!)
        guard let viewModel = editPuppyViewModel else {
            return
        }
        
        // INPUT
        nameTextField.rx.text.orEmpty
            .bind(to: viewModel.input.name)
            .disposed(by: bag)
        
        speciesTextField.rx.text.orEmpty
            .bind(to: viewModel.input.species)
            .disposed(by: bag)
        
        birthTextField.rx.text.orEmpty
            .bind(to: viewModel.input.age)
            .disposed(by: bag)
        
        weightTextField.rx.text.orEmpty
            .bind(to: viewModel.input.weight)
            .disposed(by: bag)
        
        boyButton.rx.tap
            .bind(to: viewModel.input.boyBtnTapped)
            .disposed(by: bag)
        
        girlButton.rx.tap
            .bind(to: viewModel.input.girlBtnTapped)
            .disposed(by: bag)
        
        saveButton.rx.tap
            .bind(to: viewModel.input.saveBtnTapped)
            .disposed(by: bag)
        
        deleteButton.rx.tap
            .bind(to: viewModel.input.deleteBtnTapped)
            .disposed(by: bag)
        
        // OUTPUT
        viewModel.output.enableSaveBtn
            .observe(on: MainScheduler.instance)
            .bind(to: saveButton.rx.isEnabled)
            .disposed(by: bag)
        
        viewModel.output.errorMessage
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] msg in
                self?.showAlert("Firestore 오류", msg)
            }).disposed(by: bag)
        
        viewModel.output.goToSetting
            .observe(on: MainScheduler.instance)
            .bind(onNext: goToSetting)
            .disposed(by: bag)
        
    }
    
    func setFetchViewModelBindings() {
        fetchPuppyViewModel = FetchPuppyViewModel(with: puppyInfo!)
        guard let viewModel = fetchPuppyViewModel else {
            return
        }
        // OUTPUT
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
