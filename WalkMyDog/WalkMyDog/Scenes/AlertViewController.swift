//
//  AlertViewController.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/03/22.
//

import UIKit
import Foundation

class AlertViewController: UIViewController {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBAction func cancelBtnTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionBtnTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        onActionBtn?()
    }

    var alertTitle = ""
    var alertSubTitle = ""
    var actionBtnTitle = ""
    var cancelBtnTitle: String?
    var onActionBtn: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    func setUI() {
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
        
        titleLabel.text = alertTitle
        subTitleLabel.text = alertSubTitle
        actionButton.setTitle(actionBtnTitle, for: .normal)
        
        if cancelBtnTitle == nil {
            cancelButton.isHidden = true
        } else {
            cancelButton.setTitle(cancelBtnTitle, for: .normal)
        }
    }
}
