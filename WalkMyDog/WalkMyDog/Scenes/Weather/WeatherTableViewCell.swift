//
//  WeatherTableViewCell.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/16.
//

import UIKit

class WeatherTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var morningPMLabel: UILabel!
    @IBOutlet weak var launchPMLabel: UILabel!
    @IBOutlet weak var dinnerPMLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
