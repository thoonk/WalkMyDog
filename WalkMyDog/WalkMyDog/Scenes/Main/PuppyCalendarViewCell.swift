//
//  PuppyCalendarViewCell.swift
//  WalkMyDog
//
//  Created by thoonk on 2022/03/26.
//

import Foundation
import UIKit
import FSCalendar
import SnapKit

final class PuppyCalendarViewCell: UITableViewCell {
    static let identifier = "PuppyCalendarViewCell"
    
    lazy var calendarView: FSCalendar = {
        let calendarView = FSCalendar()
        calendarView.locale = Locale(identifier: "ko_KR")
        calendarView.headerHeight = 0
        calendarView.scope = .month
        calendarView.appearance.weekdayTextColor = .lightGray
        calendarView.appearance.todayColor = UIColor(named: "customTintColor")
        calendarView.placeholderType = .none
        
        return calendarView
    }()
    
    private lazy var headerDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ko_KR")
        df.dateFormat = "yyyy년 M월"
        return df
    }()
    
    lazy var calendarHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = self.headerDateFormatter.string(from: calendarView.currentPage)
        label.font = UIFont(name: "NanumSquareRoundB", size: 17.0)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        
        return label
    }()
    
    lazy var prevMonthButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "chevron-left"), for: .normal)
        button.tintColor = .black
        
        return button
    }()
    
    lazy var nextMonthButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "chevron-right"), for: .normal)
        button.tintColor = .black
        
        return button
    }()
    
    lazy var startWalkingButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(named: "customTintColor")
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "NanumSquareRoundB", size: 15.0)
        button.setTitle("산책가자", for: .normal)
        button.setImage(UIImage(named: "footPrint"), for: .normal)
        button.tintColor = .white
        button.semanticContentAttribute = .forceRightToLeft
        button.roundCorners(.allCorners, radius: 15.0)
        
        return button
    }()
    
    lazy var summaryLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor(hex: "F2F2F2")
        label.font = UIFont(name: "NanumSquareRoundR", size: 15.0)
        label.textColor = UIColor(hex: "666666")
        label.roundCorners(.allCorners, radius: 15.0)
        label.text = "2022년 3월 26일 토요일 21:13\n30분 / 1.5km / 10.5kcal"
        return label
    }()
    
    lazy var distanceStackView: WalkInfoView = {
        let view = WalkInfoView()
        return view
    }()
    
    lazy var timeStackView: WalkInfoView = {
        let view = WalkInfoView()
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        
    }
}

private extension PuppyCalendarViewCell {
    func setupLayout() {
        self.backgroundColor = .white
        
        let calendarHeaderStackView = UIStackView(arrangedSubviews: [
            prevMonthButton,
            calendarHeaderLabel,
            nextMonthButton
        ])
        
        calendarHeaderStackView.alignment = .fill
        calendarHeaderStackView.distribution = .equalSpacing
        
        prevMonthButton.snp.makeConstraints {
            $0.width.equalTo(25.0)
        }
        
        nextMonthButton.snp.makeConstraints {
            $0.width.equalTo(25.0)
        }
        
        let walkStackView = UIStackView(arrangedSubviews: [
            distanceStackView,
            timeStackView
        ])
        
        walkStackView.alignment = .fill
        walkStackView.distribution = .fillEqually
        walkStackView.spacing = 5.0
        
        [
            calendarHeaderStackView,
            startWalkingButton,
            walkStackView,
            calendarView,
            summaryLabel
        ]
            .forEach { self.addSubview($0) }
        
        
        calendarHeaderStackView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(10.0)
            $0.height.equalTo(50.0)
        }
        
        startWalkingButton.snp.makeConstraints {
            $0.top.equalTo(calendarHeaderStackView.snp.bottom).offset(10.0)
            $0.leading.trailing.equalToSuperview().inset(15.0)
        }
        
        walkStackView.snp.makeConstraints {
            $0.top.equalTo(startWalkingButton.snp.bottom).offset(10.0)
            $0.leading.trailing.equalToSuperview().inset(15.0)
        }
        
        calendarView.snp.makeConstraints {
            $0.top.equalTo(walkStackView.snp.bottom).offset(10.0)
            $0.leading.trailing.equalToSuperview().inset(10.0)
            $0.height.greaterThanOrEqualTo(100.0)
        }
        
        summaryLabel.snp.makeConstraints {
            $0.top.equalTo(calendarView.snp.bottom).offset(10.0)
            $0.leading.trailing.equalToSuperview().inset(15.0)
            $0.bottom.equalToSuperview()
        }
    }
}
