//
//  CheckPuppyViewController.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/03/04.
//

import UIKit
import RxSwift
import RxCocoa
import PanModal

class CheckPuppyViewController: UIViewController {
    // MARK: - Interface Builder
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    @IBAction func selectBtnTapped(_ sender: UIButton) {
        if checkedPuppies.isEmpty {
            let alertVC = AlertManager.shared.showAlert(title: "알림", subTitle: "반려견을 한 마리 이상 선택해주세요!", actionBtnTitle: "확인")
            self.present(alertVC, animated: true)
        } else {
            self.performSegue(withIdentifier: C.Segue.checkToEdit, sender: checkedPuppies)
        }
    }
    // MARK: - Properties
    var viewModel: FetchAllPuppyViewModel?
    var bag = DisposeBag()
    var checkedPuppies: [Puppy] = []
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBinding()
        setUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bag = DisposeBag()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == C.Segue.checkToEdit,
           let selectedPuppy = sender as? [Puppy],
           let editRecordVC = segue.destination as? EditRecordViewController {
            editRecordVC.checkedPuppy = selectedPuppy
        }
    }
    // MARK: - Method
    func setUI() {
        tableView.separatorStyle = .none
        selectButton.titleLabel?.font = UIFont(name: "NanumGothic", size: 20)
    }
    // MARK: - ViewModel Binding
    func setBinding() {
        viewModel = FetchAllPuppyViewModel()
        let input = viewModel!.input
        let output = viewModel!.output
        
        //INPUT
        rx.viewWillAppear
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
            .bind(to: tableView.rx.items(cellIdentifier: C.Cell.check, cellType: CheckPuppyTableViewCell.self)) { [weak self] index, item, cell in
                cell.puppyNameLabel.text = item.name
                cell.checkWalkedButton.rx.tap.asObservable()
                    .subscribe(onNext: {
                        if cell.checkWalkedButton.isChecked == true {
                            self?.checkedPuppies.append(item)
                        } else {
                            let arrIndex = self?.checkedPuppies.firstIndex { $0.id == item.id }
                            self?.checkedPuppies.remove(at: arrIndex!)
                        }
                    }).disposed(by: cell.bag)
            }.disposed(by: bag)
        
        output.errorMessage
            .subscribe(onNext: { [weak self] msg in
                let alertVC = AlertManager.shared.showAlert(title: "모든 반려견 정보 로딩 실패", subTitle: msg, actionBtnTitle: "확인")
                self?.present(alertVC, animated: true, completion: {
                    input.fetchData.onNext(())
                })
            }).disposed(by: bag)
    }
}

// MARK: - PanModalPresentable
extension CheckPuppyViewController: PanModalPresentable {
    
    var panScrollable: UIScrollView? {
        return nil
    }
    
    var longFormHeight: PanModalHeight {
        return .contentHeight(300)
    }
    
    var anchorModalToLongForm: Bool {
        return true
    }
}
