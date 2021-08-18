//
//  MainTodoTVCViewModel.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2021/04/28.
//

import Foundation
struct MainTodoTVCViewModel {
    var id: IndexPath
    var weekTodos: WeekTodo
    
    init(id: IndexPath,weekTodo: WeekTodo) {
        self.id = id
        self.weekTodos = weekTodo
    }
    
}

