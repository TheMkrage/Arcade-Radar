//
//  SearchForNameViewControllerTableViewController.swift
//  Arcade Radar
//
//  Created by Matthew Krager on 5/8/16.
//  Copyright © 2016 Matthew Krager. All rights reserved.
//

import UIKit

class SearchForNameTableViewController: UITableViewController {
    
    // MARK: - Properties
    var backendless = Backendless()
    var filteredMachines = [ArcadeMachine]()
    let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - View Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        
        
        // Setup the Scope Bar
        searchController.searchBar.scopeButtonTitles = []
        
        tableView.tableHeaderView = searchController.searchBar
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table View
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return filteredMachines.count + 1
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ArcadeMachineCell", forIndexPath: indexPath) as! ArcadeMachineTableViewCell
        let machine: ArcadeMachine
        if searchController.active && searchController.searchBar.text != "" && indexPath.row < self.filteredMachines.count {
            machine = filteredMachines[indexPath.row]
            cell.machineNameLabel.text = machine.name
            cell.pricePerPlayLabel.text = "$\(machine.price) for \(machine.numOfPlays) \(machine.whatPriceIsFor)s"
        } else {
            cell.machineNameLabel.text = "Not Listed"
        }
        
        return cell
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        if searchController.searchBar.text != "" {
            let queryOptions = QueryOptions()
            //queryOptions.so
            let query = BackendlessDataQuery()
            query.queryOptions = queryOptions
            print(searchText)
            let pointsArr = searchText.componentsSeparatedByString(" ")
            var whereClause = "name LIKE '%\(searchText)%'"
            print(pointsArr)
            for x in pointsArr {
                if x != "" {
                    whereClause = "\(whereClause) OR name LIKE '%\(x)%'"
                }
            }
            print(whereClause)
            query.whereClause = whereClause
            backendless.persistenceService.of(ArcadeMachine.ofClass()).find(
                query,
                response: { ( machinesSearched : BackendlessCollection!) -> () in
                    let currentPage = machinesSearched.getCurrentPage()
                    print("SEARCHED: Loaded \(currentPage.count) machine objects")
                    var tempArray = [ArcadeMachine]()
                    for machine in currentPage {
                        print("SEARCHED! name = \(machine.name)")
                        tempArray.append(machine as! ArcadeMachine)
                    }
                    self.filteredMachines = tempArray
                    self.tableView.reloadData()
                },
                error: { ( fault : Fault!) -> () in
                    print("Server reported an error: \(fault)")
                }
            )
        }
    }
}

extension SearchForNameTableViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
    
}

extension SearchForNameTableViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
