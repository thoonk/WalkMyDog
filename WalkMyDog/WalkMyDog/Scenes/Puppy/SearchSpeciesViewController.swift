//
//  SearchSpeciesViewController.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/03/19.
//

import UIKit

class SearchSpeciesViewController: UIViewController {
    // MARK: - Interface Builder
    @IBOutlet weak var speciesTableView: UITableView!
    
    // MARK: - Properties
    var searchResults = [String]()
    let searchController = UISearchController(searchResultsController: nil)
    weak var delegate: SelectSpeciesDelegate?
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        speciesTableView.dataSource = self
        speciesTableView.delegate = self
        
        self.definesPresentationContext = true
        navigationItem.titleView = searchController.searchBar
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUI()
    }
    
    func setUI() {
        let backImg = UIImage(systemName: "chevron.backward")?.resized(to: CGSize(width: 20, height: 20))
        navigationController?.navigationBar.backIndicatorImage = backImg
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImg
        
        navigationItem.leftItemsSupplementBackButton = true
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
    }
    
    func filterSpecies(from inputText: String) {
        searchResults = C.PuppyInfo.species.filter {
            let match = $0.range(of: inputText, options: .caseInsensitive)
            return match != nil
        }
    }
}
// MARK: - SearchResultsUpdating
extension SearchSpeciesViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterSpecies(from: searchText)
            speciesTableView.reloadData()
        }
    }
}

// MARK: - TableView
extension SearchSpeciesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isActive ? searchResults.count : C.PuppyInfo.species.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let items = searchController.isActive ? searchResults[indexPath.row] : C.PuppyInfo.species[indexPath.row]
        
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: C.Cell.species, for: indexPath)
        cell.textLabel?.text = items
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selected = searchController.isActive ? searchResults[indexPath.row] : C.PuppyInfo.species[indexPath.row]
        delegate?.didSelectSpecies(with: selected)
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "견종"
    }
}
