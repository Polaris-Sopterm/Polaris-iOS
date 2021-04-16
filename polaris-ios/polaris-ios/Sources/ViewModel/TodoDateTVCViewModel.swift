//
//  TodoDateTVCViewModel.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2021/04/16.
//

import Foundation
import Foundation
import RxSwift
import RxCocoa

class TodoDateTVCViewModel {
    let id: IndexPath
    let todoModel: TodoModel
    
    init(id: IndexPath,todoModel: TodoModel) {
        self.id = id
        self.todoModel = todoModel
    }
    
    
    
}
