//
//  PuppyTableViewCell.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/21.
//

import UIKit

class PuppyTableViewCell: UITableViewCell {

    @IBOutlet weak var puppyNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
    }
    
    func bindData(with data: Puppy) {
        puppyNameLabel.text = data.name
    }
}
