//
//  SettingHeaderTableViewCell.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/04/04.
//

import UIKit

class SettingHeaderTableViewCell: UITableViewCell {
    static let identifier = "SettingHeaderTableViewCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    

    func bindData(with title: String) {
        titleLabel.text = title
    }
}
