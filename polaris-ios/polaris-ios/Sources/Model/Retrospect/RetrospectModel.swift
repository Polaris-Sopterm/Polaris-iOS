//
//  LookBackModel.swift
//  Polaris
//
//  Created by Yunjae Kim on 2022/01/04.
//

import Foundation

struct RetrospectModel: Codable {
    var userIdx     : Int?
    var idx         : Int?
    var createdAt   : String?
    var updatedAt   : String?
    let year        : Int
    let month       : Int
    let weekNo      : Int
    let value       : RetrospectValueModel
    var record1     : String?
    var record2     : String?
    var record3     : String?
}

struct RetrospectValueModel: Codable {
    let y           : [String]
    let n           : [String]
    let health      : Int
    let happy       : Int
    let challenge   : Int
    let moderation  : Int
    let emoticon    : [String]
    let need        : [String]
}
