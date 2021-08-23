//
//  TodoAPI.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/06/27.
//

import Foundation
import Moya

enum TodoAPI {
    case createToDo(title: String, date: String, journeyTitle: String? = nil, journeyIdx: Int? = nil, isTop: Bool)
    case editTodo(idx: Int, title: String? = nil, date: String? = nil, journeyIdx: Int? = nil, isTop: Bool? = nil, isDone: Bool? = nil)
    case deleteTodo(idx: Int)
    case createJourney(title: String, date: String, journeyIdx: Int, isTop: Bool)
    case listTodoByDate(year: Int? = nil, month: Int? = nil, weekNo: Int? = nil)
    case listTodoByJourney(year: Int? = nil, month: Int? = nil, weekNo: Int? = nil)
}

extension TodoAPI: TargetType {
    
    var baseURL: URL {
        return URL(string: ServerHost.main)!
    }
    
    var path: String {
        switch self {
        case .deleteTodo(let idx):              return "/toDo/v0/\(idx)"
        case .editTodo(let idx, _, _, _, _, _): return "/toDo/v0/\(idx)"
        case .createToDo:                       fallthrough
        case .createJourney:                    return "/toDo/v0"
        case .listTodoByDate:                   return "/toDo/v0/date"
        case .listTodoByJourney:                return "/toDo/v0/journey"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .editTodo:          return .patch
        case .deleteTodo:        return .delete
        case .listTodoByDate:    fallthrough
        case .listTodoByJourney: return .get
        default:                 return .post
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .createToDo(let title, let date, let journeyTitle, let journeyIdx, let isTop):
            var params: [String: Any] = ["title": title, "date": date, "isTop": isTop]
            if let journeyIdx = journeyIdx     { params["journeyIdx"] = journeyIdx }
            if let journeyTitle = journeyTitle { params["journeyTitle"] = journeyTitle }
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .editTodo(_, let title, let date, let journeyIdx, let isTop, let isDone):
            var parameters = [String: Any]()
            if let title = title           { parameters["title"] = title }
            if let date = date             { parameters["date"] = date }
            if let journeyIdx = journeyIdx { parameters["journeyIdx"] = journeyIdx }
            if let isTop = isTop           { parameters["isTop"] = isTop }
            if let isDone = isDone         { parameters["isDone"] = isDone }
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .createJourney(let title, let date, let journeyIdx, let isTop):
            return .requestParameters(parameters: ["title": title, "date": date, "journeyIdx": journeyIdx, "isTop": isTop], encoding: JSONEncoding.default)
        case .listTodoByDate(let year, let month, let weekNo):
            var params = [String: Any]()
            if let year = year      { params["year"] = year }
            if let month = month    { params["month"] = month }
            if let weekNo = weekNo  { params["weekNo"] = weekNo }
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        case .listTodoByJourney(let year, let month, let weekNo):
            var params = [String: Any]()
            if let year = year      { params["year"] = year }
            if let month = month    { params["month"] = month }
            if let weekNo = weekNo  { params["weekNo"] = weekNo }
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        default:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return NetworkInform.headers
    }
    
}
