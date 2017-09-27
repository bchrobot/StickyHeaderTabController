//
//  ColorsTabViewController.swift
//  StickyHeaderTabController_Example
//
//  Created by Benjamin Chrobot on 9/26/17.
//  Copyright (c) 2017 Benjamin Chrobot. All rights reserved.
//

import UIKit
import StickyHeaderTabController

class ColorsTabViewController: StickyHeaderContentTabViewController {

    // MARK: - Properties

    fileprivate let cellIdentifier = "ColorsCell"

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
        title = "Colors"

        setUpTableView()
    }

    private func setUpTableView() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self

        // Frame
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Cell registration
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }
}

// MARK: - UITableViewDataSource

extension ColorsTabViewController: UITableViewDataSource {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TabData.colors.count
    }

    public func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.text = TabData.colors[indexPath.row].name
        cell.backgroundColor = TabData.colors[indexPath.row].color

        return cell
    }
}

// MARK: - UITableViewDelegate

extension ColorsTabViewController: UITableViewDelegate {  }
