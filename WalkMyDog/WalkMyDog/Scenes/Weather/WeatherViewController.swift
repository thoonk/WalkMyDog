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
                
                cell.bindData(data: item)
                
            }.disposed(by: bag)
    }
}
