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
import CoreLocation
import Kingfisher

final class MainViewController: UIViewController {
    // MARK: - InterfaceBuilder
    lazy var imageScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 250)
        scrollView.contentSize = CGSize(width: CGFloat(slides.count) * view.frame.width, height: 250)
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
        setNavigationBarClear()

//        print(puppyRealmService.insert(
//            name: "꿍이",
//            age: "2013.05.02",
//            gender: false,
//            weight: 7.5,
//            species: "말티즈",
//            imageURL: nil
//        ))
//        let puppies = puppyRealmService.fetchPuppies()
//        if let puppy = puppies?.first {
//            print(puppyRealmService.update(
//                with: puppy,
//                name: "꼬꼬",
//                age: "2016.12.11",
//                gender: true,
//                weight: 8.5,
//                species: "퍼그",
//                imageURL: nil
//            ))
//            puppyRealmService.remove(with: puppy)
//        }
        
//        if let puppy = puppies?.first
//           let record = puppy.records.first
//        {
//            print(recordRealmService.insert(selectedPuppy: puppy, timeStamp: Date(), interval: 1800, distance: 1500, calories: 251, startLocation: Location(clLocation: CLLocation(latitude: 32.923, longitude: 234.2323)), endLocation: Location(clLocation: CLLocation(latitude: 32.923, longitude: 234.2323)), fecesLocation: nil, peeLocation: nil))
//            print(recordRealmService.remove(with: record))
//            print(recordRealmService.fetchRecords(selectedPuppy: puppy))
//        }
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
            imageScrollView,
            settingButton,
            containerTableView
        ]
            .forEach { view.addSubview($0) }
        
        imageScrollView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(250.0)
        }
        
        settingButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(60)
            $0.trailing.equalToSuperview().inset(20)
            $0.width.height.equalTo(45.0)
        }
        
        containerTableView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(230.0)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    func setupScrollView(with puppies: [Puppy]) {
        self.slides = [SlideView]()
        for puppy in puppies {
            let slide = SlideView()
            if let urlString = puppy.imageURL,
               let url = URL(string: urlString) {
                slide.profileImageView.kf.setImage(with: url)
            } else {
                slide.profileImageView.image = UIImage(named: "launchImage")
            }
            self.slides.append(slide)
        }
         
        for index in 0..<slides.count {
            slides[index].frame = CGRect(x: CGFloat(index) * view.frame.width, y: 0, width: view.frame.width, height: 250)
            imageScrollView.addSubview(slides[index])
        }
        
        imageScrollView.contentSize = CGSize(width: CGFloat(slides.count) * view.frame.width, height: 250)
        
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
        
        imageScrollView.rx.currentPage
            .skip(1)
            .distinctUntilChanged()
            .bind(to: input.currentIndex)
            .disposed(by: bag)
        
        settingButton.rx.tap
            .bind(to: input.settingButtonTapped)
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
        
        imageScrollView.rx.currentPage
            .subscribe(onNext: { [weak self] page in
                self?.setPageControlPage(index: page)
            })
            .disposed(by: bag)
        
        output.cellData
            .bind(to: containerTableView.rx.items) { [weak self] tableView, row, item -> UITableViewCell in
                
                switch item {
                case .puppyInfo(let puppies):
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: PuppyInfoViewCell.identifier, for: IndexPath(row: row, section: 0)) as? PuppyInfoViewCell else { return UITableViewCell() }
                    
                    self?.setupScrollView(with: puppies)
                    cell.pageControl.numberOfPages = puppies.count
                    
                    if let index = self?.imageScrollView.currentPage {
                        cell.configure(with: puppies[index])
                    }
                    
                    return cell
                case .puppyCalendar(let puppy):
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: PuppyCalendarViewCell.identifier, for: IndexPath(row: row, section: 0)) as? PuppyCalendarViewCell,
                          let puppy = puppy
                    else { return UITableViewCell() }
                    
                    cell.configure(with: puppy)
                    
                    return cell
                }
            }
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
        
        output.presentToSetting
            .subscribe(onNext: { [weak self] in
                let settingViewController = UINavigationController(rootViewController: SettingViewController())
                settingViewController.modalPresentationStyle = .fullScreen
                
                self?.present(settingViewController, animated: true)
            })
            .disposed(by: bag)
    }
    
    func setPageControlPage(index: Int) {
        guard let cell = self.containerTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? PuppyInfoViewCell else { return }
        cell.pageControl.currentPage = index
    }
    
    func setNavigationBarClear() {
//        navigationController?.view.backgroundColor = .clear
//        if #available(iOS 15.0, *) {
//            let navigationAppearance = UINavigationBarAppearance()
//            navigationAppearance.configureWithDefaultBackground()
//            navigationAppearance.backgroundColor = .clear
//            navigationAppearance.shadowColor = .clear
//
//            UINavigationBar.appearance().standardAppearance = navigationAppearance
//            UINavigationBar.appearance().scrollEdgeAppearance = navigationAppearance
//            UINavigationBar.appearance().isTranslucent = true
//        } else {
//            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
//            self.navigationController?.navigationBar.shadowImage = UIImage()
//            self.navigationController?.navigationBar.backgroundColor = .clear
//        }
    }
}

extension MainViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = (scrollView.contentOffset.x + (0.5 * scrollView.frame.size.width)) / scrollView.frame.size.width + 1
        
        self.setPageControlPage(index: Int(pageIndex))
    }
}

