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
    // MARK: - InterfaceBuilder
    @IBOutlet weak var weatherView: UIView!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var pm10ImageView: UIImageView!
    @IBOutlet weak var pm25ImageView: UIImageView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var puppyProfileTableView: UITableView!
    @IBOutlet weak var recordView: UIView!
    @IBOutlet weak var rcmdLabel: UILabel!
    @IBOutlet weak var addRecordBtn: UIButton!
    
    // MARK: - Properties
    var currentViewModel: CurrentViewModel?
    var fetchAllPuppyViewModel: FetchAllPuppyViewModel?
    var bag = DisposeBag()
    
    // MARK: - LifeCycle
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
    
    // MARK: - Actions
    @IBAction func settingBtnTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: C.Segue.homeToSetting, sender: nil)
    }
    
    @IBAction func addRecordBtnTapped(_ sender: UIButton) {
        let checkPuppyVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "CheckPuppyVC") as! CheckPuppyViewController
        presentPanModal(checkPuppyVC)
    }
    
    // MARK: - Methods
    func setUI() {
        puppyProfileTableView.separatorStyle = .none
        locationLabel.adjustsFontSizeToFitWidth = true
        weatherView.setShadowLayer()
        recordView.setShadowLayer()
        
        let addBtnImage = UIImage(named: "plus-50")?.withRenderingMode(.alwaysTemplate)
        addRecordBtn.setImage(addBtnImage, for: .normal)
        addRecordBtn.tintColor = #colorLiteral(red: 0.4196078431, green: 0.4, blue: 1, alpha: 1)
    }
    
    // MARK: - ViewModel Binding
    /// 현재 날씨 정보 바인딩
    func setCurrentBinding() {
        
        currentViewModel = CurrentViewModel()
        let output = currentViewModel!.output
        
        // OUTPUT
        output.errorMessage
            .subscribe(onNext: { [weak self] msg in
                let alertVC = AlertManager.shared.showAlert(title: "현재 날씨 정보 로딩 실패", subTitle: msg, actionBtnTitle: "확인")
                self?.present(alertVC, animated: true)
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
        
        output.pm10Image
            .map { UIImage(named: $0) }
            .observe(on: MainScheduler.instance)
            .bind(to: pm10ImageView.rx.image)
            .disposed(by: bag)
        
        output.pm25Image
            .map { UIImage(named: $0) }
            .bind(to: pm25ImageView.rx.image)
            .disposed(by: bag)
        
        output.rcmdStatus
            .bind(to: rcmdLabel.rx.text)
            .disposed(by: bag)
    }
    
    func setFetchAllPuppyBinding() {
        fetchAllPuppyViewModel = FetchAllPuppyViewModel()
        let input = fetchAllPuppyViewModel!.input
        let output = fetchAllPuppyViewModel!.output
        
        // INPUT
        rx.viewDidAppear
            .take(1)
            .map { _ in () }
            .bind(to: input.fetchData)
            .disposed(by: bag)

        // OUTPUT
        output.puppyData
            .bind(to: puppyProfileTableView.rx.items(cellIdentifier: C.Cell.profile, cellType: PuppyProfileTableViewCell.self)) { index, item, cell in
                cell.bindData(with: item)
            }.disposed(by: bag)
        
        puppyProfileTableView.rx.modelSelected(Puppy.self)
            .subscribe(onNext: { [weak self] puppy in
                self?.performSegue(withIdentifier: C.Segue.homeToRecord, sender: puppy)
            }).disposed(by: bag)
        
        output.errorMessage
            .subscribe(onNext: { [weak self] msg in
                let alertVC = AlertManager.shared.showAlert(title: "모든 반려견 정보 로딩 실패", subTitle: msg, actionBtnTitle: "확인")
                self?.present(alertVC, animated: true, completion: {
                    input.fetchData.onNext(())
                })
            })
            .disposed(by: bag)
    }
}
