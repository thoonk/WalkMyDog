//
//  WeatherViewController.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/16.
//

import UIKit
import RxCocoa
import RxSwift

class WeatherViewController: UIViewController {
    
    let viewModel = FcstViewModel()
    var bag = DisposeBag()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setBinding()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bag = DisposeBag()
    }
    
    func setBinding() {
        let locationManager = LocationManager.shared
        let input = FcstViewModel.Input(location: locationManager.location, placemark: locationManager.placemark)
        let output = viewModel.bind(input: input)
        
        output.isLoading
            .map { !$0 }
            .bind(to: activityIndicatorView.rx.isHidden)
            .disposed(by: bag)
        
        output.errorMessage
            .subscribe(onNext: { [weak self] msg in
                self?.showAlert("예보 날씨 정보 로딩 실패", msg)
            }).disposed(by: bag)
        
        output.locationName
            .bind(to: self.navigationItem.rx.title)
            .disposed(by: bag)
            
        output.fcstData
            .bind(to: tableView.rx.items(cellIdentifier: C.Cell.weather, cellType: WeatherTableViewCell.self)) { index, item, cell in
                
                cell.dateLabel.text = item.weekWeather?.dateTime
                cell.tempLabel.text = "\(item.weekWeather?.maxTempString ?? "-") / \(item.weekWeather?.minTempString ?? "-")"
                cell.weatherImageView.image = UIImage(systemName: item.weekWeather?.conditionName ?? "sum.max")
                
                let morningPM: PMModel = item.weekPM![0]
                let launchPM: PMModel = item.weekPM![1]
                let dinnerPM: PMModel = item.weekPM![2]
                
                cell.morningPMLabel.text = "\(morningPM.pm10Status) / \(morningPM.pm25Status)"
                cell.launchPMLabel.text = "\(launchPM.pm10Status) / \(launchPM.pm25Status)"
                cell.dinnerPMLabel.text = "\(dinnerPM.pm10Status) / \(dinnerPM.pm25Status)"
                
            }.disposed(by: bag)
    }
}
