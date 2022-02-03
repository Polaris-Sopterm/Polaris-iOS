//
//  LookBackAPI.swift
//  Polaris
//
//  Created by Yunjae Kim on 2022/01/05.
//

import Foundation
import Moya

enum RetrospectAPI {
    case createLookBack(model: RetrospectModel)
    case listValues(date: PolarisDate? = nil)
    case getRetrospect(date: PolarisDate)
}

extension RetrospectAPI: TargetType {
    
    var baseURL: URL {
        return URL(string: ServerHost.main)!
    }
    
    var path: String {
        switch self {
        case .createLookBack:   return "/retrospect/v0"
        case .listValues:       return "/retrospect/v0/value"
        case .getRetrospect:    return "/retrospect/v0/"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .createLookBack:   return .post
        case .listValues:       fallthrough
        case .getRetrospect:    return .get
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .createLookBack(let model):
            return .requestParameters(parameters: ["year": model.year,
                                                   "month": model.month,
                                                   "weekNo": model.weekNo,
                                                   "value": [
                                                        "y": model.value.y,
                                                        "n": model.value.n,
                                                        "health": model.value.health,
                                                        "happy": model.value.happy,
                                                        "challenge": model.value.challenge,
                                                        "moderation": model.value.moderation,
                                                        "emoticon": model.value.emoticon,
                                                        "need": model.value.need
                                                   ],
                                                   "record1": model.record1,
                                                   "record2": model.record2,
                                                   "record3": model.record3
                                                  ],
                                      encoding: JSONEncoding.default)
        case .listValues(let date):
            if let date = date {
                let param: [String: String] = [
                    "year": "\(date.year)",
                    "month": "\(date.month)",
                    "weekNo": "\(date.weekNo)"
                ]
                return .requestParameters(parameters: param, encoding: URLEncoding.queryString)
            } else {
                return .requestPlain
            }
        case .getRetrospect(let date):
            let param: [String: String] = [
                "year": "\(date.year)",
                "month": "\(date.month)",
                "weekNo": "\(date.weekNo)"
            ]
            return .requestParameters(parameters: param, encoding: URLEncoding.queryString)
        }
       
    }
    
    var headers: [String : String]? {
        return NetworkInform.headers
    }
    
}

