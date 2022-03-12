//
//  WalkViewController.swift
//  WalkMyDog
//
//  Created by thoonk on 2022/02/28.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import MapKit

enum ButtonState {
    case play
    case pause
}

final class WalkViewController: UIViewController {
    enum AnnotationType {
        case feces
        case pee
    }
    
    // MARK: - Properties
    let selectedPuppies: [Puppy]
    let currentLocation: CLLocationCoordinate2D
    
    var walkViewModel: WalkViewModel?
    var bag = DisposeBag()
    var isWalking: Bool = false
    
    // MARK: - UI Components
    lazy var mapView: MKMapView = {
        let map = MKMapView()
        
        map.mapType = .standard
        map.showsUserLocation = true
        map.setUserTrackingMode(.follow, animated: true)
        map.isZoomEnabled = true

        return map
    }()
    
    lazy var closeButton: UIButton = {
       let button = UIButton()
        button.setImage(UIImage(named: "back"), for: .normal)
        button.addTarget(self, action: #selector(closeBtnTapped), for: .touchUpInside)
        
        return button
    }()
    
    lazy var myLocationButton: UIButton = {
       let button = UIButton()
        button.setImage(UIImage(systemName: "location"), for: .normal)
        button.tintColor = UIColor(named: "customTintColor")

        return button
    }()
    
    lazy var fecesButton: UIButton = {
       let button = UIButton()
        button.setImage(UIImage(systemName: "star.circle"), for: .normal)
        button.tintColor = UIColor(named: "customTintColor")

        return button
    }()
    
    lazy var pausePlayButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(systemName: "pause", size: 30)
        button.tintColor = UIColor(named: "customTintColor")
        
        return button
    }()
    
    lazy var stopButton: UIButton = {
        let button = UIButton()
        button.setImage(systemName: "stop.fill", size: 30)
        button.tintColor = UIColor(named: "customTintColor")
        
        return button
    }()
    
    lazy var cameraButton: UIButton = {
        let button = UIButton()
        button.setImage(systemName: "camera.fill", size: 30)
        button.tintColor = UIColor(named: "customTintColor")
        
        return button
    }()
    
    lazy var distanceLabel: UILabel = {
       let label = UILabel()
        label.text = "0.0"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 25.0, weight: .bold)
        label.sizeToFit()
        
        return label
    }()
    
    lazy var timeLabel: UILabel = {
       let label = UILabel()
        label.text = "00:00"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 25.0, weight: .bold)
        label.sizeToFit()
        
        return label
    }()
    
    required init(
        selectedPuppies: [Puppy],
        location: CLLocationCoordinate2D
    ) {
        self.selectedPuppies = selectedPuppies
        self.currentLocation = location
        
        super.init(nibName: nil, bundle: nil)
        
        setupLayout()
        setupBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        let bottomMaskView = UIView()
        bottomMaskView.backgroundColor = .white
        
        let labelStackView = UIStackView(arrangedSubviews: [distanceLabel, timeLabel])
        labelStackView.alignment = .fill
        labelStackView.distribution = .fillEqually
        labelStackView.spacing = 25.0
                
        let buttonStackView = UIStackView(arrangedSubviews: [pausePlayButton, stopButton, cameraButton])
        buttonStackView.alignment = .fill
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 15.0
        
        [labelStackView, buttonStackView]
            .forEach { bottomMaskView.addSubview($0) }
        
        labelStackView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(40)
            $0.centerX.equalToSuperview()
        }
        
        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(labelStackView).offset(20)
            $0.leading.trailing.bottom.equalToSuperview().inset(20)
        }
        
        [
            topMaskView,
            mapView,
            bottomMaskView,
            myLocationButton,
            fecesButton
        ]
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
            $0.leading.trailing.equalToSuperview()
        }
        
        bottomMaskView.snp.makeConstraints {
            $0.top.equalTo(mapView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.3)
        }
        
        myLocationButton.snp.makeConstraints {
            $0.bottom.equalTo(bottomMaskView.snp.top).offset(-20)
            $0.leading.equalToSuperview().inset(15)
            $0.width.height.equalTo(50)
        }
        
        fecesButton.snp.makeConstraints {
            $0.bottom.equalTo(bottomMaskView.snp.top).offset(-20)
            $0.trailing.equalToSuperview().inset(15)
            $0.width.height.equalTo(50)
        }
    }
    
    func setupBinding() {
        self.walkViewModel = WalkViewModel()
        let input = walkViewModel!.input
        let output = walkViewModel!.output
        
        pausePlayButton.rx.tap
            .scan(ButtonState.pause) { lastState, _ in
                switch lastState {
                case .play:
                    return .pause
                case .pause:
                    return .play
                }
            }
            .bind(to: input.pausePlayButtonTapped)
            .disposed(by: bag)
        
        myLocationButton.rx.tap
            .bind(to: input.myLocationButtonTapped)
            .disposed(by: bag)
        
        fecesButton.rx.tap
            .bind(to: input.fecesButtonTapped)
            .disposed(by: bag)
        
        mapView.rx
            .setDelegate(self)
            .disposed(by: bag)
        
        input.pausePlayButtonTapped
            .subscribe(onNext: { [weak self] state in
                switch state {
                case .pause:
                    self?.pausePlayButton.setImage(systemName: "play", size: 30)
                case .play:
                    self?.pausePlayButton.setImage(systemName: "pause", size: 30)
                }
            })
            .disposed(by: bag)
        
        output.location
            .subscribe(onNext: { [weak self] loc in
                self?.mapView.centerToLocation(loc)
            })
            .disposed(by: bag)
        
        output.annotationLocation
            .subscribe(onNext: { [weak self] loc in
                self?.setupAnnotation(with: loc, type: .feces)
            })
            .disposed(by: bag)
        
        output.path
            .subscribe(onNext: { [weak self] path in
                self?.drawPathLine(with: path)
            })
            .disposed(by: bag)
        
        output.distanceRelay
            .subscribe(onNext: { [weak self] distance in
                self?.distanceLabel.text = String(format: "%.1f (km)", distance / 1000)
            })
            .disposed(by: bag)
    }
    
    @objc
    func closeBtnTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setupAnnotation(with coordinate: CLLocationCoordinate2D, type: AnnotationType) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        switch type {
        case .feces:
            annotation.title = "Feces"
        case .pee:
            annotation.title = "Pee"
        }
        
        self.mapView.addAnnotation(annotation)
    }
    
    func drawPathLine(with path: [CLLocationCoordinate2D]) {
        let lineDraw = MKPolyline(coordinates: path, count: path.count)
        self.mapView.addOverlay(lineDraw)
    }
}

extension MKMapView {
    func centerToLocation(
        _ location: CLLocationCoordinate2D,
        regionRadius: CLLocationDistance = 500
    ) {
        let region = MKCoordinateRegion(
            center: location,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius
        )
        setRegion(region, animated: true)
    }
}

extension WalkViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .systemBlue
            renderer.lineWidth = 5.0
            renderer.alpha = 0.5
            return renderer
        } else {
            return MKPolylineRenderer()
        }
    }
}