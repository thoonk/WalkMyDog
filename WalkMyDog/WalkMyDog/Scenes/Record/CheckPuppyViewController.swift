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
    
    var viewModel: CheckPuppyViewModel?
    var bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        setBinding()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        bag = DisposeBag()
    }
    
    @IBAction func addRecordBtnTapped(_ sender: UIButton) {
    }
    
    func setBinding() {
        viewModel = CheckPuppyViewModel()
        let output = viewModel!.output

        // OUTPUT
        output.puppyData
            .bind(to: tableView.rx.items(cellIdentifier: C.Cell.check, cellType: CheckPuppyTableViewCell.self)) { index, item, cell in
                cell.puppyNameLabel.text = item.name
            }.disposed(by: bag)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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
