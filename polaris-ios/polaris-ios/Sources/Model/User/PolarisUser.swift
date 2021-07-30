//
//  SignupModel.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/06/03.
//

import Foundation

struct PolarisUser: Codable {
    let idx: Int?
    let email: String?
    let password: String?
    let nickname: String?
    let createdAt: String?
    let updatedAt: String?
}
