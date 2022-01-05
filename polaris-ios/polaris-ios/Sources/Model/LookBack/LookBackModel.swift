//
//  LookBackModel.swift
//  Polaris
//
//  Created by Yunjae Kim on 2022/01/04.
//

import Foundation

struct LookBackModel: Codable {
    let year    : String
    let month   : String
    let weekNo  : String
    let value   : LookBackValueModel
    let record1 : String?
    let record2 : String?
    let record3 : String?
}

struct LookBackValueModel: Codable {
    let y           : [LookBackStarEnum]
    let n           : [LookBackStarEnum]
    let health      : Int
    let happy       : Int
    let challenge   : Int
    let moderation  : Int
    let emoticon    : [LookBackEmotionEnum]
    let need        : [LookBackStarEnum]
}


enum LookBackStarEnum: String, Codable {
    case HAPPINESS  = "행복"
    case CONTROL    = "절제"
    case GRATITUDE  = "감사"
    case REST       = "휴식"
    case GROWTH     = "성장"
    case CHANGE     = "변화"
    case HEALTH     = "건강"
    case OVERCOME   = "극복"
    case CHALLENGE  = "도전"
}

enum LookBackEmotionEnum: String, Codable {
    case COMFORTABLE    = "편안"
    case INCONVENIENCE  = "불편"
    case EXPECTATION    = "기대"
    case FRUSTRATED     = "답답"
    case EASY           = "무난"
    case JOY            = "기쁨"
    case ANGRY          = "화남"
    case REGRETFUL      = "아쉬운"
    case SATISFACTION   = "만족"
}
