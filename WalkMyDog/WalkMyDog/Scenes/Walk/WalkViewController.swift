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
import Photos

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
    var walkViewModel: WalkViewModel?
    var bag = DisposeBag()
    
    // MARK: - UI Components
    lazy var mapView: MKMapView = {
        let map = MKMapView()
        
        map.mapType = .standard
        map.showsUserLocation = true
        map.setUserTrackingMode(.follow, animated: true)
        map.isZoomEnabled = true
//        map.isUserInteractionEnabled = false

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
        button.setImage(UIImage(named: "myLocation-26"), for: .normal)
        return button
    }()
    
    lazy var fecesButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "feces-32"), for: .normal)
        return button
    }()
    
    lazy var pausePlayButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "pause-30")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor(named: "customTintColor")
        return button
    }()
    
    lazy var stopButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "stop-30")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor(named: "customTintColor")
        return button
    }()
    
    lazy var cameraButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "camera-30")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor(named: "customTintColor")
        button.addTarget(self, action: #selector(didTapCameraButton), for: .touchUpInside)
        
        return button
    }()
    
    lazy var cameraPicker: ImagePicker = {
        let imagePicker = ImagePicker(presentationController: self, delegate: self)
        return imagePicker
    }()
    
    lazy var distanceLabel: UILabel = {
       let label = UILabel()
        label.textAlignment = .right
        label.text = "0.0 km"
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
    
    lazy var statusLabel: UILabel = {
       let label = UILabel()
        label.text = "산책중이에요!"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 20.0, weight: .bold)
        label.sizeToFit()
        
        return label
    }()
    
    required init(
        selectedPuppies: [Puppy]
    ) {
        self.selectedPuppies = selectedPuppies
        
        super.init(nibName: nil, bundle: nil)
        
        setupLayout()
        setupBinding()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//
//        bag = DisposeBag()
//    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        walkViewModel?.timerService.pauseTimer()
    }
    
    deinit {
        print("Deinit WalkViewController")
        bag = DisposeBag()
    }
}

// MARK: - Private Methods
private extension WalkViewController {
    func setupLayout() {
        let topMaskView = UIView()
        topMaskView.roundCorners([.bottomLeft, .bottomRight], radius: 25.0)
        topMaskView.backgroundColor = .white
        
        topMaskView.addSubview(statusLabel)
        statusLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(15.0)
        }
        
        let bottomMaskView = UIView()
        bottomMaskView.backgroundColor = .white
        bottomMaskView.roundCorners(.allCorners, radius: 25.0)
        
        let labelStackView = UIStackView(arrangedSubviews: [timeLabel, distanceLabel])
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
            $0.top.equalToSuperview().inset(10.0)
            $0.leading.trailing.equalToSuperview().inset(30.0)
            $0.height.equalToSuperview().multipliedBy(0.3)
        }
        
        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(labelStackView.snp.bottom).offset(10.0)
            $0.leading.trailing.equalToSuperview().inset(10.0)
            $0.bottom.equalToSuperview().inset(20.0)
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
            $0.height.equalTo(100.0)
        }
        
        mapView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        bottomMaskView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20.0)
            $0.bottom.equalToSuperview().inset(60.0)
            $0.height.equalToSuperview().multipliedBy(0.2)
        }
        
        myLocationButton.snp.makeConstraints {
            $0.bottom.equalTo(bottomMaskView.snp.top).offset(-15.0)
            $0.leading.equalToSuperview().inset(15.0)
            $0.width.height.equalTo(50.0)
        }
        
        fecesButton.snp.makeConstraints {
            $0.bottom.equalTo(bottomMaskView.snp.top).offset(-15.0)
            $0.trailing.equalToSuperview().inset(15.0)
            $0.width.height.equalTo(50.0)
        }
        
        view.bringSubviewToFront(topMaskView)
        view.bringSubviewToFront(bottomMaskView)
    }
    
    func setupBinding() {
        self.walkViewModel = WalkViewModel(viewController: self)
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
        
        stopButton.rx.tap
            .bind(to: input.stopButtonTapped)
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
                    self?.pausePlayButton.setImage(UIImage(named: "play-30"), for: .normal)
                case .play:
                    self?.pausePlayButton.setImage(UIImage(named: "pause-30")?.withRenderingMode(.alwaysTemplate), for: .normal)
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
                self?.setupAnnotationActionSheet(with: loc)
            })
            .disposed(by: bag)
        
        output.path
            .subscribe(onNext: { [weak self] path in
                self?.drawPathLine(with: path)
            })
            .disposed(by: bag)
        
        output.distanceRelay
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] distance in
                self?.distanceLabel.text = String(format: "%.1f km", distance * 0.001)
            })
            .disposed(by: bag)
        
        output.dismissRelay
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: bag)
    }
    
    @objc
    func closeBtnTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setupAnnotationActionSheet(with coordinate: CLLocationCoordinate2D) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let fecesAction = UIAlertAction(title: "대변", style: .default) { [weak self] _ in
            self?.setupAnnotation(with: coordinate, type: .feces)
        }
        let peeAction = UIAlertAction(title: "소변", style: .default) { [weak self] _ in
            self?.setupAnnotation(with: coordinate, type: .pee)
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        [fecesAction, peeAction, cancelAction]
            .forEach { actionSheet.addAction($0) }
        
        self.present(actionSheet, animated: true)
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
    
    @objc
    func didTapCameraButton() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            guard let self = self else { return }
            DispatchQueue.main.async { [weak self] in
                if granted == true {
                    self?.cameraPicker.present(pickerType: .camera)
                } else {
                    self?.setupReqAuthView()
                }
            }
        }
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

extension WalkViewController: TimerServiceDelegate {
    func timerTick(_ currentTi: Double) {
        self.timeLabel.text = format(seconds: currentTi)
    }
}

extension WalkViewController: ImagePickerDelegate {
    func didSelect(image: UIImage?) {
        guard let image = image else { return }
        
        // 로컬 저장
        UIImageWriteToSavedPhotosAlbum(
            image,
            self,
            #selector(self.image),
            nil
        )
    }
    
    @objc
    private func image(
        _ image: UIImage,
        didFinishSavingWithError err: Error?,
        contextInfo: UnsafeRawPointer
    ) {
        if err != nil {
            self.setupAlertView(with: "기기 이미지 저장 오류가 발생했습니다.")
        }
    }
}
