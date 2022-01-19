//
//  LookBackModel.swift
//  Polaris
//
//  Created by Yunjae Kim on 2022/01/04.
//

import Foundation

struct LookBackModel {
    let year    : String
    let month   : String
    let weekNo  : String
    let value   : LookBackValueModel
    let record1 : String?
    let record2 : String?
    let record3 : String?
}

struct LookBackValueModel {
    let y           : [String]
    let n           : [String]
    let health      : Int
    let happy       : Int
    let challenge   : Int
    let moderation  : Int
    let emoticon    : [String]
    let need        : [String]
}
