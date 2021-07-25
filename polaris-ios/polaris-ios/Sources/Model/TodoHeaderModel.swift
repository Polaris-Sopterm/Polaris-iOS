//
//  TodoHeaderModel.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/07/22.
//

import Foundation

protocol TodoHeaderModel {
    
}

struct DayTodoHeaderModel: TodoHeaderModel {
    
    let date: Date?
    
}

struct JourneyTodoHeaderModel: TodoHeaderModel {
    
    let journeyId: String?
    let subCategory: [String]?
    
}
