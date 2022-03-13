//
//  ImagePicker.swift
//  WalkMyDog
//
//  Created by thoonk on 2022/03/13.
//

import UIKit

protocol ImagePickerDelegate: AnyObject {
    func didSelect(image: UIImage?)
}

enum ImagePickerType {
    case camera
    case library
    case both
}

/// 로컬 디바이스의 이미지 가져오는 클래스
class ImagePicker: NSObject {
    // MARK: - Properties
    private let pickerController: UIImagePickerController
    private weak var presentationController: UIViewController?
    private weak var delegate: ImagePickerDelegate?
    
    // MARK: - Init
    init(presentationController: UIViewController, delegate: ImagePickerDelegate) {
        self.pickerController = UIImagePickerController()
        
        super.init()
        
        self.presentationController = presentationController
        self.delegate = delegate
        self.pickerController.delegate = self
//        self.pickerController.allowsEditing = true
        self.pickerController.mediaTypes = ["public.image"]
    }
    
    // MARK: - Methods
    private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return nil
        }
        
        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            self.pickerController.sourceType = type
            self.presentationController?.present(self.pickerController, animated: true)
        }
    }
    
    private func action(for type: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return
        }
        
        self.pickerController.sourceType = type
        self.presentationController?.present(self.pickerController, animated: true)
    }
    
    func present(pickerType: ImagePickerType) {
        switch pickerType {
        case .camera:
            self.action(for: .camera)
        case .library:
            self.action(for: .photoLibrary)
        case .both:
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            if let action = self.action(for: .camera, title: "Camera") {
                alert.addAction(action)
            }
            
            if let action = self.action(for: .photoLibrary, title: "Photo Library") {
                alert.addAction(action)
            }
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.presentationController?.present(alert, animated: true)
        }
    }
    
    private func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage?) {
        self.delegate?.didSelect(image: image)
        controller.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension ImagePicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.pickerController(picker, didSelect: nil)
    }
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        guard let image = info[.originalImage] as? UIImage else {
            return self.pickerController(picker, didSelect: nil)
        }
        self.pickerController(picker, didSelect: image)
    }
}

