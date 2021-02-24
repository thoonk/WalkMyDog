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

    let viewModel = PuppiesViewModel()
    var bag = DisposeBag()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("hi")
        setBinding()
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
        let input = PuppiesViewModel.Input()
        let output = viewModel.bind(input: input)
        
        output.puppyData
            .bind(to: tableView.rx.items(cellIdentifier: C.Cell.puppy, cellType: PuppyTableViewCell.self)) { index, item, cell in
                cell.puppyNameLabel.text = item.name
                cell.puppyAgeLabel.text = Date().computeAge(with: item.age).description
                cell.puppyWeightLabel.text = String(item.weight)
                cell.puppySpeciesLabel.text = item.species
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


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
