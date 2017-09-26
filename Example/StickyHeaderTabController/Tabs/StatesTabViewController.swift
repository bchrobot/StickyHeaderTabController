//
//  StatesTabViewController.swift
//  StickyHeaderTabController_Example
//
//  Created by Benjamin Chrobot on 9/21/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import StickyHeaderTabController

class StatesTabViewController: StickyHeaderContentTabViewController {

    // MARK: - Properties

    fileprivate let cellIdentifier = "StatesCell"

    override open var scrollView: UIScrollView {
        return tableView
    }

    // MARK: Views

    private let tableView = UITableView()

    // MARK: - Initialization

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        commonInit()
    }

    // MARK: - Setup

    private func commonInit() {
        title = "States"

        setUpTableView()
    }

    private func setUpTableView() {
        view.addSubview(tableView)
        tableView.dataSource = self

        // Frame
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Cell registration
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }
}

// MARK: - UITableViewDataSource

extension StatesTabViewController: UITableViewDataSource {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TabData.states.count
    }

    public func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.text = TabData.states[indexPath.row]

        return cell
    }
}
