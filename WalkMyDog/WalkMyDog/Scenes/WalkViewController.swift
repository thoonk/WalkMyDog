//
//  WalkViewController.swift
//  WalkMyDog
//
//  Created by thoonk on 2022/02/28.
//

import UIKit
import GoogleMaps
import RxSwift
import RxCocoa
import SnapKit

final class WalkViewController: UIViewController {
    // MARK: - Properties
    let selectedPuppies: [Puppy]
    var walkViewModel: WalkViewModel?
    var bag = DisposeBag()
    
    // MARK: - UI Components
    lazy var mapView: GMSMapView = {
        let view = GMSMapView(frame: .zero)
        
        return view
    }()
    
    lazy var closeButton: UIButton = {
       let button = UIButton()
        button.setImage(UIImage(named: "back"), for: .normal)
        button.addTarget(self, action: #selector(closeBtnTapped), for: .touchUpInside)
        
        return button
    }()
    
    lazy var currentPositionButton: UIButton = {
       let button = UIButton()
        button.setImage(UIImage(systemName: "location"), for: .normal)
        button.tintColor = .gray
        
        return button
    }()
    
    required init(_ selectedPuppies: [Puppy]) {
        self.selectedPuppies = selectedPuppies
        
        super.init(nibName: nil, bundle: nil)
        
        setupLayout()
        setupBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let camera = GMSCameraPosition.camera(withLatitude: 37.51444, longitude: 126.75915, zoom: 15.0)
//        let mapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)
//        self.view.addSubview(mapView)
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: 37.51444, longitude: 126.75915)
        marker.title = "Home"
        marker.snippet = "South Korea"
        marker.map = mapView
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        bag = DisposeBag()
    }
}

// MARK: - Private Methods
private extension WalkViewController {
    func setupLayout() {
        let topMaskView = UIView()
        topMaskView.backgroundColor = .white
        
        topMaskView.addSubview(closeButton)
        closeButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(20)
            $0.width.height.equalTo(25)
        }
        
        [topMaskView, mapView]
            .forEach {
                view.addSubview($0)
            }
        
        topMaskView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(50)
        }
        
        mapView.snp.makeConstraints {
            $0.top.equalTo(topMaskView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    func setupBinding() {
        self.walkViewModel = WalkViewModel()
        let output = walkViewModel!.output
        
//        output.cameraPosition
//            .debug()
//            .subscribe(onNext: { [weak self] cameraPosition in
//                self?.mapView.camera = cameraPosition
//            })
//            .disposed(by: bag)
        
        output.location
            .map {
                GMSCameraPosition.camera(
                    withLatitude: $0.coordinate.latitude,
                    longitude: $0.coordinate.longitude,
                    zoom: 15.0
                )
            }
            .bind(to: mapView.rx.camera)
            .disposed(by: bag)
        
//        output.location
//            .map {
//                GMSCameraPosition.camera(
//                    withLatitude: $0.coordinate.latitude,
//                    longitude: $0.coordinate.longitude,
//                    zoom: 15.0
//                )
//            }
//            .bind(to: mapView.rx.cameraToAnimate)
//            .disposed(by: bag)
    }
    
    @objc
    func closeBtnTapped() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension Reactive where Base: GMSMapView {
    var camera: Binder<GMSCameraPosition> {
        return Binder(base) { control, camera in
            control.camera = camera
        }
    }
    
    var cameraToAnimate: Binder<GMSCameraPosition> {
        return Binder(base) { control, camera in
            control.animate(to: camera)
        }
    }
}
