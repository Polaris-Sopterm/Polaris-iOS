//
//  LookBackAPI.swift
//  Polaris
//
//  Created by Yunjae Kim on 2022/01/05.
//

import Foundation
import Moya

enum RetrospectAPI {
    case create(model: RetrospectModel)
    case listValues(date: PolarisDate? = nil)
    case getRetrospect(date: PolarisDate)
    case skipRetrospect(date: PolarisDate)
}

extension RetrospectAPI: TargetType {
    
    var baseURL: URL {
        return URL(string: ServerHost.main)!
    }
    
    var path: String {
        switch self {
        case .create:   return "/retrospect/v0"
        case .listValues:       return "/retrospect/v0/value"
        case .getRetrospect:    return "/retrospect/v0/"
        case .skipRetrospect:   return "/retrospect/v0/skip"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .create:   return .post
        case .listValues:       fallthrough
        case .getRetrospect:    return .get
        case .skipRetrospect:   return .patch
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .create(let model):
            var params = [String: Any]()
            params["year"] = model.year
            params["month"] = model.month
            params["weekNo"] = model.weekNo
            params["value"] = [
                "y": model.value.y,
                "n": model.value.n,
                "health": model.value.health,
                "happy": model.value.happy,
                "challenge": model.value.challenge,
                "moderation": model.value.moderation,
                "emoticon": model.value.emoticon,
                "need": model.value.need
            ]
            
            if let record1 = model.record1 { params["record1"] = record1 }
            if let record2 = model.record2 { params["record2"] = record2 }
            if let record3 = model.record3 { params["record3"] = record3 }
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
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
        case .skipRetrospect(let date):
            let param: [String: Int] = [
                "year": date.year,
                "month": date.month,
                "weekNo": date.weekNo
            ]
            return .requestParameters(parameters: param, encoding: JSONEncoding.default)
        }
       
    }
    
    var headers: [String : String]? {
        return NetworkInform.headers
    }
    
}

