//
//  MasterViewController.swift
//  CoreMLDemos
//
//  Created by Jon Manning on 4/7/18.
//  Copyright © 2018 Secret Lab. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var detailViewController: SentimentAnalysisViewController? = nil
    var objects = [Any]()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? SentimentAnalysisViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let controller = (segue.destination as! UINavigationController).topViewController else {
            return
        }
        controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        controller.navigationItem.leftItemsSupplementBackButton = true
    }

    // MARK: - Table View

}

