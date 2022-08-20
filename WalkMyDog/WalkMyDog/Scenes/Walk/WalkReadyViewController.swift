//
//  WalkReadyViewController.swift
//  WalkMyDog
//
//  Created by thoonk on 2022/04/03.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import MapKit

final class WalkReadyViewController: UIViewController {
    // MARK: - UI Components
    lazy var weatherImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(systemName: "sun.max")
        
        return imageView
    }()
    
    lazy var temperatureLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont(name: "NanumSquareRoundB", size: 20.0) ?? UIFont.systemFont(ofSize: 20.0)
        label.textAlignment = .center
        label.textColor = .black
        label.sizeToFit()
        label.text = "-°C"

        return label
    }()
    
    lazy var pm25Label: UILabel = {
       let label = UILabel()
        label.font = UIFont(name: "NanumSquareRoundB", size: 13.0) ?? UIFont.systemFont(ofSize: 13.0)
        label.text = "-"
        label.textColor = .black
        label.textAlignment = .center
        
        return label
    }()
    
    lazy var pm10Label: UILabel = {
       let label = UILabel()
        label.font = UIFont(name: "NanumSquareRoundB", size: 13.0) ?? UIFont.systemFont(ofSize: 13.0)
        label.text = "-"
        label.textColor = .black
        label.textAlignment = .center
        
        return label
    }()
    
    lazy var puppyCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0.0
        
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        
//        collectionView.dataSource = self
        collectionView.delegate = self
//        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = .white
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.allowsMultipleSelection = true
        
        collectionView.register(SelectPuppyCollectionViewCell.self, forCellWithReuseIdentifier: SelectPuppyCollectionViewCell.identifier)

        return collectionView
    }()
    
    lazy var registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .clear
        button.setImage(UIImage(named: "registerButtonImage")?.withRenderingMode(.alwaysOriginal), for: .normal)

        button.clipsToBounds = true
        
        return button
    }()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50 )
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = false
        activityIndicator.style = .large
        
        return activityIndicator
    }()
    
    lazy var mapView: MKMapView = {
        let map = MKMapView()
        
        map.mapType = .standard
        map.showsUserLocation = true
        map.setUserTrackingMode(.follow, animated: true)
        map.isUserInteractionEnabled = false

        return map
    }()
    
    lazy var startWalkingButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(named: "customTintColor")
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "NanumSquareRoundB", size: 15.0)
        button.setTitle("산책시작", for: .normal)
        button.tintColor = .white
        button.roundCorners(.allCorners, radius: 15.0)
        
        return button
    }()
    
    var viewModel: WalkReadyViewModel?
    var bag = DisposeBag()
    private var selectedPuppies = [Puppy]()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        setupLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBinding()
    }
    
    deinit {
        bag = DisposeBag()
    }
}

private extension WalkReadyViewController {
    func setupLayout() {
        let topMaskView = UIView()
        topMaskView.roundCorners([.bottomLeft, .bottomRight], radius: 25.0)
        topMaskView.backgroundColor = .white
        topMaskView.setShadowLayer()
        
        let pm10FormLabel = UILabel()
        pm10FormLabel.text = "미세먼지"
        pm10FormLabel.textColor = .black
        pm10FormLabel.textAlignment = .center
        pm10FormLabel.font = UIFont(name: "NanumSquareRoundR", size: 13.0) ?? UIFont.systemFont(ofSize: 13.0)
        
        let pm10StackView = UIStackView(arrangedSubviews: [pm10FormLabel, pm10Label])
        pm10StackView.alignment = .fill
        pm10StackView.distribution = .fillEqually
        pm10StackView.spacing = 0.0
        
        let pm25FormLabel = UILabel()
        pm25FormLabel.text = "초미세먼지"
        pm25FormLabel.textColor = .black
        pm25FormLabel.textAlignment = .center
        pm25FormLabel.font = UIFont(name: "NanumSquareRoundR", size: 13.0) ?? UIFont.systemFont(ofSize: 13.0)
        
        let pm25StackView = UIStackView(arrangedSubviews: [pm25FormLabel, pm25Label])
        pm25StackView.alignment = .fill
        pm25StackView.distribution = .fillEqually
        pm25StackView.spacing = 0.0
        
        [
            weatherImageView,
            temperatureLabel,
            pm10StackView,
            pm25StackView,
            puppyCollectionView,
            registerButton
        ]
            .forEach { topMaskView.addSubview($0) }
        
        weatherImageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(50.0)
            $0.leading.equalToSuperview().inset(25.0)
        }
        
        temperatureLabel.snp.makeConstraints {
            $0.top.equalTo(weatherImageView)
            $0.leading.equalTo(weatherImageView.snp.trailing).offset(10.0)
        }
        
        pm10StackView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(60.0)
            $0.leading.equalTo(temperatureLabel.snp.trailing).offset(10.0)
            
        }
        
        pm25StackView.snp.makeConstraints {
            $0.top.equalTo(pm10StackView)
            $0.leading.equalTo(pm10StackView.snp.trailing).offset(10.0)
            $0.trailing.greaterThanOrEqualToSuperview().inset(20.0)
        }
        
//        puppyCollectionView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        puppyCollectionView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        puppyCollectionView.snp.makeConstraints {
            $0.top.equalTo(weatherImageView.snp.bottom).offset(20.0)
            $0.leading.equalToSuperview().inset(20.0)
            $0.bottom.equalToSuperview().inset(20.0)
        }
        
        registerButton.snp.makeConstraints {
            $0.top.equalTo(puppyCollectionView)
            $0.bottom.equalToSuperview().inset(40.0)
            $0.leading.equalTo(puppyCollectionView.snp.trailing).offset(10.0)
            $0.trailing.equalToSuperview().inset(20.0)
            $0.width.height.equalTo(50.0)
        }
        
        [
            topMaskView,
            mapView,
            startWalkingButton
        ].forEach { view.addSubview($0) }
        
        topMaskView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(180.0)
        }
        
        mapView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        startWalkingButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(40.0)
            $0.bottom.equalToSuperview().inset(20.0)
            $0.height.equalTo(50.0)
        }
        
        view.bringSubviewToFront(topMaskView)
    }
    
    func setupBinding() {
        self.viewModel = WalkReadyViewModel()
        let input = viewModel!.input
        let output = viewModel!.output
        
        rx.viewWillAppear
//            .take(1)
            .map { _ in () }
            .bind(to: input.fetchData)
            .disposed(by: bag)
        
        mapView.rx
            .setDelegate(self)
            .disposed(by: bag)
        
        registerButton.rx.tap
            .debug()
            .bind(to: input.registerButtonTapped)
            .disposed(by: bag)
        
        startWalkingButton.rx.tap
            .debug()
            .subscribe(onNext: { [weak self] in
                input.startWalkingButtonTapped.onNext(self?.selectedPuppies ?? [Puppy]())
            })
            .disposed(by: bag)
        
        output.location
            .subscribe(onNext: { [weak self] loc in
                self?.mapView.centerToLocation(loc)
            })
            .disposed(by: bag)
        
        output.presentToWalkStartCount
            .subscribe(onNext: { [weak self] puppies in
                let walkStartCountViewController = WalkStartCountViewController(selectedPuppies: puppies)
                walkStartCountViewController.modalPresentationStyle = .fullScreen
                
                self?.present(walkStartCountViewController, animated: true, completion: { [weak self] in
                    self?.selectedPuppies = [Puppy]()
                })
            })
            .disposed(by: bag)
        
        output.presentToEdit
            .bind { [weak self] _ in
                let editPuppyViewController = UINavigationController(rootViewController:  EditPuppyViewController(
                    puppyInfo: nil,
                    isFromNavigation: false
                ))
                editPuppyViewController.modalPresentationStyle = .fullScreen
                self?.present(editPuppyViewController, animated: true)
            }
            .disposed(by: bag)
        
        output.weatherInfo
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] weather in
                self?.weatherImageView.image = UIImage(systemName: weather.conditionName)
                self?.temperatureLabel.text = weather.temperatureString
            })
            .disposed(by: bag)
        
        output.pmInfo
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] pm in
                self?.pm25Label.text = pm.pm25String
                self?.pm10Label.text = pm.pm10String
                
                self?.pm25Label.textColor = self?.setupTextColor(with: pm.pm25Status)
                self?.pm10Label.textColor = self?.setupTextColor(with: pm.pm10Status)
            })
            .disposed(by: bag)
        
        output.puppyInfo
            .bind(to: puppyCollectionView.rx.items(
                cellIdentifier: SelectPuppyCollectionViewCell.identifier,
                cellType: SelectPuppyCollectionViewCell.self)) {
                    index, item, cell in
                    cell.bindData(with: item)
                }
                .disposed(by: bag)
        
        puppyCollectionView.rx
            .modelAndIndexSelected(Puppy.self)
            .subscribe(onNext: { [weak self] puppy, index in
                if let cell = self?.puppyCollectionView.dequeueReusableCell(withReuseIdentifier: SelectPuppyCollectionViewCell.identifier, for: index) as? SelectPuppyCollectionViewCell {
                    
                    if cell.isSelected == true {
                        self?.selectedPuppies.append(puppy)
                    }
                }
            })
            .disposed(by: bag)
        
        Observable.zip(puppyCollectionView.rx.itemSelected, puppyCollectionView.rx.modelDeselected(Puppy.self))
            .subscribe(onNext: { [weak self] index, puppy in
                if let cell = self?.puppyCollectionView.dequeueReusableCell(withReuseIdentifier: SelectPuppyCollectionViewCell.identifier, for: index) as? SelectPuppyCollectionViewCell {
                
                    if cell.isSelected == false {
                        let arrayIndex =
                        self?.selectedPuppies.firstIndex { $0.id == puppy.id } ?? 0
                        
                        if self?.selectedPuppies.isEmpty == false {
                            self?.selectedPuppies.remove(at: arrayIndex)
                        }
                    }
                }
            })
            .disposed(by: bag)
        
        output.errorMessage
            .debug()
            .subscribe(onNext: { [weak self] message in
                self?.setupAlertView(with: message, handler: nil)
            })
            .disposed(by: bag)
    }
}

private extension WalkReadyViewController {
    func setupTextColor(with data: RCMDCriteria) -> UIColor {
        switch data {
        case .love, .happy:
            return UIColor(hex: "046241")
        case .bad, .worst:
            return UIColor(hex: "D45F97")
        default:
            return UIColor.black
        }
    }
}

extension WalkReadyViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            let annotationId = "AnnotationIdentifier"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationId)
            
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
                annotationView?.canShowCallout = true
            } else {
                annotationView?.annotation = annotation
            }
            
            annotationView?.image = UIImage(named: "currentLocation")
            return annotationView
        } else {
            return nil
        }
    }
}

extension WalkReadyViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.bounds.height
        
        return CGSize(width: size, height: size)
    }
}
