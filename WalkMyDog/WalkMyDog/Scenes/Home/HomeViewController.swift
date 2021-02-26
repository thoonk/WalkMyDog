//
//  HomeViewController.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/05.
//

import UIKit
import RxSwift
import RxCocoa

class HomeViewController: UIViewController {
    
    let currnetViewModel = CurrentViewModel()
    var puppiesViewModel: PuppiesViewModel?
    var bag = DisposeBag()
    
    @IBOutlet weak var weatherView: UIView!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var pm10Label: UILabel!
    @IBOutlet weak var pm25Label: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var puppyProfileTableView: UITableView!
    
    @IBOutlet weak var recordView: UIView!
    
    @IBAction func settingBtnTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: C.Segue.homeToSetting, sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setCurrentBinding()
        setPuppyBinding()
        setUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bag = DisposeBag()
    }
    
    func setUI() {
        puppyProfileTableView.separatorStyle = .none
        
        weatherView.layer.cornerRadius = 10
        weatherView.layer.borderWidth = 1.0
        weatherView.layer.borderColor = UIColor.black.cgColor
        
        recordView.layer.cornerRadius = 10
        recordView.layer.borderWidth = 1.0
        recordView.layer.borderColor = UIColor.black.cgColor
    }
    /// 현재 날씨 정보 바인딩
    func setCurrentBinding() {
        let locationManager = LocationManager.shared
        let input = CurrentViewModel.Input(location: locationManager.location, placemark: locationManager.placemark)
        let output = currnetViewModel.bind(input: input)
        
        // OUTPUT
        output.errorMessage
            .subscribe(onNext: { [weak self] msg in
                self?.showAlert("현재 날씨 정보 로딩 실패", msg)
            }).disposed(by: bag)
        
        output.isLoading
            .map { !$0 }
            .bind(to: activityIndicatorView.rx.isHidden)
            .disposed(by: bag)
        
        output.locationName
            .bind(to: locationLabel.rx.text)
            .disposed(by: bag)
        
        output.conditionName
            .map {
                UIImage(systemName: $0)
            }
            .observe(on: MainScheduler.instance)
            .bind(to: weatherImageView.rx.image)
            .disposed(by: bag)
        
        output.temperature
            .bind(to: tempLabel.rx.text)
            .disposed(by: bag)
        
        output.pm10Status
            .bind(to: pm10Label.rx.text)
            .disposed(by: bag)
        
        output.pm25Status
            .bind(to: pm25Label.rx.text)
            .disposed(by: bag)
    }
    
    func setPuppyBinding() {
        puppiesViewModel = PuppiesViewModel()
        // OUTPUT
        puppiesViewModel?.output.puppyData
            .bind(to: puppyProfileTableView.rx.items(cellIdentifier: C.Cell.profile, cellType: PuppyProfileTableViewCell.self)) { index, item, cell in
                cell.bindData(with: item)
            }.disposed(by: bag)
    }
}
