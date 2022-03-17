//
//  HomeAPI.swift
//  Polaris
//
//  Created by Yunjae Kim on 2021/07/30.
//

import Foundation
import Moya

enum HomeAPI {
    case getHomeBanner(weekModel: PolarisDate)
}

extension HomeAPI: TargetType {
    
    var baseURL: URL {
        return URL(string: ServerHost.main)!
    }
    
    var path: String {
        switch self {
        case .getHomeBanner: return "/home/v0/banner/"
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
        case .getHomeBanner(let weekModel):
            let params: [String: Any] = ["year": weekModel.year, "month": weekModel.month, "weekNo": weekModel.weekNo]
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        return NetworkInform.headers
    }
    
}


