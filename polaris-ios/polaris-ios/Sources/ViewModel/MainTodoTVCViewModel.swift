//
//  MainTodoTVCViewModel.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2021/04/28.
//

import Foundation
struct MainTodoTVCViewModel {
    var id: IndexPath
    var weekTodos: TodoModel
    
    init(id: IndexPath,weekTodo: TodoModel) {
        self.id = id
        self.weekTodos = weekTodo
    }
    
}

