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
    
    var viewModel: EditPuppyViewModel?
    var bag = DisposeBag()
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var speciesTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var birthTextField: UITextField!
    @IBOutlet weak var boyButton: RadioButton!
    @IBOutlet weak var girlButton: RadioButton!
    
    override func awakeFromNib() {
        self.view.layoutIfNeeded()
        
        if viewModel == nil {
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
        setBindings()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bag = DisposeBag()
    }
    
    func setBindings() {
        
        guard let viewModel = viewModel
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
}
