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
    var isSendingToMap = true
    var backendless = Backendless()
    var filteredMachines = [ArcadeMachineType]()
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
        if self.isSendingToMap {
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("map") as! MapViewController
            vc.arcadeMachineWhereClauseExtension = "AND name = '\(self.filteredMachines[indexPath.row].name)'"
            self.showViewController(vc, sender: self)
        }else {
            let createViewController = self.storyboard?.instantiateViewControllerWithIdentifier("Create") as! CreateArcadeMachineViewController
            createViewController.nameOfMachine = filteredMachines[indexPath.row].name
            self.showViewController(createViewController, sender: self)
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let machine: ArcadeMachineType
        if searchController.active && searchController.searchBar.text != "" && indexPath.row < self.filteredMachines.count {
            machine = filteredMachines[indexPath.row]
            cell.textLabel!.text = machine.name
        } else {
            
            cell.textLabel!.text = "Not Listed"
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
            query.whereClause = whereClause
            dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0), { () -> Void in
                let machinesSearched: BackendlessCollection! = self.backendless.data.of(ArcadeMachineType.ofClass()).find(query)
                let currentPage = machinesSearched.getCurrentPage() as! [ArcadeMachineType]
                print("SEARCHED: Loaded \(currentPage.count) machine objects")
                var tempArray = [ArcadeMachineType]()
                for machine in currentPage {
                    print("SEARCHED! name = \(machine.name)")
                    tempArray.append(machine )
                }
                self.filteredMachines = tempArray
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                })
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
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if self.isSendingToMap {
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("map") as! MapViewController
            let searchText = searchBar.text!
            
            let pointsArr = searchText.componentsSeparatedByString(" ")
            var whereClause = "name LIKE '%\(searchText)%'"
            if pointsArr.count > 1 {
                for x in pointsArr {
                    if x != "" {
                        whereClause = "\(whereClause) OR name LIKE '%\(x)%'"
                    }
                }
            }
            
            vc.arcadeMachineWhereClauseExtension = "AND \(whereClause)"
            self.showViewController(vc, sender: self)
            
        }
        print("Taco")
    }
    
}

extension SearchForNameTableViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
