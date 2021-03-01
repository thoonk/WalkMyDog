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
import FirebaseStorage

class EditPuppyViewController: UIViewController {
    
    var puppyInfo: Puppy?
    var createPuppyViewModel = CreatePuppyViewModel()
    var fetchPuppyViewModel: FetchPuppyViewModel?
    var editPuppyViewModel: EditPuppyViewModel?
    var bag = DisposeBag()
        
    lazy var imagePicker: UIImagePickerController = {
        let picker: UIImagePickerController = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        return picker
    }()
    
    lazy var profileImage: Observable<UIImage?> = profileImageView.rx.observe(UIImage.self, "image")
    
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var speciesTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var birthTextField: UITextField!
    @IBOutlet weak var boyButton: RadioButton!
    @IBOutlet weak var girlButton: RadioButton!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIButton!
    
    @objc
    func tapSelectImage(_ sender: Any){
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    
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
        
        let tapGestureImageView = UITapGestureRecognizer(target: self, action: #selector(tapSelectImage))
        profileImageView.addGestureRecognizer(tapGestureImageView)
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
    
    func setUI() {
        deleteButton.layer.cornerRadius = 10
        deleteButton.layer.borderWidth = 1.0
        deleteButton.layer.borderColor = UIColor.black.cgColor
        deleteButton.layer.masksToBounds = true
        
        if puppyInfo != nil {
            deleteButton.isHidden = false

            setFetchViewModelBindings()
            setEditViewModelBindings()
        } else {
            deleteButton.isHidden = true

            setCreateViewModelBindings()
        }
    }
    
    func setCreateViewModelBindings() {
        
        // INPUT
        profileImage
            .subscribe(onNext: { image in
                self.createPuppyViewModel.input.profileImage.onNext(image!)
            }).disposed(by: bag)
        
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
        profileImage
            .subscribe(onNext: { image in
                viewModel.input.profileImage.onNext(image!)
            }).disposed(by: bag)
        
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
        viewModel.output.profileImage
            .map { UIImage(data: $0)}
            .bind(to: profileImageView.rx.image)
            .disposed(by: bag)
        
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

extension EditPuppyViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        self.profileImageView.image = image
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
}
