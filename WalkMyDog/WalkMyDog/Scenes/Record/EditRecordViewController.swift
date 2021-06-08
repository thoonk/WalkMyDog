//
//  EditRecordViewController.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/03/05.
//

import UIKit
import RxSwift
import RxCocoa
import JVFloatLabeledTextField

final class EditRecordViewController: UIViewController {
    // MARK: - Interface Builder
    @IBOutlet weak var datePickerTextField: JVFloatLabeledTextField!
    @IBOutlet weak var walkIntervalTextField: JVFloatLabeledTextField!
    @IBOutlet weak var walkDistTextField: JVFloatLabeledTextField!
    @IBOutlet weak var saveRecordButton: UIButton!
    
    // MARK: - Properties
    var checkedPuppy: [Puppy]?
    private var datePicker: UIDatePicker!
    private var editRecordViewModel: EditRecordViewModel?
    private var bag = DisposeBag()
    
    // MARK: - LifeCycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setUI()
        if checkedPuppy != nil {
            setEditRecordBinding()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bag = DisposeBag()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - Actions
    @IBAction func closeBtnTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func goToHome() {
        performSegue(withIdentifier: C.Segue.unwindToHome, sender: self)
    }
    
    @objc
    func doneBtnTapped(sender: Any) {
        self.view.endEditing(true)
    }
    
    @objc
    func dateChanged(sender: UIDatePicker) {
        self.datePickerTextField.text = sender.date.setDateTime()
    }
    
    @objc
    func showPicker() {
        datePickerTextField.becomeFirstResponder()
    }
    
    @objc
    func dismissPicker() {
        datePickerTextField.resignFirstResponder()
    }
    
    // MARK: - Methods
    private func setUI() {
        self.datePicker = UIDatePicker()
        
        let textFieldBar = setKeyboardDoneBtn(for: #selector(doneBtnTapped(sender:)))
        walkIntervalTextField.inputAccessoryView = textFieldBar
        walkDistTextField.inputAccessoryView = textFieldBar
        
        if let picker = self.datePicker {
            picker.sizeToFit()

            picker.datePickerMode = .dateAndTime
            picker.preferredDatePickerStyle = .wheels
            picker.maximumDate = Date()
            picker.addTarget(
                self,
                action: #selector(dateChanged(sender:)),
                for: .valueChanged
            )
            
            let datePickerBar = setKeyboardDoneBtn(for: #selector(dismissPicker))
            datePickerTextField.inputView = picker
            datePickerTextField.inputAccessoryView = datePickerBar
        }
        walkIntervalTextField.rightView = setUnitLabel(inTxtField: "분")
        walkIntervalTextField.rightViewMode = .always
        
        walkDistTextField.rightView = setUnitLabel(inTxtField: "m")
        walkDistTextField.rightViewMode = .always
        
        saveRecordButton.titleLabel?.font = UIFont(name: "NanumGothic", size: 20)
    }
    
    // MARK: - ViewModel Binding
    private func setEditRecordBinding() {
        editRecordViewModel = EditRecordViewModel(with: checkedPuppy!)
        guard let viewModel = editRecordViewModel else { return }
        
        // INPUT
        datePickerTextField.rx.text.orEmpty
            .distinctUntilChanged()
            .bind(to: viewModel.input.timeStamp)
            .disposed(by: bag)
        
        walkIntervalTextField.rx.text.orEmpty
            .distinctUntilChanged()
            .bind(to: viewModel.input.walkedInterval)
            .disposed(by: bag)
        
        walkDistTextField.rx.text.orEmpty
            .distinctUntilChanged()
            .bind(to: viewModel.input.walkedDistance)
            .disposed(by: bag)
        
        saveRecordButton.rx.tap
            .bind(to: viewModel.input.saveBtnTapped)
            .disposed(by: bag)
        
        // OUTPUT
        viewModel.output.enableSaveBtn
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] value in
                self?.saveRecordButton.rx.isEnabled.onNext(value)
                if value == false {
                    self?.saveRecordButton.backgroundColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
                } else {
                    self?.saveRecordButton.backgroundColor = UIColor(named: "customTintColor")
                }
            })
            .disposed(by: bag)
        
        viewModel.output.errorMessage
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] msg in
                let alertVC = AlertManager.shared.showAlert(
                    title: "Firestore 오류",
                    subTitle: msg,
                    actionBtnTitle: "확인"
                )
                self?.present(alertVC, animated: true)
            }).disposed(by: bag)
        
        viewModel.output.goToHome
            .observe(on: MainScheduler.instance)
            .bind(onNext: goToHome)
            .disposed(by: bag)
    }
}
