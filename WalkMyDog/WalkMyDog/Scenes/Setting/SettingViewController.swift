//
//  SettingViewController.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/08.
//

import UIKit
import RxSwift
import RxCocoa

class SettingViewController: UIViewController {

    var fetchAllPuppyViewModel: FetchAllPuppyViewModel?
    var bag = DisposeBag()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setFetchAllPuppyBinding()
        setUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bag = DisposeBag()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == C.Segue.settingToEdit,
           let selectedItem = sender as? Puppy,
           let editPuppyVC = segue.destination as? EditPuppyViewController {
            editPuppyVC.puppyInfo = selectedItem
        }
    }
    
    func setUI() {
        setTableView()
        
        let backImg = UIImage(systemName: "chevron.backward")?.resized(to: CGSize(width: 20, height: 20))
        navigationController?.navigationBar.backIndicatorImage = backImg
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImg
        
        navigationItem.leftItemsSupplementBackButton = true
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
    }
    
    func setFetchAllPuppyBinding() {
        fetchAllPuppyViewModel = FetchAllPuppyViewModel()
        let output = fetchAllPuppyViewModel!.output
            
        output.puppyData
            .bind(to: tableView.rx.items(cellIdentifier: C.Cell.puppy, cellType: PuppyTableViewCell.self)) { index, item, cell in
                cell.puppyNameLabel.text = item.name
            }.disposed(by: bag)
        
        output.errorMessage
            .subscribe(onNext: { [weak self] msg in
                self?.showAlert("반려견 정보 로딩 실패", msg)
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

        sectionImageView.translatesAutoresizingMaskIntoConstraints = false
        sectionImageView.topAnchor.constraint(equalTo: headerView.safeAreaLayoutGuide.topAnchor, constant: 15).isActive = true
        sectionImageView.leadingAnchor.constraint(equalTo: headerView.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        sectionImageView.widthAnchor.constraint(equalToConstant: 25).isActive = true
        sectionImageView.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        let sectionLabel = UILabel() // (frame: CGRect(x: 50, y: 10, width: 100, height: 37))
        sectionLabel.font = UIFont.systemFont(ofSize: 17.0)
        sectionLabel.text = "반려견"
        headerView.addSubview(sectionLabel)
        
        sectionLabel.translatesAutoresizingMaskIntoConstraints = false
        sectionLabel.topAnchor.constraint(equalTo: headerView.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        sectionLabel.leadingAnchor.constraint(equalTo: sectionImageView.trailingAnchor, constant: 15).isActive = true
        sectionLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        sectionLabel.heightAnchor.constraint(equalToConstant: 37).isActive = true

        let addPuppyBtn = UIButton() // (frame: CGRect(x: 320, y: 10, width: 60, height: 37))
        addPuppyBtn.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        addPuppyBtn.isUserInteractionEnabled = true
        addPuppyBtn.isEnabled = true
        addPuppyBtn.tintColor = .lightGray
        addPuppyBtn.addTarget(self, action: #selector(goToEdit), for: .touchUpInside)
        headerView.addSubview(addPuppyBtn)
        
        addPuppyBtn.translatesAutoresizingMaskIntoConstraints = false
        addPuppyBtn.topAnchor.constraint(equalTo: headerView.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        addPuppyBtn.trailingAnchor.constraint(equalTo: headerView.safeAreaLayoutGuide.trailingAnchor, constant: -50).isActive = true
        addPuppyBtn.widthAnchor.constraint(equalToConstant: 50).isActive = true
        addPuppyBtn.heightAnchor.constraint(equalToConstant: 37).isActive = true

        let underBar = UIView() // (frame: CGRect(x: 20, y: 48, width: 340, height: 1))
        underBar.backgroundColor = .lightGray
        headerView.addSubview(underBar)
        
        underBar.translatesAutoresizingMaskIntoConstraints = false
        underBar.bottomAnchor.constraint(equalTo: headerView.safeAreaLayoutGuide.bottomAnchor, constant: 5).isActive = true
        underBar.topAnchor.constraint(equalTo: sectionLabel.bottomAnchor, constant: 1).isActive = true
        underBar.leadingAnchor.constraint(equalTo: headerView.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        underBar.trailingAnchor.constraint(equalTo: headerView.safeAreaLayoutGuide.trailingAnchor).isActive = true
        underBar.widthAnchor.constraint(equalToConstant: 408).isActive = true
        underBar.heightAnchor.constraint(equalToConstant: 1).isActive = true

        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
}
