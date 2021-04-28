//
//  TodoStarModel.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2021/04/28.
//

import Foundation

struct TodoStarModel {
    var star: String
    var todos: [TodoModel]
    
    init(star: String, todos: [TodoModel]) {
        self.star = star
        self.todos = todos
    }
    
    
}
