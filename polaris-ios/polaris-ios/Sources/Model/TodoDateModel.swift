//
//  TodoDateModel.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2021/04/16.
//

import Foundation

struct TodoDateModel {
    var date: String
    var todos: [TodoDisplayModel]
    
    init(date: String, todos: [TodoDisplayModel]) {
        self.date = date
        self.todos = todos
    }
    
}
