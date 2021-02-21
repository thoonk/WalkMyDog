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
        setBinding()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bag = DisposeBag()
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
            }
            .disposed(by: bag)
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
