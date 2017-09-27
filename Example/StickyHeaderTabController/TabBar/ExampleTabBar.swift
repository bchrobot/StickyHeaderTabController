//
//  ExampleTabBar.swift
//  StickyHeaderTabController_Example
//
//  Created by Benjamin Chrobot on 9/27/17.
//  Copyright © 2017 Benjamin Chrobot. All rights reserved.
//

import UIKit
import StickyHeaderTabController

class ExampleTabBar: StickyHeaderTabBarView {

    // MARK: - Properties

    private let exampleCellReuseIdentifier = "ExampleCellReuseIdentifier"

    // MARK: - Overrides

    override open func registerCellForReuse() {
        register(ExampleTabBarViewCell.self,
                 forCellWithReuseIdentifier: exampleCellReuseIdentifier)
    }

    override open func collectionView(_ collectionView: UICollectionView,
                                      cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index = indexPath.item
        let title = tabDataSource?.stickyHeaderTabBarView(self, titleAtIndex: index)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: exampleCellReuseIdentifier,
                                                      for: indexPath) as! ExampleTabBarViewCell
        cell.title = title

        return cell
    }
}
