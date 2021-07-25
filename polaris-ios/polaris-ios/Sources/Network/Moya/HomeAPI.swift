//
//  HomeAPI.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2021/07/18.
//

import Foundation
import Moya

enum HomeAPI {
    case getHomeBanner(isSkipped: Bool)
    
    func getPath() -> String {
        switch(self){
        case let .getHomeBanner(isSkipped):
            return "/home/v0/banner/:"+String(isSkipped)
            
        }
    }
    
}

extension HomeAPI: TargetType {
    
    var baseURL: URL {
        return URL(string: ServerHost.main)!
    }
    
    var path: String {
        switch self {
        case .getHomeBanner: return HomeAPI.getPath(self)()
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
        case .getHomeBanner(let isSkipped):
            return .requestParameters(parameters: [:], encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return NetworkInform.headers
    }
    
}

