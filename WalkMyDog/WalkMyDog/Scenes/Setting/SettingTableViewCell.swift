//
//  SettingTableViewCell.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/04/01.
//

import UIKit

class SettingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!

    func bindData(title: String, subTitle: String) {
        titleLabel.text = title
        subTitleLabel.text =  UserDefaults.standard.string(forKey: "pmRcmdCriteria")
    }
}
