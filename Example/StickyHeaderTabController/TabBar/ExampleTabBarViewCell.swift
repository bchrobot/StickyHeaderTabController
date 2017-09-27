//
//  ExampleTabBarViewCell.swift
//  StickyHeaderTabController_Example
//
//  Created by Benjamin Chrobot on 9/27/17.
//  Copyright © 2017 Benjamin Chrobot. All rights reserved.
//

import Foundation
import StickyHeaderTabController

class ExampleTabBarViewCell: StickyHeaderTabBarViewCell {

    override init(frame: CGRect) {
        super.init(frame: frame)

        textColor = UIColor(white: 0.63, alpha: 1)
        selectedTextColor = UIColor(white: 0.24, alpha: 1)
        bottomBorderColor = UIColor(red: 0.0, green: 0.4, blue: 0.4, alpha: 1.0)
        bottomBorderWidth = 4.0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
