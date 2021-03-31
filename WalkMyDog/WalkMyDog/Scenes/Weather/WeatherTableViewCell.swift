//
//  WeatherTableViewCell.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/16.
//

import UIKit

class WeatherTableViewCell: UITableViewCell {

    @IBOutlet weak var fcstView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet weak var morningPM10ImageView: UIImageView!
    @IBOutlet weak var launchPM10ImageView: UIImageView!
    @IBOutlet weak var dinnerPM10ImageView: UIImageView!
    @IBOutlet weak var morningPM25ImageView: UIImageView!
    @IBOutlet weak var launchPM25ImageView: UIImageView!
    @IBOutlet weak var dinnerPM25ImageView: UIImageView!
    @IBOutlet weak var rcmdImageView: UIImageView!
    @IBOutlet weak var morningRcmdImageView: UIImageView!
    @IBOutlet weak var launchRcmdImageView: UIImageView!
    @IBOutlet weak var dinnerRcmdImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        fcstView.layer.cornerRadius = 10
    }
    
    func bindData(data: FcstModel) {
        dateLabel.text = data.weekWeather?.dateTime
        maxTempLabel.text = "\(data.weekWeather?.maxTempString ?? "-")"
        minTempLabel.text = "\(data.weekWeather?.minTempString ?? "-")"
        weatherImageView.image = UIImage(systemName: data.weekWeather?.conditionName ?? "sum.max")
        
        let morningPM: PMModel = data.weekPM![0]
        let launchPM: PMModel = data.weekPM![1]
        let dinnerPM: PMModel = data.weekPM![2]
                
        morningPM10ImageView.image = UIImage(named: morningPM.pm10Image)
        morningPM25ImageView.image = UIImage(named: morningPM.pm25Image)
        
        launchPM10ImageView.image = UIImage(named: launchPM.pm10Image)
        launchPM25ImageView.image = UIImage(named: launchPM.pm25Image)
        
        dinnerPM10ImageView.image = UIImage(named: dinnerPM.pm10Image)
        dinnerPM25ImageView.image = UIImage(named: dinnerPM.pm25Image)
        
        if data.weekWeather?.conditionId ?? 0 <= 531 {
            morningRcmdImageView.image = nil
            launchRcmdImageView.image = nil
            dinnerRcmdImageView.image = nil
        } else {
            morningRcmdImageView.image = UIImage(named: morningPM.rcmdImage)
            launchRcmdImageView.image = UIImage(named: launchPM.rcmdImage)
            dinnerRcmdImageView.image = UIImage(named: dinnerPM.rcmdImage)
        }
    }
}
