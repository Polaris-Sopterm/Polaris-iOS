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
    case auth(email: String, password: String)
    case reauth(refreshToken: String)
    case logout
    case signout
    case updateUser(nickname: String)
}

extension UserAPI: TargetType {
    
    var baseURL: URL {
        return URL(string: ServerHost.main)!
    }
    
    var path: String {
        switch self {
        case .createUser: return "/user/v0"
        case .checkEmail: return "/user/v0/checkEmail"
        case .auth:       fallthrough
        case .reauth:     fallthrough
        case .logout:     return "/auth/v0"
        case .signout:    return "/user/v0"
        case .updateUser: return "/user/v0/me"
        }
    }
    
    var method: Moya.Method {
        if case .reauth = self  { return .put }
        if case .signout = self { return .delete }
        if case .logout = self { return .delete }
        if case .updateUser = self { return .patch }
        return .post
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .createUser(let email, let password, let nickname):
            return .requestParameters(parameters: ["email": email, "password": password, "nickname": nickname], encoding: JSONEncoding.default)
        case .checkEmail(let email):
            return .requestParameters(parameters: ["email": email], encoding: JSONEncoding.default)
        case .auth(let email,let password):
            return .requestParameters(parameters: ["email": email, "password": password], encoding: JSONEncoding.default)
        case .reauth(let refreshToken):
            return .requestParameters(parameters: ["refreshToken": refreshToken], encoding: JSONEncoding.default)
        case .logout:
            return .requestPlain
        case .signout:
            return .requestPlain
        case .updateUser(let nickname):
            return .requestParameters(parameters: ["nickname": nickname], encoding: JSONEncoding.default)
        }
       
    }
    
    var headers: [String : String]? {
        return NetworkInform.headers
    }
    
}
