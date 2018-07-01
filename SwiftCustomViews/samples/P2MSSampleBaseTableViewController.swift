//
//  P2MSSampleBaseTableViewController.swift
//  SwiftCustomViews
//
//  Created by Pyae Phyo Myint Soe on 1/7/18.
//  Copyright © 2018 Pyae Phyo Myint Soe. All rights reserved.
//

import UIKit

class P2MSSampleBaseTableViewController: UITableViewController {
    
    private struct TableViewItem {
        var title: String
        var storyboardID: String
        init(title: String, storyboardID: String) {
            self.title = title
            self.storyboardID = storyboardID
        }
    }
    
    private let allTableViewItems = [
        TableViewItem(title: NSLocalizedString("star_rating_view", comment: ""), storyboardID: "P2MSStarRatingViewController")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        title = NSLocalizedString("samples", comment: "")
        self.tableView.tableFooterView = UIView()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allTableViewItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "baseViewCell", for: indexPath)
        let curItem = allTableViewItems[indexPath.row]
        cell.textLabel?.text = curItem.title
        return cell
    }
    
    private func gotoViewController(item: TableViewItem){
        guard !item.storyboardID.isEmpty else {
            return
        }
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: item.storyboardID)
        viewController.title = item.title
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        gotoViewController(item: allTableViewItems[indexPath.row])
    }

}
