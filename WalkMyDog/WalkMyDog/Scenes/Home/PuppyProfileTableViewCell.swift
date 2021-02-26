//
//  PuppyProfileTableViewCell.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/26.
//

import UIKit

class PuppyProfileTableViewCell: UITableViewCell {

    @IBOutlet weak var puppyProfileView: UIView!
    @IBOutlet weak var puppyImageView: UIImageView!
    @IBOutlet weak var puppyNameLabel: UILabel!
    @IBOutlet weak var puppyGenderImageView: UIImageView!
    @IBOutlet weak var puppySpeciesLabel: UILabel!
    @IBOutlet weak var puppyAgeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        puppyProfileView.layer.cornerRadius = 10
        puppyProfileView.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        
        puppyImageView.layoutIfNeeded()
        puppyImageView.layer.cornerRadius = puppyImageView.frame.height / 2.0
        puppyImageView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bindData(with data: Puppy) {
        puppyImageView.image = UIImage(named: "ang")
        puppyNameLabel.text = data.name
        puppySpeciesLabel.text = data.species
        puppyAgeLabel.text = "\(Date().computeAge(with: data.age).description) 살"
        
        if data.gender == true {
            puppyGenderImageView.image = UIImage(named: "male")
        } else {
            puppyGenderImageView.image = UIImage(named: "female")
        }
    }
}
