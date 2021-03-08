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
    @IBOutlet weak var pmTitleLabel: UILabel!
    @IBOutlet weak var morningPM10ImageView: UIImageView!
    @IBOutlet weak var launchPM10ImageView: UIImageView!
    @IBOutlet weak var dinnerPM10ImageView: UIImageView!
    @IBOutlet weak var morningPM25ImageView: UIImageView!
    @IBOutlet weak var launchPM25ImageView: UIImageView!
    @IBOutlet weak var dinnerPM25ImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        pmTitleLabel.text = "미세 / 초미세"
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func bindData(data: FcstModel) {
                
        dateLabel.text = data.weekWeather?.dateTime
        tempLabel.text = "\(data.weekWeather?.maxTempString ?? "-") / \(data.weekWeather?.minTempString ?? "-")"
        weatherImageView.image = UIImage(systemName: data.weekWeather?.conditionName ?? "sum.max")
        
        let morningPM: PMModel = data.weekPM![0]
        let launchPM: PMModel = data.weekPM![1]
        let dinnerPM: PMModel = data.weekPM![2]
        
        morningPM10ImageView.image = UIImage(named: morningPM.pm10Status)
        morningPM25ImageView.image = UIImage(named: morningPM.pm25Status)
        
        launchPM10ImageView.image = UIImage(named: launchPM.pm10Status)
        launchPM25ImageView.image = UIImage(named: launchPM.pm25Status)
        
        dinnerPM10ImageView.image = UIImage(named: dinnerPM.pm10Status)
        dinnerPM25ImageView.image = UIImage(named: dinnerPM.pm25Status)
    }
}
