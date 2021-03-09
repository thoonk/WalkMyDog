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
    @IBOutlet weak var walkCalendarView: FSCalendar!
    @IBOutlet weak var headerLabel: UILabel!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if puppyInfo != nil {
            setRecordBinding()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUI()
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
    }
    
    private func setTableView() {
        recordTableView.rx.setDelegate(self)
            .disposed(by: bag)
        
        recordTableView.separatorStyle = .none
        recordTableView.delaysContentTouches = false
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
            .subscribe(onNext: { record in
                viewModel.input.recordSubject.onNext(record)
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
                self?.walkCalendarView.reloadData()
            }).disposed(by: bag)
        
        viewModel.output.errorMessage
            .subscribe(onNext: { [weak self] msg in
                self?.showAlert("산책 기록 로딩 실패", msg)
            }).disposed(by: bag)
    }
}

// MARK: - FSCalendar
extension RecordViewController: FSCalendarDataSource, FSCalendarDelegate {
    
    private func setCalendar() {
        walkCalendarView.delegate = self
        walkCalendarView.dataSource = self
        
        walkCalendarView.locale = Locale(identifier: "ko_KR")
        walkCalendarView.headerHeight = 0
        walkCalendarView.scope = .month
        walkCalendarView.appearance.weekdayTextColor = .lightGray
        walkCalendarView.appearance.todayColor = .systemIndigo
        walkCalendarView.placeholderType = .none
        
        headerLabel.text = self.dateFormatter.string(from: walkCalendarView.currentPage)
        headerLabel.adjustsFontSizeToFitWidth = true
    }
    
    private func scrollCurrentPage(isPrev: Bool) {
        let cal = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.month = isPrev ? -1 : 1
        
        self.currentPage = cal.date(byAdding: dateComponents, to: self.currentPage ?? self.today)
        self.walkCalendarView.setCurrentPage(self.currentPage!, animated: true)
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        self.headerLabel.text = self.dateFormatter.string(from: calendar.currentPage)
    }

    func calendar(_ calendar: FSCalendar, imageFor date: Date) -> UIImage? {
        if self.dateInfo.contains(date) {
            return UIImage(named: "dog-paw-48")?.resized(to: CGSize(width: 15, height: 15))
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
