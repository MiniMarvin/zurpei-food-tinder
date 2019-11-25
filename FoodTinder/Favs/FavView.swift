//
//  FavPageView.swift
//  FoodTinder
//
//  Created by Caio Gomes on 25/11/19.
//  Copyright © 2019 Zurpei. All rights reserved.
//

import Foundation
import UIKit

class FavView : UIViewController {
    var tableView: UITableView = UITableView()
    var topStackView: TopNavigationStackView = TopNavigationStackView()
    
    // MARK: Setup the page
    override func viewDidLoad() {
        // add the tableViewCells
        self.tableView.register(UINib(nibName: "FavCell", bundle: Bundle.main), forCellReuseIdentifier: "FavCell")
        
        // Setup Top StackView Buttons
        
        
        self.setupLayout()
        
        
    }
    
    func setupLayout() {
        // Setup tableView Layout
        self.tableView.allowsMultipleSelection = false
        self.tableView.separatorStyle = .none
        self.tableView.layer.cornerRadius = 10
        
        self.view.layer.cornerRadius = 10
        self.view.clipsToBounds = true
        
        // put a stackview as a view to us
//        let pageArrange = UIStackView(arrangedSubviews: [topStackView, tableView])
        let pageArrange = UIStackView(arrangedSubviews: [tableView])
        pageArrange.axis = .vertical
        
        self.view.addSubview(pageArrange)
        pageArrange.anchor(top: self.view.safeAreaLayoutGuide.topAnchor, leading: self.view.leadingAnchor, bottom: self.view.bottomAnchor, trailing: self.view.trailingAnchor)
        
        pageArrange.isLayoutMarginsRelativeArrangement = true
        pageArrange.layoutMargins = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        
        pageArrange.bringSubviewToFront(tableView)
    }
}
