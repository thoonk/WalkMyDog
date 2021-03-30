//
//  SettingViewController.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/08.
//

import UIKit
import RxSwift
import RxCocoa

class SettingViewController: UIViewController, UIGestureRecognizerDelegate {
    // MARK: - Interface Builder
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    // MARK: - Properties
    var fetchAllPuppyViewModel: FetchAllPuppyViewModel?
    var bag = DisposeBag()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setFetchAllPuppyBindingg()
        setUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bag = DisposeBag()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == C.Segue.settingToEdit,
           let selectedItem = sender as? Puppy,
           let editPuppyVC = segue.destination as? EditPuppyViewController {
            editPuppyVC.puppyInfo = selectedItem
        }
    }
    
    // MARK: - Methods
    func setUI() {
        setTableView()
        setCustomBackBtn()
    }
    
    func setFetchAllPuppyBindingg() {
        fetchAllPuppyViewModel = FetchAllPuppyViewModel()
        let input = fetchAllPuppyViewModel!.input
        let output = fetchAllPuppyViewModel!.output
        
        // INPUT
        rx.viewDidAppear
            .take(1)
            .map { _ in () }
            .bind(to: input.fetchData)
            .disposed(by: bag)
        
        // OUTPUT
        output.isLoading
            .map { !$0 }
            .bind(to: activityIndicatorView.rx.isHidden)
            .disposed(by: bag)
        
        output.puppyData
            .bind(to: tableView.rx.items(cellIdentifier: C.Cell.puppy, cellType: PuppyTableViewCell.self)) { index, item, cell in
                cell.puppyNameLabel.text = item.name
            }.disposed(by: bag)
        
        output.errorMessage
            .subscribe(onNext: { [weak self] msg in
                let alertVC = AlertManager.shared.showAlert(title: "모든 반려견 정보 로딩 실패", subTitle: msg, actionBtnTitle: "확인")
                self?.present(alertVC, animated: true, completion: {
                    input.fetchData.onNext(())
                })
            }).disposed(by: bag)
        
        tableView.rx.modelSelected(Puppy.self)
            .subscribe(onNext: { [weak self] puppy in
                self?.performSegue(withIdentifier: C.Segue.settingToEdit, sender: puppy)
            }).disposed(by: bag)
    }
    
    /// 테이블뷰 설정
    func setTableView() {
        tableView.rx.setDelegate(self)
            .disposed(by: bag)
        tableView.separatorStyle = .none
        tableView.rowHeight = 50
    }
    
    /// 강쥐 정보 추가시 뷰 전환 메서드
    @objc
    private func goToEdit() {
        self.performSegue(withIdentifier: C.Segue.settingToEdit, sender: nil)
    }
}

// MARK: - UITableViewDelegate
extension SettingViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()//(frame: CGRect(x: 20, y: 0, width: 400, height: 50))
        headerView.isUserInteractionEnabled = true
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        let sectionImageView = UIImageView()//(frame: CGRect(x: 20, y: 15, width: 24, height: 24))
        sectionImageView.image = UIImage(named: "dog-24")
        headerView.addSubview(sectionImageView)

        sectionImageView.setAnchor(top: headerView.safeAreaLayoutGuide.topAnchor, leading: headerView.safeAreaLayoutGuide.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 15, left: 20, bottom: 0, right: 0), size: .init(width: 25, height: 25))
        
        let sectionLabel = UILabel() // (frame: CGRect(x: 50, y: 10, width: 100, height: 37))
        sectionLabel.font = UIFont(name: "NanumGothic", size: 15)
        sectionLabel.text = "반려견"
        headerView.addSubview(sectionLabel)
        
        sectionLabel.setAnchor(top: headerView.safeAreaLayoutGuide.topAnchor, leading: sectionImageView.trailingAnchor, bottom: nil, trailing: nil, padding: .init(top: 10, left: 15, bottom: 0, right: 0), size: .init(width: 100, height: 37))

        let addPuppyBtn = UIButton() // (frame: CGRect(x: 320, y: 10, width: 60, height: 37))
        addPuppyBtn.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        addPuppyBtn.isUserInteractionEnabled = true
        addPuppyBtn.isEnabled = true
        addPuppyBtn.tintColor = .lightGray
        addPuppyBtn.addTarget(self, action: #selector(goToEdit), for: .touchUpInside)
        headerView.addSubview(addPuppyBtn)
        
        addPuppyBtn.setAnchor(top: headerView.safeAreaLayoutGuide.topAnchor, leading: nil, bottom: nil, trailing: headerView.safeAreaLayoutGuide.trailingAnchor, padding: .init(top: 10, left: 0, bottom: 0, right: 10), size: .init(width: 50, height: 37))

        let underBar = UIView()
        underBar.backgroundColor = .lightGray
        headerView.addSubview(underBar)
        
        underBar.setAnchor(top: sectionLabel.bottomAnchor, leading: headerView.safeAreaLayoutGuide.leadingAnchor, bottom: headerView.safeAreaLayoutGuide.bottomAnchor, trailing: headerView.safeAreaLayoutGuide.trailingAnchor, padding: .init(top: 2, left: 20, bottom: 5, right: 0), size: .init(width: view.frame.size.width-20, height: 1))

        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
}
