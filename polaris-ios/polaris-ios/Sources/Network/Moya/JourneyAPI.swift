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
    case createJourney(title: String, value1: String, value2: String? = nil, date: String)
}

extension JourneyAPI: TargetType {
    
    var baseURL: URL {
        return URL(string: ServerHost.main)!
    }
    
    var path: String {
        switch self {
        case .jouneyTitleList: return "/journey/v0/title"
        case .createJourney:   return "/journey/v0"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .jouneyTitleList: return .get
        case .createJourney:   return .post
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .jouneyTitleList(let date):
            return .requestParameters(parameters: ["date": date], encoding: URLEncoding.default)
        case .createJourney(let title, let value1, let value2, let date):
            var parameters: [String: Any] = ["title": title, "value1": value1, "date": date]
            if let value2 = value2 { parameters["value2"] = value2 }
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return NetworkInform.headers
    }
    
}
