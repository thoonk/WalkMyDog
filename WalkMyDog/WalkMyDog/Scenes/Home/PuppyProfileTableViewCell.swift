//
//  PuppyProfileTableViewCell.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/26.
//

import UIKit
import Kingfisher

class PuppyProfileTableViewCell: UITableViewCell {

    @IBOutlet weak var puppyProfileView: UIView!
    @IBOutlet weak var puppyImageView: UIImageView!
    @IBOutlet weak var puppyNameLabel: UILabel!
    @IBOutlet weak var puppyGenderImageView: UIImageView!
    @IBOutlet weak var puppySpeciesLabel: UILabel!
    @IBOutlet weak var puppyAgeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        puppyProfileView.layer.cornerRadius = 10
        puppyProfileView.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        
        puppyImageView.layoutIfNeeded()
        puppyImageView.layer.cornerRadius = puppyImageView.frame.height / 2.0
        puppyImageView.layer.masksToBounds = true
    }
    
    func bindData(with data: Puppy) {
        if data.imageUrl != nil {
            puppyImageView.setImage(with: data.imageUrl!)
        } else {
            puppyImageView.image = UIImage(named: "profileImage-100")
        }
        
        puppyNameLabel.text = data.name
        puppySpeciesLabel.text = data.species
        puppyAgeLabel.text = "\(Date().computeAge(with: data.age).description) 살"
        
        if data.gender == true {
            puppyGenderImageView.image = UIImage(named: "male-24")
        } else {
            puppyGenderImageView.image = UIImage(named: "female-24")
        }
    }
}
