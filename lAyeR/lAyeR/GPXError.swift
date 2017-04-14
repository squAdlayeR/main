//
//  GPXError.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/4/7.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation

enum GPXError: Error {
    case createFailure
    case readFailure
    case saveFailure
    case noPathFound
}
