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
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        setupLayout()
        setupBinding()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        
        [
            topMaskView,
            mapView,
            startWalkingButton
        ].forEach { view.addSubview($0) }
        
        topMaskView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(100.0)
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
        
        mapView.rx
            .setDelegate(self)
            .disposed(by: bag)
        
        startWalkingButton.rx.tap
            .bind(to: input.startWalkingButtonTapped)
            .disposed(by: bag)
        
        output.location
            .subscribe(onNext: { [weak self] loc in
                self?.mapView.centerToLocation(loc)
            })
            .disposed(by: bag)
        
        output.presentToWalk
            .subscribe(onNext: { [weak self] puppies in
                let walkViewController = WalkViewController(selectedPuppies: puppies)
                walkViewController.modalPresentationStyle = .fullScreen
                self?.present(walkViewController, animated: true)
            })
            .disposed(by: bag)
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
