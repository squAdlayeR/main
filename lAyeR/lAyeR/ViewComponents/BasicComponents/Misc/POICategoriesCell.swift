//
//  POICategoriesCell.swift
//  lAyeR
//
//  Created by Yang Zhuohan on 2/4/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import UIKit

/**
 A wrapper class that is to define the table cell in application settings
 This cell will be containing an icon and a category name.
 */
class POICategoriesCell: UITableViewCell {

    // Connects the category icon
    @IBOutlet weak var categoryIcon: UIImageView!
    
    // Connects the category name
    @IBOutlet weak var categoryName: UILabel!
    
    // Sets the represneting category of this cell. by default is other
    private(set) var category: POICategory = .other
    
    /// Prepares the display of cell with specified icon name and category name
    /// - Parameter category: an enum that defines the category that the cell
    ///     is representing
    func prepareDisplay(with category: POICategory) {
        self.category = category
        categoryName.text = category.text
        prepareIcon(with: category.rawValue)
    }
    
    /// Prepares the category icon with specified icon name
    /// - Parameter categoryIconName: the image name of the icon
    private func prepareIcon(with categoryIconName: String) {
        let icon = UIImage(named: "\(category.rawValue)\(MiscConstants.coloredIconExtension)")
        categoryIcon.image = icon
    }

}
