//
//  SignupModel.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/06/03.
//

import Foundation

struct SignupModel: Codable {
    var idx: Int
    var email: String
    var password: String
    var nickname: String
    var createdAt: String
    var updatedAt: String
}
