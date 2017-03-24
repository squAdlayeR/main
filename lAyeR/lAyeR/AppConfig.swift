//
//  AppConfig.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/3/12.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

/*
 * Stores all constants for the project.
 * May change to json file. To be determined.
 */
class AppConfig {
    
    /// Base URL for firebase database.
    static let databaseBaseURL: String = "https://layer-160608.firebaseio.com/"
    
    /// Base URL for google nearby places query.
    /// May change to radar query. To be determined.
    static let mapQueryBaseURL: String = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
    
    /// API key for google services.
    static let apiKey = "AIzaSyAxEeB1jYBx9HgghM4IXxxzGIA4p6yjr9s"
    
    
}
