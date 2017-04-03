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
    
    /// Prepares the display of cell with specified icon name and category name
    func prepareDisplay(with iconName: String, categoryNameText: String) {
        categoryName.text = categoryNameText
        prepareIcon(with: iconName)
    }
    
    /// Prepares the category icon with specified icon name
    /// - Parameter imageName: the image name of the icon
    private func prepareIcon(with imageName: String) {
        let icon = UIImage(named: imageName)
        let tintIcon = icon?.withRenderingMode(.alwaysTemplate)
        categoryIcon.image = tintIcon
        categoryIcon.tintColor = .black
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
