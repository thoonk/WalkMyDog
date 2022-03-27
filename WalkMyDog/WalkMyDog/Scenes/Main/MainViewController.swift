//
//  MainViewController.swift
//  WalkMyDog
//
//  Created by thoonk on 2021/02/05.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class MainViewController: UIViewController {
    // MARK: - InterfaceBuilder
    lazy var imageScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 250)
        scrollView.contentSize = CGSize(width: CGFloat(slides.count) * view.frame.width, height: 400)
        scrollView.delegate = self
        
        return scrollView
    }()
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.image = UIImage(named: "launchImage")
        
        return imageView
    }()
    
    lazy var settingButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "setting-30"), for: .normal)
        button.tintColor = .white
        
        return button
    }()
    
    lazy var containerTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.separatorStyle = .singleLine
        tableView.roundCorners([.topLeft, .topRight], radius: 22.0)
        tableView.allowsSelection = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 500
        
        tableView.register(PuppyInfoViewCell.self, forCellReuseIdentifier: PuppyInfoViewCell.identifier)
        tableView.register(PuppyCalendarViewCell.self, forCellReuseIdentifier: PuppyCalendarViewCell.identifier)
        
        return tableView
    }()
    
    private var puppies = [Puppy]()
    var slides = [SlideView]()
    
    // MARK: - Properties
    var currentViewModel: CurrentViewModel?
    var mainViewModel: MainViewModel?
    var bag = DisposeBag()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        setupLayout()
        self.navigationController?.navigationBar.backgroundColor = .clear
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        setCurrentBinding()
        setFetchAllPuppyBinding()
//        setUI()
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
        let selectPuppyVC = SelectPuppyViewController()
//        selectPuppyVC.modalPresentationStyle = .fullScreen
//        self.present(selectPuppyVC, animated: true)
    }
    
    @IBAction func unwindToHome(_ sender: UIStoryboardSegue) {}
    
    // MARK: - Methods
    func setupLayout() {
        [
            profileImageView,
            settingButton,
            containerTableView
        ]
            .forEach { view.addSubview($0) }
        
        profileImageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(280.0)
        }
        
        settingButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(50)
            $0.trailing.equalToSuperview().inset(20)
            $0.width.height.equalTo(50.0)
        }
        
        containerTableView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(250.0)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    func setupScrollView() {
        for index in 0..<slides.count {
            slides[index].frame = CGRect(x: CGFloat(index) * view.frame.width, y: 0, width: view.frame.width, height: 250)
            imageScrollView.addSubview(slides[index])
        }
        
//        puppyInfoView.pageControl.numberOfPages = slides.count
    }
    
//    func setUI() {
//        puppyProfileTableView.separatorStyle = .none
//        locationLabel.adjustsFontSizeToFitWidth = true
//        weatherView.setShadowLayer()
//        recordView.setShadowLayer()
//
//        let addBtnImage = UIImage(named: "plus-50")?
//            .withRenderingMode(.alwaysTemplate)
//        addRecordBtn.setImage(addBtnImage, for: .normal)
//        addRecordBtn.tintColor = UIColor(named: "customTintColor")
//    }
    
    // MARK: - ViewModel Binding
    /// 현재 날씨 정보 바인딩
//    func setCurrentBinding() {
//
//        currentViewModel = CurrentViewModel()
//        let output = currentViewModel!.output
//
//        // OUTPUT
//        output.errorMessage
//            .subscribe(onNext: { [weak self] msg in
//                let alertVC = AlertManager.shared.showAlert(
//                    title: "현재 날씨 정보 로딩 실패",
//                    subTitle: msg,
//                    actionBtnTitle: "확인"
//                )
//                self?.present(alertVC, animated: true)
//            }).disposed(by: bag)
//
//        output.isLoading
//            .map { !$0 }
//            .bind(to: activityIndicatorView.rx.isHidden)
//            .disposed(by: bag)
//
//        output.locationName
//            .bind(to: locationLabel.rx.text)
//            .disposed(by: bag)
//
//        output.conditionName
//            .map {
//                UIImage(systemName: $0)
//            }
//            .observe(on: MainScheduler.instance)
//            .bind(to: weatherImageView.rx.image)
//            .disposed(by: bag)
//
//        output.temperature
//            .bind(to: tempLabel.rx.text)
//            .disposed(by: bag)
//
//        output.pm10Image
//            .map { UIImage(named: $0) }
//            .observe(on: MainScheduler.instance)
//            .bind(to: pm10ImageView.rx.image)
//            .disposed(by: bag)
//
//        output.pm25Image
//            .map { UIImage(named: $0) }
//            .bind(to: pm25ImageView.rx.image)
//            .disposed(by: bag)
//
//        output.rcmdStatus
//            .bind(to: rcmdLabel.rx.text)
//            .disposed(by: bag)
//    }
//
    func setFetchAllPuppyBinding() {
        mainViewModel = MainViewModel()
        let input = mainViewModel!.input
        let output = mainViewModel!.output

        // INPUT
        rx.viewDidAppear
            .take(1)
            .map { _ in () }
            .bind(to: input.fetchData)
            .disposed(by: bag)

        // OUTPUT
//        output.puppyData
//            .bind(to: puppyProfileTableView.rx.items(
//                    cellIdentifier: C.Cell.profile,
//                    cellType: PuppyProfileTableViewCell.self
//            )) { index, item, cell in
//                cell.bindData(with: item)
//            }.disposed(by: bag)
//
//        puppyProfileTableView.rx.modelSelected(Puppy.self)
//            .subscribe(onNext: { [weak self] puppy in
//                self?.performSegue(
//                    withIdentifier: C.Segue.homeToRecord,
//                    sender: puppy
//                )
//            }).disposed(by: bag)
        output.cellData
            .bind(to: containerTableView.rx.items) { tableView, row, item -> UITableViewCell in
                
                switch item {
                case .puppyInfo(let puppies):
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: PuppyInfoViewCell.identifier, for: IndexPath(row: row, section: 0)) as? PuppyInfoViewCell else { return UITableViewCell() }
                    
                    cell.pageControl.numberOfPages = puppies.count
                    cell.configure(with: puppies[0])
                    
                    return cell
                case .puppyCalendar(let puppy, let records):
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: PuppyCalendarViewCell.identifier, for: IndexPath(row: row, section: 0)) as? PuppyCalendarViewCell else { return UITableViewCell() }
                    
                    cell.configure(with: puppy, records: records)
                    
                    return cell
                }
            }
            .disposed(by: bag)
                
        output.puppyData
            .subscribe(onNext: { [weak self] puppy in
                self?.puppies = puppy
//                self?.puppyInfoView.updateUI(with: puppy[0])
            })
            .disposed(by: bag)

        output.errorMessage
            .subscribe(onNext: { [weak self] msg in
                let alertVC = AlertManager.shared.showAlert(
                    title: "모든 반려견 정보 로딩 실패",
                    subTitle: msg,
                    actionBtnTitle: "확인"
                )
                self?.present(alertVC, animated: true, completion: {
                    input.fetchData.onNext(())
                })
            })
            .disposed(by: bag)
    }
}

extension MainViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / view.frame.width)
        guard let cell = self.containerTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? PuppyInfoViewCell else { return }
        cell.pageControl.currentPage = Int(pageIndex)
        
//        self.puppyInfoView.pageControl.currentPage = Int(pageIndex)
//        self.puppyInfoView.updateUI(with: self.puppies[Int(pageIndex)])
    }
}
