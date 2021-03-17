//
//  WeatherViewController.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/16.
//

import UIKit
import RxCocoa
import RxSwift
import RxViewController

class WeatherViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var viewModel: FcstViewModel?
    var bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.rowHeight = 120
        tableView.refreshControl = UIRefreshControl()
        setBinding()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bag = DisposeBag()
    }
    
    func setBinding() {
        viewModel = FcstViewModel()
        let output = viewModel!.output
        
        let firstLoad = rx.viewWillAppear
            .take(1)
            .map { _ in () }
        let reload = tableView.refreshControl?.rx
            .controlEvent(.valueChanged)
            .map { _ in () } ?? Observable.just(())
        
        Observable.merge([firstLoad, reload])
            .bind(to: viewModel!.input.fetchFcst)
            .disposed(by: bag)
        
        output.loaded
            .map { !$0 }
            .do(onNext: { [weak self] ended in
                if ended {
                    self?.tableView.refreshControl?.endRefreshing()
                }
            })
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
