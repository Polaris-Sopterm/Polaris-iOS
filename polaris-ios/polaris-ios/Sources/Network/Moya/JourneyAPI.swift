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
    func getPath() -> String {
        switch(self){
        case let .getWeekJourney(year,month,weekNo):
            return "/journey/v0?year="+String(year)+"&month="+String(month)+"&weekNo="+String(weekNo)
        }
    }
}

extension JourneyAPI: TargetType {
    
    var baseURL: URL {
        return URL(string: ServerHost.main)!
    }
    
    var path: String {
        switch self {
        case .getWeekJourney: return JourneyAPI.getPath(self)()
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .getWeekJourney:
            print(self.getPath())
            return .requestParameters(parameters: [:], encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        return NetworkInform.headers
    }
    
}


