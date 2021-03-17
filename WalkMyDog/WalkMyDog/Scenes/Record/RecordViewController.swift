//
//  RecordViewController.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/16.
//

import UIKit
import FSCalendar
import RxSwift
import RxCocoa
import RxViewController

class RecordViewController: UIViewController {
    
    @IBOutlet weak var recordTableView: UITableView!
    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var walkCalendarView: UIView!
    @IBOutlet weak var sumAvgRecordView: UIView!
    @IBOutlet weak var sumIntervalLabel: UILabel!
    @IBOutlet weak var sumDistLabel: UILabel!
    @IBOutlet weak var avgIntervalLabel: UILabel!
    @IBOutlet weak var avgDistLabel: UILabel!
    @IBOutlet weak var prevMonthButton: UIButton!
    @IBOutlet weak var nextMonthButton: UIButton!
    
    @IBAction func prevBtnTapped(_ sender: UIButton) {
        scrollCurrentPage(isPrev: true)
    }
    
    @IBAction func nextBtnTapped(_ sender: UIButton) {
        scrollCurrentPage(isPrev: false)
    }
    
    var puppyInfo: Puppy?
    private var recordViewModel: RecordViewModel?
    private var bag = DisposeBag()
    
    private var dateInfo: [Date] = []
    private var currentPage: Date?
    private lazy var today: Date = {
        return Date()
    }()
    
    private lazy var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ko_KR")
        df.dateFormat = "yyyy년 M월"
        return df
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUI()
        if puppyInfo != nil {
            setRecordBinding()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bag = DisposeBag()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == C.Segue.recordToEdit,
           let selectedItem = sender as? [Puppy],
           let editRecordVC = segue.destination as? EditRecordViewController {
            editRecordVC.checkedPuppy = selectedItem
        }
    }
    
    /// 산책 기록 추가시 뷰 전환 메서드
    @objc
    private func goToEdit() {
        var checkedPuppy = [Puppy]()
        checkedPuppy.append(puppyInfo!)
        self.performSegue(withIdentifier: C.Segue.recordToEdit, sender: checkedPuppy)
    }
    
    private func setUI() {
        setTableView()
        setCalendar()
        sumAvgRecordView.layer.cornerRadius = 10
    }
    
    private func setTableView() {
        recordTableView.rx.setDelegate(self)
            .disposed(by: bag)
        
        recordTableView.separatorStyle = .none
        recordTableView.delaysContentTouches = false
        recordTableView.layer.cornerRadius = 10
    }
    
    private func setRecordBinding() {
        
        recordViewModel = RecordViewModel(with: puppyInfo!)
        guard let viewModel = recordViewModel else { return }
        
        // INPUT
        let firstLoad = rx.viewWillAppear
            .take(1)
            .map { _ in () }
        
        let reload = recordTableView.refreshControl?.rx
            .controlEvent(.valueChanged)
            .map { _ in () } ?? Observable.just(())
        
        Observable.merge([firstLoad, reload])
            .bind(to: viewModel.input.fetchRecord)
            .disposed(by: bag)
        
        recordTableView.rx.modelSelected(Record.self)
            .debug()
            .subscribe(onNext: { record in
                viewModel.input.recordSubject.onNext(record)
            }).disposed(by: bag)
 
        prevMonthButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                viewModel.input.currentDate.onNext((self?.calendarView.currentPage)!)
            }).disposed(by: bag)
        
        nextMonthButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                viewModel.input.currentDate.onNext((self?.calendarView.currentPage)!)
            }).disposed(by: bag)
        
        //OUTPUT
        viewModel.output.recordData
            .bind(to: recordTableView.rx.items(cellIdentifier: C.Cell.record, cellType: RecordTableViewCell.self)) { index, item, cell in
                cell.bindData(data: item)
                cell.deleteRecordBtn.rx.tap
                    .bind(to: viewModel.input.deleteRecordBtnTapped)
                    .disposed(by: cell.bag)
            }.disposed(by: bag)
        
        viewModel.output.timeStamp
            .subscribe(onNext: { [weak self] data in
                self?.dateInfo = data
                self?.calendarView.reloadData()
            }).disposed(by: bag)
        
        viewModel.output.errorMessage
            .subscribe(onNext: { [weak self] msg in
                self?.showAlert("산책 기록 로딩 실패", msg)
            }).disposed(by: bag)
        
        viewModel.output.sumInterval
            .bind(to: sumIntervalLabel.rx.text)
            .disposed(by: bag)
        
        viewModel.output.avgInterval
            .bind(to: avgIntervalLabel.rx.text)
            .disposed(by: bag)
        
        viewModel.output.sumDist
            .bind(to: sumDistLabel.rx.text)
            .disposed(by: bag)
        
        viewModel.output.avgDist
            .bind(to: avgDistLabel.rx.text)
            .disposed(by: bag)
    }
}

// MARK: - FSCalendar
extension RecordViewController: FSCalendarDelegate, FSCalendarDataSource {
    
    private func setCalendar() {
        calendarView.delegate = self
        calendarView.dataSource = self
        
        walkCalendarView.layer.cornerRadius = 10
        walkCalendarView.layer.masksToBounds = true
        calendarView.locale = Locale(identifier: "ko_KR")
        calendarView.headerHeight = 0
        calendarView.scope = .month
        calendarView.appearance.weekdayTextColor = .lightGray
        calendarView.appearance.todayColor = .systemIndigo
        calendarView.placeholderType = .none
        
        headerLabel.text = self.dateFormatter.string(from: calendarView.currentPage)
        headerLabel.adjustsFontSizeToFitWidth = true
    }
    
    private func scrollCurrentPage(isPrev: Bool) {
        let cal = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.month = isPrev ? -1 : 1
        
        self.currentPage = cal.date(byAdding: dateComponents, to: self.currentPage ?? self.today)
        self.calendarView.setCurrentPage(self.currentPage!, animated: true)
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        self.headerLabel.text = self.dateFormatter.string(from: calendar.currentPage)
    }

    func calendar(_ calendar: FSCalendar, imageFor date: Date) -> UIImage? {
        if self.dateInfo.contains(date) {
            return UIImage(named: "dog-paw-48")?.resized(to: CGSize(width: 10, height: 10))
        } else {
            return nil
        }
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        return false
    }
}

// MARK: - TableViewDelegate
extension RecordViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 20, y: 0, width: 350, height: 50))
        headerView.isUserInteractionEnabled = true
        
        let sectionLabel = UILabel(frame: CGRect(x: 20, y: 10, width: 100, height: 35))
        sectionLabel.text = "산책 내역"
        
        let addRecordBtn = UIButton(frame: CGRect(x: 280, y: 10, width: 80, height: 35))

        addRecordBtn.setImage(UIImage(systemName: "plus"), for: .normal)
        addRecordBtn.isUserInteractionEnabled = true
        addRecordBtn.isEnabled = true
        addRecordBtn.tintColor = .lightGray
        addRecordBtn.addTarget(self, action: #selector(goToEdit), for: .touchUpInside)
        
        let underBar = UIView(frame: CGRect(x: 20, y: 47, width: 320, height: 1))
        underBar.backgroundColor = .lightGray
        
        headerView.addSubview(sectionLabel)
        headerView.addSubview(addRecordBtn)
        headerView.addSubview(underBar)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        50
    }
}
