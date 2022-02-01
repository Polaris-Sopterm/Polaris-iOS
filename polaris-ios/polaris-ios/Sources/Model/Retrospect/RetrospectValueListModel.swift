//
//  RetrospectValuesModel.swift
//  polaris-ios
//
//  Created by Dongmin on 2022/01/26.
//

import Foundation

struct RetrospectValueListModel: Codable {
    let happiness: Int
    let control: Int
    let thanks: Int
    let rest: Int
    let growth: Int
    let change: Int
    let health: Int
    let overcome: Int
    let challenge: Int
    
    enum CodingKeys: String, CodingKey {
        case happiness  = "행복"
        case control    = "절제"
        case thanks     = "감사"
        case rest       = "휴식"
        case growth     = "성장"
        case change     = "변화"
        case health     = "건강"
        case overcome   = "극복"
        case challenge  = "도전"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let intMetaType = Int.self
        
        self.happiness = (try? values.decode(intMetaType, forKey: .happiness)) ?? 0
        self.control = (try? values.decode(intMetaType, forKey: .control)) ?? 0
        self.thanks = (try? values.decode(intMetaType, forKey: .thanks)) ?? 0
        self.rest = (try? values.decode(intMetaType, forKey: .rest)) ?? 0
        self.growth = (try? values.decode(intMetaType, forKey: .growth)) ?? 0
        self.change = (try? values.decode(intMetaType, forKey: .change)) ?? 0
        self.health = (try? values.decode(intMetaType, forKey: .health)) ?? 0
        self.overcome = (try? values.decode(intMetaType, forKey: .overcome)) ?? 0
        self.challenge = (try? values.decode(intMetaType, forKey: .challenge)) ?? 0
    }
    
    init(
        happiness: Int,
        control: Int,
        thanks: Int,
        rest: Int,
        growth: Int,
        change: Int,
        health: Int,
        overcome: Int,
        challenge: Int
    ) {
        self.happiness = happiness
        self.control = control
        self.thanks = thanks
        self.rest = rest
        self.growth = growth
        self.change = change
        self.health = health
        self.overcome = overcome
        self.challenge = challenge
    }
    
    var isAchieveJourneyAtLeastOne: Bool {
        self.foundStarsList.isEmpty == false
    }
    
    var foundStarsList: [Journey] {
        var list = [Journey]()
        
        if self.happiness != 0 { list.append(.happiness) }
        if self.control != 0 { list.append(.control) }
        if self.thanks != 0 { list.append(.thanks) }
        if self.rest != 0 { list.append(.rest) }
        if self.growth != 0 { list.append(.growth) }
        if self.change != 0 { list.append(.change) }
        if self.health != 0 { list.append(.health) }
        if self.overcome != 0 { list.append(.overcome) }
        if self.challenge != 0 { list.append(.challenge) }
        return list
    }
    
    var foundStarCount: Int {
        self.foundStarsList.count
    }
    
}
