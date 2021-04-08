//
//  SearchSpeciesViewController.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/03/19.
//

import UIKit
import RxSwift
import RxCocoa

class SearchSpeciesViewController: UIViewController {
    // MARK: - Interface Builder
    @IBOutlet weak var speciesTableView: UITableView!
    
    // MARK: - Properties
    let searchController = UISearchController(searchResultsController: nil)
    let searchSpeciesViewModel = SearchSpeciesViewModel()
    var bag = DisposeBag()
    weak var delegate: SelectSpeciesDelegate?
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpSearchController()
        setCustomBackBtn()
        setSearchSpeciesViewModel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bag = DisposeBag()
    }
    
    // MARK: - ViewModel Binding
    private func setSearchSpeciesViewModel() {
        let input = searchSpeciesViewModel.input
        let output = searchSpeciesViewModel.output
        
        // INPUT
        searchController.searchBar.rx.text
            .bind { [weak self] text in
                if self?.searchController.isActive == true {
                    input.searchingText.onNext(text!)
                } else {
                    input.searchingText.onNext("")
                }
            }
            .disposed(by: bag)
        
        // OUTPUT
        output.searchResult
            .bind(to: speciesTableView.rx.items) { (tv, index, item) -> UITableViewCell in
                guard let cell = tv.dequeueReusableCell(withIdentifier: C.Cell.species) else { return UITableViewCell() }
                cell.textLabel?.text = item
                cell.textLabel?.font = UIFont(name: "NanumGothic", size: 15)
                return cell
            }
            .disposed(by: bag)
        
        Observable
            .zip(speciesTableView.rx.itemSelected,
                 speciesTableView.rx.modelSelected(String.self))
            .bind { [weak self] indexPath, item in
                self?.speciesTableView.deselectRow(at: indexPath, animated: true)
                
                self?.delegate?.didSelectSpecies(with: item)
                self?.navigationController?.popViewController(animated: true)
            }
            .disposed(by: bag)
    }
    
    // MARK: - Methods
    private func setUpSearchController() {
        self.definesPresentationContext = true
        navigationItem.titleView = searchController.searchBar
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(named: "customTintColor")!,
            .font: UIFont(name: "NanumGothic", size: 17)!
        ]
        
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(attributes, for: .normal)
        
        searchController.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "견종을 입력해주세요!", attributes: [NSAttributedString.Key.font: UIFont(name: "NanumGothic", size: 17)!])
    }
}
