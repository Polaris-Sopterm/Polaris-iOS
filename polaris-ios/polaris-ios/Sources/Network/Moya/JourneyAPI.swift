//
//  JourneyAPI.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/08/08.
//

import Foundation
import Moya

enum JourneyAPI {
    case jouneyTitleList(date: String)
}

extension JourneyAPI: TargetType {
    
    var baseURL: URL {
        return URL(string: ServerHost.main)!
    }
    
    var path: String {
        switch self {
        case .jouneyTitleList: return "/journey/v0/title"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .jouneyTitleList: return .get
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .jouneyTitleList(let date):
            return .requestParameters(parameters: ["date": date], encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return NetworkInform.headers
    }
    
}
