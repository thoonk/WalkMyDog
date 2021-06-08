//
//  CheckPuppyTableViewCell.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/03/04.
//

import UIKit
import RxSwift

final class CheckPuppyTableViewCell: UITableViewCell {

    @IBOutlet weak var puppyNameLabel: UILabel!
    @IBOutlet weak var checkWalkedButton: CheckButton!
    
    var bag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
    }
    
    override func prepareForReuse() {
        bag = DisposeBag()
    }
    
    func bindData(with data: Puppy) {
        self.puppyNameLabel.text = data.name
    }
}
