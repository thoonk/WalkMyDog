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
    
    var puppyInfo: Puppy?
    var recordViewModel: RecordViewModel?
    var bag = DisposeBag()
    
    var currentPage: Date?
    lazy var today: Date = {
        return Date()
    }()
    
    @IBOutlet weak var recordTableView: UITableView!
    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var headerLabel: UILabel!
    
    @IBAction func prevBtnTapped(_ sender: UIButton) {
        scrollCurrentPage(isPrev: true)
    }
    
    @IBAction func nextBtnTapped(_ sender: UIButton) {
        scrollCurrentPage(isPrev: false)
    }
    
    func setCalendar() {
        calendarView.delegate = self
        calendarView.dataSource = self
        
        calendarView.locale = Locale(identifier: "ko_KR")
        calendarView.headerHeight = 0
        calendarView.scope = .month
        
        headerLabel.adjustsFontSizeToFitWidth = true
        
        //        calendarView.appearance.headerMinimumDissolvedAlpha = 0
        //        calendarView.appearance.headerDateFormat = "yyyy년 M월"
        //        calendarView.appearance.headerTitleColor = .black
        //        calendarView.appearance.headerTitleFont = UIFont.systemFont(ofSize: 20)
        calendarView.appearance.weekdayTextColor = .systemIndigo
        calendarView.appearance.todayColor = .cyan
    }
    
    func scrollCurrentPage(isPrev: Bool) {
        let cal = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.month = isPrev ? -1 : 1
        
        self.currentPage = cal.date(byAdding: dateComponents, to: self.currentPage ?? self.today)
        self.calendarView.setCurrentPage(self.currentPage!, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        let user1 = User(name: "user1", puppies: [])
        //        FIRStoreManager.shared.registerUserInfo(with: .users, for: user1)
        //        FIRStoreManager.shared.fetchUserInfo(from: .users, returning: User.self) { (user) in
        //            user1 = user
        //        }
        
        //        FIRStoreManager.shared.updateUserInfo(with: .users, for: user1)
        
        //        FIRStoreManager.shared.deleteUserInfo(with: .users)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setTableView()
        if puppyInfo != nil {
            setRecordBinding()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bag = DisposeBag()
    }
    
    /// 산책 기록 추가시 뷰 전환 메서드
    @objc
    private func goToEdit() {
        self.performSegue(withIdentifier: C.Segue.recordToEdit, sender: nil)
    }
    
    func setTableView() {
        recordTableView.rx.setDelegate(self)
            .disposed(by: bag)
        
        recordTableView.separatorStyle = .none
        recordTableView.delaysContentTouches = false
    }
    
    func setRecordBinding() {
        
        recordViewModel = RecordViewModel(with: puppyInfo!)
        guard let viewModel = recordViewModel else { return }
        
        let firstLoad = rx.viewWillAppear
            .take(1)
            .map { _ in () }
        
        let reload = recordTableView.refreshControl?.rx
            .controlEvent(.valueChanged)
            .map { _ in () } ?? Observable.just(())
        
        Observable.merge([firstLoad, reload])
            .bind(to: viewModel.input.fetchRecord)
            .disposed(by: bag)
        
        viewModel.output.recordData
            .bind(to: recordTableView.rx.items(cellIdentifier: C.Cell.record, cellType: RecordTableViewCell.self)) { index, item, cell in
                cell.bindData(data: item)
                cell.deleteRecordBtn.rx.tap
                    .bind(to: viewModel.input.deleteRecordBtnTapped)
                    .disposed(by: cell.bag)
            }.disposed(by: bag)
        
        recordTableView.rx.modelSelected(Record.self)
            .subscribe(onNext: { record in
                viewModel.input.recordSubject.onNext(record)
            }).disposed(by: bag)
        
        viewModel.output.errorMessage
            .subscribe(onNext: { [weak self] msg in
                self?.showAlert("산책 기록 로딩 실패", msg)
            }).disposed(by: bag)
    }
}

extension RecordViewController: FSCalendarDataSource, FSCalendarDelegate {
    // 캘린더 이벤트 등록
    //    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
    //        if self.events.contains(date) {
    //            return 1
    //        } else {
    //            return 0
    //        }
    //    }
    //
    //    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
    //        let dateFormatter = DateFormatter()
    //        dateFormatter.locale = Locale(identifier: "ko_KR")
    //        dateFormatter.dateFormat = "yyyy년 M월"
    //        self.headerLabel.text = dateFormatter.string(from: calendar.currentPage)
    //    }
}

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
