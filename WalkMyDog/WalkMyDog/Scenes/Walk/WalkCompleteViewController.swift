//
//  WalkCompleteViewController.swift
//  WalkMyDog
//
//  Created by thoonk on 2022/08/20.
//

import UIKit
import MapKit
import RxSwift
import RxCocoa
import SnapKit

final class WalkCompleteViewController: UIViewController {
    // MARK: - UI Components
    lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(systemName: "xmark", size: 15.0)
        button.tintColor = UIColor(hex: "666666")
        button.addTarget(self, action: #selector(closeBtnTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var dateLabel: UILabel = {
       let label = UILabel()
        label.textAlignment = .center
        label.text = "2022년 8월 20일 토요일"
        label.textColor = UIColor(hex: "666666")
        label.font = UIFont.systemFont(ofSize: 18.0, weight: .bold)
        label.sizeToFit()
        
        return label
    }()
    
    lazy var timeLabel: UILabel = {
       let label = UILabel()
        label.textAlignment = .center
        label.text = "17:20 ~ 18:50"
        label.textColor = UIColor(hex: "D45F97")
        label.font = UIFont.systemFont(ofSize: 18.0, weight: .bold)
        label.sizeToFit()
        
        return label
    }()
    
    lazy var intervalStackView: VerticalLabelStackView = {
        let stackView = VerticalLabelStackView()
        return stackView
    }()
    
    lazy var distanceStackView: VerticalLabelStackView = {
        let stackView = VerticalLabelStackView()
        return stackView
    }()
    
    lazy var mapView: MKMapView = {
        let map = MKMapView()
        
        map.mapType = .standard
//        map.showsUserLocation = true
//        map.setUserTrackingMode(.follow, animated: true)
        map.isZoomEnabled = false
        map.isUserInteractionEnabled = true

        return map
    }()
    
    lazy var recommendIntervalLabel: UILabel = {
       let label = UILabel()
        label.textAlignment = .right
        label.text = "0분"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 25.0, weight: .bold)
        label.sizeToFit()
        
        return label
    }()
    
    lazy var caloriesLabel: UILabel = {
       let label = UILabel()
        label.textAlignment = .right
        label.text = "0kcal"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 25.0, weight: .bold)
        label.sizeToFit()
        
        return label
    }()
    
    lazy var fecesInfoLabel: UILabel = {
       let label = UILabel()
        label.textAlignment = .right
        label.text = "- / -"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 25.0, weight: .bold)
        label.sizeToFit()
        
        return label
    }()
    
    let selectedPuppies: [Puppy]
    var bag = DisposeBag()

    required init(
        selectedPuppies: [Puppy]
    ) {
        self.selectedPuppies = selectedPuppies
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        setupLayout()
        
        intervalStackView.configure(with: "시간", valueText: "1시간 30분")
        distanceStackView.configure(with: "거리", valueText: "2.5km")
    }
}

private extension WalkCompleteViewController {
    func setupLayout() {
        let guideLabel = UILabel()
        guideLabel.font = UIFont(name: "NanumSquareRoundR", size: 18.0)
        guideLabel.textColor = UIColor(hex: "046241")
        guideLabel.textAlignment = .left
        guideLabel.numberOfLines = 1
        guideLabel.text = "산책을 완료했습니다."
        
        let topView = UIStackView(arrangedSubviews: [guideLabel, closeButton])
        topView.distribution = .fillProportionally
        topView.alignment = .fill
        topView.spacing = 10.0
        
        closeButton.snp.makeConstraints {
            $0.width.height.equalTo(25.0)
        }
        
        let dateInfoView = UIView()
        dateInfoView.backgroundColor = UIColor(hex: "F2F2F2")
        
        [
            dateLabel,
            timeLabel
        ].forEach { dateInfoView.addSubview($0) }
        
        dateLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(10.0)
        }
        
        timeLabel.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(10.0)
            $0.bottom.leading.trailing.equalToSuperview().inset(10.0)
        }
        
        let walkInfoView = UIStackView(arrangedSubviews: [intervalStackView, distanceStackView])
        walkInfoView.distribution = .fillEqually
        walkInfoView.alignment = .fill
        walkInfoView.spacing = 30.0
        
        [
            topView,
            dateInfoView,
            walkInfoView,
            mapView
        ]
            .forEach { view.addSubview($0) }
        
        topView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20.0)
            $0.leading.trailing.equalToSuperview().inset(20.0)
            $0.height.equalTo(40.0)
        }
        
        dateInfoView.snp.makeConstraints {
            $0.top.equalTo(guideLabel.snp.bottom).offset(20.0)
            $0.leading.trailing.equalToSuperview().inset(20.0)
            $0.height.equalTo(80.0)
        }
        
        walkInfoView.snp.makeConstraints {
            $0.top.equalTo(dateInfoView.snp.bottom).offset(10.0)
            $0.leading.trailing.equalToSuperview().inset(25.0)
            $0.height.equalTo(80.0)
        }
        
        mapView.snp.makeConstraints {
            $0.top.equalTo(walkInfoView.snp.bottom).offset(10.0)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(200.0)
        }
    }
    
    @objc
    func closeBtnTapped() {
        self.dismiss(animated: true, completion: nil)
    }
}
