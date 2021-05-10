//
//  MainTodoTVCViewModel.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2021/04/28.
//

import Foundation
struct MainTodoTVCViewModel {
    var id: IndexPath
    var todoModel: TodoModel
    
    init(id: IndexPath,todoModel: TodoModel) {
        self.id = id
        self.todoModel = todoModel
    }
    
}

