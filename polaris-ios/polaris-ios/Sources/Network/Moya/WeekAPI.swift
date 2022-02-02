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
}

extension WeekAPI: TargetType {
    
    var baseURL: URL {
        return URL(string: ServerHost.main)!
    }
    
    var path: String {
        switch self {
        case .getWeekNo(let date):
            return "/weekNo/v0/" + date.convertToString()
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getWeekNo: return .get
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .getWeekNo:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return NetworkInform.headers
    }
    
}
