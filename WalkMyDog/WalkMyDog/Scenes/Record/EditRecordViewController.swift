//
//  EditRecordViewController.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/03/05.
//

import UIKit
import RxSwift
import RxCocoa

class EditRecordViewController: UIViewController {
    
    @IBOutlet weak var datePickerTextField: UITextField!
    @IBOutlet weak var walkIntervalTextField: UITextField!
    @IBOutlet weak var walkDistTextField: UITextField!
    @IBOutlet weak var addRecordButton: UIButton!
    
    @IBAction func closeBtnTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    var checkedPuppy: [Puppy]?
    private var datePicker: UIDatePicker!
    private var editRecordViewModel: EditRecordViewModel?
    private var bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
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
    
    private func setEditRecordBinding() {
        editRecordViewModel = EditRecordViewModel(with: checkedPuppy!)
        guard let viewModel = editRecordViewModel else { return }
        
        // INPUT
        datePickerTextField.rx.text.orEmpty
            .bind(to: viewModel.input.timeStamp)
            .disposed(by: bag)
        
        walkIntervalTextField.rx.text.orEmpty
            .bind(to: viewModel.input.walkedInterval)
            .disposed(by: bag)
        
        walkDistTextField.rx.text.orEmpty
            .bind(to: viewModel.input.walkedDistance)
            .disposed(by: bag)
        
        addRecordButton.rx.tap
            .bind(to: viewModel.input.saveBtnTapped)
            .disposed(by: bag)
        
        // OUTPUT
        viewModel.output.enableSaveBtn
            .observe(on: MainScheduler.instance)
            .bind(to: addRecordButton.rx.isEnabled)
            .disposed(by: bag)
        
        viewModel.output.errorMessage
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] msg in
                self?.showAlert("Firestore 오류", msg)
            }).disposed(by: bag)
        
        viewModel.output.goToHome
            .observe(on: MainScheduler.instance)
            .bind(onNext: goToHome)
            .disposed(by: bag)
    }
    
    private func setUI() {
        self.datePicker = UIDatePicker()
        
        let textFieldBar = setKeyboardDoneBtn(for: #selector(doneBtnTapped(sender:)))
        walkIntervalTextField.inputAccessoryView = textFieldBar
        walkDistTextField.inputAccessoryView = textFieldBar
        
        if let picker = self.datePicker {
            picker.sizeToFit()

            picker.datePickerMode = .dateAndTime
            picker.preferredDatePickerStyle = .wheels
            picker.addTarget(self, action: #selector(dateChanged(sender:)), for: .valueChanged)
            
            let datePickerBar = setKeyboardDoneBtn(for: #selector(dismissPicker))
            datePickerTextField.inputView = picker
            datePickerTextField.inputAccessoryView = datePickerBar
        }
    }
    
    private func goToHome() {
        let homeVC = self.storyboard?.instantiateViewController(identifier: "HomeVC") as! HomeViewController
        let navigationController = UINavigationController(rootViewController: homeVC)
        navigationController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        self.present(navigationController, animated: true, completion: nil)
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
}
