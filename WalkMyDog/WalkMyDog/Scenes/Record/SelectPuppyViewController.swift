//
//  SelectPuppyViewController.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/03/04.
//

import UIKit
import RxSwift
import RxCocoa
import MapKit
import CoreLocation

final class SelectPuppyViewController: UIViewController {
    // MARK: - Interface Builder
    lazy var collectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        
        collectionView.backgroundColor = .systemBackground
        collectionView.allowsMultipleSelection = true
        
        return collectionView
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
    
    lazy var startButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(named: "customTintColor")
        button.titleLabel?.textColor = .white
        button.titleLabel?.text = "산책 시작"
        button.roundCorners(.allCorners, radius: 20.0)
        
        return button
    }()
    
    @IBAction func selectBtnTapped(_ sender: UIButton) {
        if selectedPuppies.isEmpty {
            let alertVC = AlertManager.shared.showAlert(
                title: "알림",
                subTitle: "반려견을 한 마리 이상 선택해주세요!",
                actionBtnTitle: "확인"
            )
            self.present(alertVC, animated: true)
        } else {
            let walkViewController = WalkViewController(selectedPuppies: selectedPuppies)
            walkViewController.modalPresentationStyle = .fullScreen
            self.present(walkViewController, animated: true)
        }
    }
    // MARK: - Properties
    var selectPuppyViewModel: SelectPuppyViewModel
    var currentViewModel: CurrentViewModel
    var bag = DisposeBag()
    var selectedPuppies: [Puppy] = []
    
    init(
        selectPuppyViewModel: SelectPuppyViewModel = SelectPuppyViewModel(),
        currentViewModel: CurrentViewModel = CurrentViewModel()
    ) {
        self.selectPuppyViewModel = selectPuppyViewModel
        self.currentViewModel = currentViewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBinding()
        setUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bag = DisposeBag()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == C.Segue.checkToEdit,
           let selectedPuppy = sender as? [Puppy],
           let editRecordVC = segue.destination as? EditRecordViewController {
            editRecordVC.checkedPuppy = selectedPuppy
        }
    }
    // MARK: - Method
    func setUI() {
        
    }
    // MARK: - ViewModel Binding
    func setBinding() {
        let input = selectPuppyViewModel.input
        let output = selectPuppyViewModel.output
        
        //INPUT
        rx.viewWillAppear
            .take(1)
            .map { _ in () }
            .bind(to: input.fetchData)
            .disposed(by: bag)
        
        // OUTPUT
        output.isLoading
            .map { !$0 }
            .bind(to: activityIndicator.rx.isHidden)
            .disposed(by: bag)
            
        output.puppyData
            .bind(to: collectionView.rx.items(
                    cellIdentifier: C.Cell.check,
                    cellType: SelectPuppyCollectionViewCell.self
            )) { [weak self] index, item, cell in
                cell.puppyNameLabel.text = item.name
                // setup puppy profile image
                
            }.disposed(by: bag)
        
        collectionView.rx
            .modelAndIndexSelected(Puppy.self)
            .subscribe(onNext: { [weak self] puppy, index in
                if let cell = self?.collectionView
                    .dequeueReusableCell(withReuseIdentifier: C.Cell.check, for: index) as? SelectPuppyCollectionViewCell {
                    
                    if cell.isSelected == true {
                        self?.selectedPuppies.append(puppy)
                    } else {
                        let arrayIndex =
                        self?.selectedPuppies.firstIndex { $0.id == puppy.id } ?? 0
                        
                        self?.selectedPuppies.remove(at: arrayIndex)
                    }
                }
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
            }).disposed(by: bag)
    }
}

private extension SelectPuppyViewController {
    func setupLayout() {
        let topMaskView = UIView()
        topMaskView.roundCorners([.bottomLeft, .bottomRight], radius: 25.0)
        topMaskView.backgroundColor = .white
        
        [collectionView]
            .forEach { topMaskView.addSubview($0) }
        
        
        [
            topMaskView,
            mapView,
            activityIndicator,
            startButton
        ]
            .forEach { view.addSubview($0) }
        
        topMaskView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(120.0)
        }
        
        mapView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        startButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(20.0)
            $0.leading.trailing.equalToSuperview().inset(30.0)
            $0.height.equalTo(25.0)
        }
    }
}

extension SelectPuppyViewController: MKMapViewDelegate {
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

extension Reactive where Base: UICollectionView {
    func modelAndIndexSelected<T>(_ modelType: T.Type) -> ControlEvent<(T, IndexPath)> {
        ControlEvent(events: Observable.zip(
            self.modelSelected(modelType),
            self.itemSelected
        ))
    }
}
