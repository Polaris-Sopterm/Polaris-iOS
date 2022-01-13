//
//  LookBackAPI.swift
//  Polaris
//
//  Created by Yunjae Kim on 2022/01/05.
//

import Foundation
import Moya

enum LookBackAPI {
    case createLookBack(model: LookBackModel)
}

extension LookBackAPI: TargetType {
    
    var baseURL: URL {
        return URL(string: ServerHost.main)!
    }
    
    var path: String {
        switch self {
        case .createLookBack: return "/retrospect/v0"
        }
    }
    
    var method: Moya.Method {
        return .post
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
        }
       
    }
    
    var headers: [String : String]? {
        return NetworkInform.headers
    }
    
}

