//
//  AddTodoResponseModel.swift
//  Polaris
//
//  Created by Dongmin on 2021/07/26.
//

import Foundation

struct AddTodoRequestBody {
    let title: String
    let date: String
    let isTop: Bool
    var journeyIdx: Int?
}

struct AddTodoResponseModel: Codable {
    let idx: Int?
    let createdAt: String?
    let updatedAt: String?
}
