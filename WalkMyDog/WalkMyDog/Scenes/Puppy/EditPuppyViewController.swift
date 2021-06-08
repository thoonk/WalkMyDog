//
//  EditPuppyViewController.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/22.
//

import UIKit
import RxSwift
import RxCocoa
import Photos
import Kingfisher
import Foundation
import JVFloatLabeledTextField

class EditPuppyViewController: UIViewController, UIGestureRecognizerDelegate {
    // MARK: - Interface Builder
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameTextField: JVFloatLabeledTextField!
    @IBOutlet weak var speciesTextField: CustomTextField!
    @IBOutlet weak var weightTextField: JVFloatLabeledTextField!
    @IBOutlet weak var birthTextField: JVFloatLabeledTextField!
    @IBOutlet weak var boyButton: RadioButton!
    @IBOutlet weak var girlButton: RadioButton!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIButton!
    
    // MARK: - Properties
    var puppyInfo: Puppy?
    private var fetchPuppyViewModel: FetchPuppyViewModel?
    private var editPuppyViewModel: EditPuppyViewModel?
    private var selectedSpecies: String?
    private var bag = DisposeBag()
    private var datePicker: UIDatePicker!
        
    lazy var imagePicker: UIImagePickerController = {
        let picker: UIImagePickerController = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        return picker
    }()
    
    lazy var profileImage: Observable<UIImage?> = profileImageView.rx.observe(UIImage.self, "image")
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == C.Segue.editToSearch,
           let searchSpeciesVC = segue.destination as? SearchSpeciesViewController {
            searchSpeciesVC.delegate = self
        }
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        boyButton.alternateBtn = [girlButton]
        girlButton.alternateBtn = [boyButton]
        
        let tapGestureImageView = UITapGestureRecognizer(
            target: self,
            action: #selector(tapSelectImage)
        )
        profileImageView.addGestureRecognizer(tapGestureImageView)
        speciesTextField.addTarget(
            self,
            action: #selector(selectSpecies),
            for: .touchDown
        )
        deleteButton.addTarget(
            self,
            action: #selector(deleteBtnTapped),
            for: .touchUpInside
        )
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bag = DisposeBag()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func awakeFromNib() {
        self.view.layoutIfNeeded()
        
        if puppyInfo == nil {
            boyButton.isSelected = true
            girlButton.isSelected = false
        }
    }
    
    // MARK: - Actions
    @objc
    private func tapSelectImage(_ sender: Any){
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    
    @objc
    private func doneBtnTapped(sender: Any) {
        self.view.endEditing(true)
    }
    
    @objc
    private func dateChanged(sender: UIDatePicker) {
        self.birthTextField.text = sender.date.setDate()
    }
    
    @objc
    private func showPicker() {
        birthTextField.becomeFirstResponder()
    }
    
    @objc
    private func dismissPicker() {
        birthTextField.resignFirstResponder()
    }
    
    @objc
    private func selectSpecies() {
        self.performSegue(withIdentifier: C.Segue.editToSearch, sender: nil)
    }
    
    @objc
    private func deleteBtnTapped() {
        let alertVC = AlertManager.shared.showAlert(
            title: "강아지 정보 삭제",
            subTitle: "정말로 삭제하시겠습니까?",
            actionBtnTitle: "삭제",
            cancelBtnTitle: "취소"
        ) { [weak self] in
            self?.editPuppyViewModel?.input.deleteBtnTapped.onNext(())
        }
        present(alertVC, animated: true)
    }
    
    // MARK: - Methods
    private func setUI() {
        deleteButton.layer.cornerRadius = 12
        deleteButton.layer.masksToBounds = true
        deleteButton.backgroundColor = .systemGray5
        
        profileImageView.layer.cornerRadius = profileImageView.bounds.height/2
        profileImageView.image = UIImage(named: "profileImage-150")
                
        weightTextField.rightView = setUnitLabel(inTxtField: " kg")
        weightTextField.rightViewMode = .always
        weightTextField.placeholder = "체중"
        nameTextField.placeholder = "이름"
        speciesTextField.placeholder = "견종"
        birthTextField.placeholder = "생년월일"
        nameTextField.floatingLabelActiveTextColor = UIColor(named: "customTintColor")
        speciesTextField.floatingLabelActiveTextColor = UIColor(named: "customTintColor")
        weightTextField.floatingLabelActiveTextColor = UIColor(named: "customTintColor")
        birthTextField.floatingLabelActiveTextColor = UIColor(named: "customTintColor")

        if puppyInfo != nil {
            deleteButton.isHidden = false
            setFetchViewModelBindings()
        } else {
            deleteButton.isHidden = true
        }
        setEditViewModelBindings()

        self.datePicker = UIDatePicker()
        
        let textFieldBar = setKeyboardDoneBtn(for: #selector(doneBtnTapped(sender:)))
        nameTextField.inputAccessoryView = textFieldBar
        speciesTextField.inputAccessoryView = textFieldBar
        weightTextField.inputAccessoryView = textFieldBar
        
        if let picker = self.datePicker {
            picker.sizeToFit()
            
            picker.datePickerMode = .date
            picker.preferredDatePickerStyle = .wheels
            picker.maximumDate = Date()
            picker.addTarget(
                self,
                action: #selector(dateChanged(sender:)),
                for: .valueChanged
            )
            
            let datePickerBar = setKeyboardDoneBtn(for: #selector(dismissPicker))
            birthTextField.inputView = picker
            birthTextField.inputAccessoryView = datePickerBar
        }
        
        if selectedSpecies != nil {
            print(selectedSpecies!)
            if selectedSpecies == "직접 입력" {
                speciesTextField.becomeFirstResponder()
            } else {
                speciesTextField.text = selectedSpecies
            }
        }
        
        setCustomBackBtn()
        
        let customFont = UIFont(name: "NanumGothic", size: 17)
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: customFont!
        ]
        
        saveButton.setTitleTextAttributes(
            [NSAttributedString.Key.font: customFont!],
            for: .normal
        )
    }
    
    private func goToSetting() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - ViewModel Binding
    func setEditViewModelBindings() {
        editPuppyViewModel = EditPuppyViewModel(with: puppyInfo)
        guard let viewModel = editPuppyViewModel else {
            return
        }
        
        // INPUT
        profileImage
            .debug()
            .subscribe(onNext: { image in
                if self.profileImageView.image != UIImage(named: "profileImage-150") {
                    viewModel
                        .input
                        .profileImage
                        .onNext(image ?? UIImage(named: "profileImage-150"))
                } else {
                    viewModel
                        .input
                        .profileImage
                        .onNext(nil)
                }
            }).disposed(by: bag)
        
        nameTextField.rx.text.orEmpty
            .distinctUntilChanged()
            .bind(to: viewModel.input.name)
            .disposed(by: bag)
        
        speciesTextField.rx.text.orEmpty
            .distinctUntilChanged()
            .bind(to: viewModel.input.species)
            .disposed(by: bag)
        
        birthTextField.rx.text.orEmpty
            .distinctUntilChanged()
            .bind(to: viewModel.input.age)
            .disposed(by: bag)
        
        weightTextField.rx.text.orEmpty
            .distinctUntilChanged()
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
        
        // OUTPUT
        viewModel.output.enableSaveBtn
            .observe(on: MainScheduler.instance)
            .bind(to: saveButton.rx.isEnabled)
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
        viewModel.output.profileImageUrl
            .subscribe(onNext: { urlString in
                if urlString != nil {
                    self.profileImageView.setImageCache(with: urlString!)
                } else {
                    self.profileImageView.image = UIImage(named: "profileImage-150")
                }
            }).disposed(by: bag)
        
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

// MARK: - ImagePickerController, NavigationController
extension EditPuppyViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        guard let image = info[UIImagePickerController.InfoKey.editedImage]
                as? UIImage else { return }
        self.profileImageView.image = image
        editPuppyViewModel?.input.profileImage.onNext(image)
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - SelectSpeciesDelegate
extension EditPuppyViewController: SelectSpeciesDelegate {
    func didSelectSpecies(with species: String) {
        self.selectedSpecies = species
    }
}
