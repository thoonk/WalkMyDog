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
import RxSwift

enum HeaderButton: Int {
    case prev = 301
    case next = 302
}

enum DateFormat: String {
    case header = "yyyy년 M월"
    case calendar = "yyyy-MM-dd"
    case summary = "yyyy년 M월 d일 EEEE hh:mm"
}

typealias CalendarData = (
    count: Int,
    totalDistance: Double,
    averageDistance: Double,
    totalTime: Int,
    averageTime: Int
)

final class PuppyCalendarViewCell: UITableViewCell {
    static let identifier = "PuppyCalendarViewCell"
    
    private var bag = DisposeBag()
    
    lazy var calendarView: FSCalendar = {
        let calendarView = FSCalendar()
        calendarView.locale = Locale(identifier: "ko_KR")
        calendarView.headerHeight = 0
        calendarView.scope = .month
        calendarView.appearance.weekdayTextColor = .lightGray
        calendarView.appearance.todayColor = UIColor(named: "customTintColor")
        calendarView.placeholderType = .none
        calendarView.delegate = self
        calendarView.dataSource = self
        
        return calendarView
    }()
    
    private lazy var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ko_KR")
        return df
    }()
    
    lazy var calendarHeaderLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        setupDateFormatter(with: .header)
        label.text = self.dateFormatter.string(from: calendarView.currentPage)
        label.font = UIFont(name: "NanumSquareRoundB", size: 17.0)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        
        return label
    }()
    
    lazy var prevMonthButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "chevron-left"), for: .normal)
        button.tintColor = .black
        button.tag = HeaderButton.prev.rawValue
        button.addTarget(self, action: #selector(handleCalendarHeaderButton(_:)), for: .touchUpInside)
        
        return button
    }()
    
    lazy var nextMonthButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "chevron-right"), for: .normal)
        button.tintColor = .black
        button.tag = HeaderButton.next.rawValue
        button.addTarget(self, action: #selector(handleCalendarHeaderButton(_:)), for: .touchUpInside)
        
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
        label.textAlignment = .center
        label.roundCorners(.allCorners, radius: 15.0)
        label.text = "현재 선택하신 날짜의 산책 기록이 없습니다."
        label.numberOfLines = 2
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
    
    private var currentPage: Date?
    private lazy var today: Date = {
        return Date()
    }()
    
    private var puppyInfo: Puppy?
    private var records = [Record]()
    
    private var dateInfo = [String]() {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.calendarView.reloadData()
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        bag = DisposeBag()
    }
    
    func configure(with puppy: Puppy, walkButtonTapObserver: PublishSubject<Void>) {
        self.puppyInfo = puppy
        self.records = Array(puppy.records)
        
        let calendarData = computeCalendarData()
        
        distanceStackView.walkFormLabel.text = "\(puppy.name)와\n내가 달린 거리"
        distanceStackView.walkResultLabel.text = "총 \(String(format: "%.1fkm", calendarData.totalDistance * 0.001))\n평균 \(String(format: "%.1fkm", calendarData.averageDistance * 0.001))"
        
        timeStackView.walkFormLabel.text = "\(puppy.name)와\n내가 달린 시간"
        timeStackView.walkResultLabel.text = "총 \(formatTime(with: calendarData.totalTime))\n평균 \(formatTime(with: calendarData.averageTime))"
        
        DispatchQueue.main.async { [weak self] in
            self?.calendarView.reloadData()
        }
        
        startWalkingButton.rx.tap
            .bind(to: walkButtonTapObserver)
            .disposed(by: bag)
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
            $0.width.equalTo(50.0)
        }
        
        nextMonthButton.snp.makeConstraints {
            $0.width.equalTo(50.0)
        }
        
        let walkStackView = UIStackView(arrangedSubviews: [
            distanceStackView,
            timeStackView
        ])
        
        walkStackView.alignment = .fill
        walkStackView.distribution = .fillEqually
        walkStackView.spacing = 15.0
        
        [
            calendarHeaderStackView,
            startWalkingButton,
            walkStackView,
            calendarView,
            summaryLabel
        ]
            .forEach { contentView.addSubview($0) }
        
        calendarHeaderStackView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(10.0)
            $0.height.equalTo(50.0)
        }
        
        startWalkingButton.snp.makeConstraints {
            $0.top.equalTo(calendarHeaderStackView.snp.bottom).offset(10.0)
            $0.leading.trailing.equalToSuperview().inset(20.0)
            $0.height.equalTo(50.0)
        }
        
        walkStackView.snp.makeConstraints {
            $0.top.equalTo(startWalkingButton.snp.bottom).offset(10.0)
            $0.leading.trailing.equalToSuperview().inset(20.0)
        }
        
        calendarView.snp.makeConstraints {
            $0.top.equalTo(walkStackView.snp.bottom).offset(10.0)
            $0.leading.trailing.equalToSuperview().inset(10.0)
            $0.height.greaterThanOrEqualTo(200.0)
        }
        
        summaryLabel.snp.makeConstraints {
            $0.top.equalTo(calendarView.snp.bottom).offset(10.0)
            $0.leading.trailing.equalToSuperview().inset(15.0)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(50.0)
        }
    }
    
    @objc
    func handleCalendarHeaderButton(_ sender: UIButton) {
        if let type = HeaderButton(rawValue: sender.tag) {
            switch type {
            case .prev:
                scrollCurrentPage(isPrev: true)
            case .next:
                scrollCurrentPage(isPrev: false)
            }
        }
    }
    
   func scrollCurrentPage(isPrev: Bool) {
        let cal = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.month = isPrev ? -1 : 1
        
        self.currentPage = cal.date(
            byAdding: dateComponents,
            to: self.currentPage ?? self.today
        )
        self.calendarView.setCurrentPage(self.currentPage!, animated: true)
    }
    
    func formatTime(with time: Int) -> String {
        let hours = time / 3600
        let minutes = (time / 60) % 60
        
        if hours > 0 {
            if minutes > 0 {
                return "\(hours)시간 \(minutes)분"
            } else {
                return "\(hours)시간"
            }
        } else {
            if minutes > 0 {
                return "\(minutes)분"
            } else {
                return "1분 이하"
            }
        }
    }
    
    func setupDateFormatter(with type: DateFormat) {
        self.dateFormatter.dateFormat = type.rawValue
    }
    
    func computeCalendarData() -> CalendarData {
        var totalDistance: Double = 0.0
        var totalTime: Int = 0
        setupDateFormatter(with: .calendar)
        
        for record in records {
            let dateString = dateFormatter.string(from: record.timeStamp)
            self.dateInfo.append(dateString)
            
            totalDistance += record.distance
            totalTime += record.interval
        }
        
        let count = records.count
        var averageDistance = totalDistance / Double(count)
        let averageTime = count == 0 ? 0 : totalTime / count
        
        if averageDistance.isNaN == true {
            averageDistance = 0.0
        }
        
        return CalendarData(count, totalDistance, averageDistance, totalTime, averageTime)
    }
}

extension PuppyCalendarViewCell: FSCalendarDelegate, FSCalendarDataSource {
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        setupDateFormatter(with: .header)
        self.calendarHeaderLabel.text = self.dateFormatter.string(from: self.calendarView.currentPage)
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        setupDateFormatter(with: .calendar)
        let dateString = self.dateFormatter.string(from: date)
        
        if self.dateInfo.contains(dateString) {
            return 1
        } else {
            return 0
        }
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let newDate = date.addingTimeInterval(TimeInterval(NSTimeZone.local.secondsFromGMT()))
        
        setupDateFormatter(with: .summary)
        
        for record in records {
            if record.timeStamp.isEqual(to: newDate) {
                let dateString = self.dateFormatter.string(from: record.timeStamp)
                let distance = String(format: "%.1fkm", record.distance * 0.001)
                
                self.summaryLabel.text = "\(dateString)\n\(formatTime(with: record.interval)) / \(distance) / \(record.calories)kcal"
            }
        }
    }
    
//    func calendar(_ calendar: FSCalendar, imageFor date: Date) -> UIImage? {
//        let dateString = self.calendarDateFormatter.string(from: date)
//
//        if self.dateInfo.contains(dateString) {
//            return UIImage(named: "dog-paw-48")?
//                .resized(to: CGSize(width: 10, height: 10))
//        } else {
//            return nil
//        }
//    }
}
