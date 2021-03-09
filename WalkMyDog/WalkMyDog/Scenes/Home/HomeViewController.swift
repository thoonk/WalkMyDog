//
//  HomeViewController.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/05.
//

import UIKit
import RxSwift
import RxCocoa
import PanModal

class HomeViewController: UIViewController {
    
    var currentViewModel: CurrentViewModel?
    var fetchAllPuppyViewModel: FetchAllPuppyViewModel?
    var bag = DisposeBag()
    
    @IBOutlet weak var weatherView: UIView!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var pm10ImageView: UIImageView!
    @IBOutlet weak var pm25ImageView: UIImageView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var puppyProfileTableView: UITableView!
    @IBOutlet weak var recordView: UIView!
    @IBOutlet weak var addRecordBtn: UIButton!
    
    @IBAction func settingBtnTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: C.Segue.homeToSetting, sender: nil)
    }
    
    @IBAction func addRecordBtnTapped(_ sender: UIButton) {
        let checkPuppyVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "CheckPuppyVC") as! CheckPuppyViewController
        presentPanModal(checkPuppyVC)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.items?[0].title = "산책 기록"
        self.tabBarController?.tabBar.items?[1].title = "날씨 예보"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setCurrentBinding()
        setFetchAllPuppyBinding()
        setUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bag = DisposeBag()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == C.Segue.homeToRecord,
           let selectedItem = sender as? Puppy,
           let recordVC = segue.destination as? RecordViewController {
            recordVC.puppyInfo = selectedItem
        }
    }
    
    func setUI() {
        puppyProfileTableView.separatorStyle = .none
        locationLabel.adjustsFontSizeToFitWidth = true
        weatherView.layer.cornerRadius = 10
        weatherView.layer.borderWidth = 1.0
        weatherView.layer.borderColor = UIColor.black.cgColor
        
        recordView.layer.cornerRadius = 10
        recordView.layer.borderWidth = 1.0
        recordView.layer.borderColor = UIColor.black.cgColor
    }
    
    // MARK: - ViewModel Binding
    /// 현재 날씨 정보 바인딩
    func setCurrentBinding() {
        
        currentViewModel = CurrentViewModel()
        let output = currentViewModel!.output
        
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
            .map { UIImage(named: $0) }
            .observe(on: MainScheduler.instance)
            .bind(to: pm10ImageView.rx.image)
            .disposed(by: bag)
        
        output.pm25Status
            .map { UIImage(named: $0) }
            .bind(to: pm25ImageView.rx.image)
            .disposed(by: bag)
    }
    
    func setFetchAllPuppyBinding() {
        fetchAllPuppyViewModel = FetchAllPuppyViewModel()
        let output = fetchAllPuppyViewModel!.output

        // OUTPUT
        output.puppyData
            .bind(to: puppyProfileTableView.rx.items(cellIdentifier: C.Cell.profile, cellType: PuppyProfileTableViewCell.self)) { index, item, cell in
                cell.bindData(with: item)
            }.disposed(by: bag)
        
        puppyProfileTableView.rx.modelSelected(Puppy.self)
            .subscribe(onNext: { [weak self] puppy in
                self?.performSegue(withIdentifier: C.Segue.homeToRecord, sender: puppy)
            }).disposed(by: bag)
    }
}
