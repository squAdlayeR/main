//
//  ResourceManager.swift
//  lAyeR
//
//  Created by Yang Zhuohan on 3/10/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import UIKit

/**
 This is a static class that is used to manage resources in
 assets (such as loading images)
 */
class ResourceManager {
    
    /// Gets the image view of a specific image according to its name.
    /// - Parameter imageName: the name of the image
    /// - Returns: corresponding UIImageView
    static func getImageView(by imageName: String) -> UIImageView {
        let image = UIImage(named: imageName)
        let imageView = UIImageView(image: image)
        return imageView
    }
    
}
