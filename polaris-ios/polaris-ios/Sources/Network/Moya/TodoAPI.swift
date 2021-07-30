//
//  TodoAPI.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/06/27.
//

import Foundation
import Moya

enum TodoAPI {
    case createToDo(title: String, date: String, journeyTitle: String = "default", journeyIdx: Int? = nil, isTop: Bool)
    case createJourney(title: String, date: String, journeyIdx: Int, isTop: Bool)
    case listTodoByDate(year: String? = nil, month: String? = nil, weekNo: String? = nil)
}

extension TodoAPI: TargetType {
    
    var baseURL: URL {
        return URL(string: ServerHost.main)!
    }
    
    var path: String {
        switch self {
        case .createToDo:       fallthrough
        case .createJourney:    return "/toDo/v0"
        case .listTodoByDate:   return "/toDo/v0/date"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .listTodoByDate: return .get
        default:              return .post
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .createToDo(let title, let date, let journeyTitle, let journeyIdx, let isTop):
            var params: [String: Any] = ["title": title, "date": date, "journeyTitle": journeyTitle, "isTop": isTop]
            if let journeyIdx = journeyIdx { params["journeyIdx"] = journeyIdx }
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .createJourney(let title, let date, let journeyIdx, let isTop):
            return .requestParameters(parameters: ["title": title, "date": date, "journeyIdx": journeyIdx, "isTop": isTop], encoding: JSONEncoding.default)
        case .listTodoByDate(let year, let month, let weekNo):
            var params: [String: Any] = [:]
            if let year = year      { params["year"] = year }
            if let month = month    { params["month"] = month }
            if let weekNo = weekNo  { params["weekNo"] = weekNo }
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        return NetworkInform.headers
    }
    
}
