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

    var viewModel: PuppiesViewModel?
    var bag = DisposeBag()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBinding()
        setTableView()
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
    
    func setBinding() {
        viewModel = PuppiesViewModel()
        let output = viewModel!.output
            
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
        let headerView = UIView(frame: CGRect(x: 20, y: 10, width: 400, height: 40))
        headerView.isUserInteractionEnabled = true
        
        let sectionLabel = UILabel(frame: CGRect(x: 20, y: 10, width: 100, height: 25))
        sectionLabel.text = "반려견"
        
        let addPuppyBtn = UIButton(frame: CGRect(x: 300, y: 10, width: 100, height: 25))
        addPuppyBtn.setTitle("추가", for: .normal)
        addPuppyBtn.setTitleColor(.magenta, for: .normal)
        addPuppyBtn.isUserInteractionEnabled = true
        addPuppyBtn.isEnabled = true
        addPuppyBtn.tintColor = .blue
        addPuppyBtn.addTarget(self, action: #selector(goToEdit), for: .touchUpInside)
        
        let underBar = UIView(frame: CGRect(x: 20, y: 37, width: 350, height: 1))
        underBar.backgroundColor = .lightGray
        
        headerView.addSubview(sectionLabel)
        headerView.addSubview(addPuppyBtn)
        headerView.addSubview(underBar)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}
