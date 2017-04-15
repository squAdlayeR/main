//
//  RealmModels.swift
//  lAyeR
//
//  Created by luoyuyang on 04/04/17.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation
import RealmSwift

/**
 RealmString is the wrapper class of Swift String class
 This is becuase Realm List can only contains the subclasses of Object
 */
class RealmString: Object {
    dynamic var content: String = ""
    convenience init(_ input: String) {
        self.init()
        content = input
    }
    func get() -> String {
        return content
    }
}












