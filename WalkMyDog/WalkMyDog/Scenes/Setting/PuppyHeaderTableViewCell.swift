//
//  PuppyHeaderTableViewCell.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/04/03.
//

import UIKit

class PuppyHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var createButton: UIButton!
    
    func bindData(with title: String) {
        titleLabel.text = title
    }
}
