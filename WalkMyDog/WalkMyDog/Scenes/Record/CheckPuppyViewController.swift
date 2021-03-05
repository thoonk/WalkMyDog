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

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addRecordButton: UIButton!

    @IBAction func addRecordBtnTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: C.Segue.checkToEdit, sender: checkedPuppies)
    }
    
    var viewModel: FetchAllPuppyViewModel?
    var bag = DisposeBag()
    var checkedPuppies: [Puppy] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        setBinding()
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
    
    func setBinding() {
        viewModel = FetchAllPuppyViewModel()
        let output = viewModel!.output

        // OUTPUT
        output.puppyData
            .bind(to: tableView.rx.items(cellIdentifier: C.Cell.check, cellType: CheckPuppyTableViewCell.self)) { [weak self] index, item, cell in
                cell.puppyNameLabel.text = item.name
                cell.checkWalkedButton.rx.tap.asObservable().subscribe(onNext: {
                    if cell.checkWalkedButton.isChecked == true {
                        self?.checkedPuppies.append(item)
                    } else {
                        let arrIndex = self?.checkedPuppies.firstIndex { $0.id == item.id }
                        self?.checkedPuppies.remove(at: arrIndex!)
                    }
                }).disposed(by: cell.bag)
            }.disposed(by: bag)
    }
}

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
