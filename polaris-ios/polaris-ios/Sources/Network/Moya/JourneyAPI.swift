//
//  JourneyAPI.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2021/07/31.
//

import Foundation
import Moya

enum JourneyAPI {
    case getWeekJourney(year: Int, month: Int, weekNo: Int)
}

extension JourneyAPI: TargetType {
    
    var baseURL: URL {
        return URL(string: ServerHost.main)!
    }
    
    var path: String {
        return "/journey/v0"
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .getWeekJourney(let year, let month, let weekNo):
            return .requestParameters(parameters: ["year":year,"month":month,"weekNo":weekNo], encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        return NetworkInform.headers
    }
    
}


