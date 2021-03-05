//
//  RecordTableViewCell.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/03/02.
//

import UIKit
import RxSwift

class RecordTableViewCell: UITableViewCell {
    
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var deleteRecordBtn: UIButton!
    
    var bag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = DisposeBag()
    }
    
    func bindData(data: Record) {
        self.timeStampLabel.text = data.timeStamp
        self.detailLabel.text =
            "\(data.walkInterval)분, \(data.walkDistance)m"
    }
}
