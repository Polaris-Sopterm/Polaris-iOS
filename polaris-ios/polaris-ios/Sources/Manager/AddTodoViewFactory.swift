//
//  AddTodoViewFactory.swift
//  polaris-ios
//
//  Created by Dongmin on 2022/03/27.
//

import Foundation

struct AddTodoViewMakingParameter {
    let mode: AddTodoVC.AddMode
    var delegate: AddTodoViewControllerDelegate?
}

enum AddTodoViewFactory {
    
    static func makeAddTodoViewController(param: AddTodoViewMakingParameter) -> AddTodoVC? {
        let addTodoView = AddTodoVC.instantiateFromStoryboard(StoryboardName.addTodo)
        addTodoView?.delegate = param.delegate
        addTodoView?.setAddMode(param.mode)
        return addTodoView
    }
    
}
