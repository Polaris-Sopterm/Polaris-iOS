//
//  UserAPI.swift
//  Polaris
//
//  Created by Dongmin on 2021/06/03.
//

import Foundation
import Moya

enum UserAPI {
    case createUser(email: String, password: String, nickname: String)
    case checkEmail(email: String)
}

extension UserAPI: TargetType {
    
    var baseURL: URL {
        return URL(string: ServerHost.main)!
    }
    
    var path: String {
        switch self {
        case .createUser: return "/user/v0"
        case .checkEmail: return "/user/v0/checkEmail"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .createUser: return .post
        case .checkEmail: return .post
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .createUser(let email, let password, let nickname):
            print(email, password, nickname)
            return .requestParameters(parameters: ["email": email, "password": password, "nickname": nickname], encoding: JSONEncoding.default)
        case .checkEmail(let email):
            return .requestParameters(parameters: ["email": email], encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return NetworkInform.headers
    }
    
}
