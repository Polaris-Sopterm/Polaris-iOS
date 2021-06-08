//
//  AuthModel.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/06/08.
//

import Foundation

struct AuthModel: Codable {
    var accessToken: String
    var refreshToken: String
}
