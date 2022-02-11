//
//  WeekAPI.swift
//  polaris-ios
//
//  Created by Dongmin on 2022/02/02.
//

import Foundation
import Moya

enum WeekAPI {
    case getWeekNo(date: Date)
    case lastWeekOfMonth
}

extension WeekAPI: TargetType {
    
    var baseURL: URL {
        return URL(string: ServerHost.main)!
    }
    
    var path: String {
        switch self {
        case .getWeekNo(let date):
            return "/weekNo/v0/" + date.convertToString()
        case .lastWeekOfMonth:
            return "/weekNo/v0/lastWeekOfMonth"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getWeekNo:        return .get
        case .lastWeekOfMonth:  return .get
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .getWeekNo:
            return .requestPlain
        case .lastWeekOfMonth:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return NetworkInform.headers
    }
    
}
