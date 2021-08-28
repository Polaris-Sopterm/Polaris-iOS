//
//  TodoModel.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2021/04/15.
//

import Foundation

struct TodoDisplayModel {
    var todoTitle: String
    var todoSubtitle: String
    var fixed: Bool
    var checked: Bool
    
    init(todoTitle: String, todoSubtitle: String, fixed: Bool,checked: Bool) {
        self.todoTitle = todoTitle
        self.todoSubtitle = todoSubtitle
        self.fixed = fixed
        self.checked = checked
    }
    
    
}

