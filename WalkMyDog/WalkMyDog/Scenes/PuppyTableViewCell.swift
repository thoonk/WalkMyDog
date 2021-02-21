//
//  PuppyTableViewCell.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/21.
//

import UIKit

class PuppyTableViewCell: UITableViewCell {

    @IBOutlet weak var puppyNameLabel: UILabel!
    @IBOutlet weak var puppyAgeLabel: UILabel!
    @IBOutlet weak var puppySpeciesLabel: UILabel!
    @IBOutlet weak var puppyWeightLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
