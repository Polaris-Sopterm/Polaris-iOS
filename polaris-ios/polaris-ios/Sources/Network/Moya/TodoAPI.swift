//
//  TodoAPI.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/06/27.
//

import Foundation
import Moya

enum TodoAPI {
    case createToDo(title: String, date: String, journeyTitle: String? = nil, journeyIdx: Int, isTop: Bool)
    case createJourney(title: String, date: String, journeyIdx: Int, isTop: Bool)
}

extension TodoAPI: TargetType {
    
    var baseURL: URL {
        return URL(string: ServerHost.main)!
    }
    
    var path: String {
        switch self {
        case .createToDo: fallthrough
        case .createJourney: return "/toDo/v0"
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
        case .createToDo(let title, let date, let journeyTitle, let journeyIdx, let isTop):
            var params: [String: Any] = ["title": title, "date": date, "journeyIdx": journeyIdx, "isTop": isTop]
            if let journeyTitle = journeyTitle { params["journeyTitle"] = journeyTitle }
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .createJourney(let title, let date, let journeyIdx, let isTop):
            return .requestParameters(parameters: ["title": title, "date": date, "journeyIdx": journeyIdx, "isTop": isTop], encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return NetworkInform.headers
    }
    
}
