//
//  PolarisStar.swift
//  polaris-ios
//
//  Created by USER on 2021/04/25.
//

import UIKit

enum PolarisStar: String, CaseIterable {
    case happiness  = "Happiness"
    case control    = "Control"
    case thanks     = "Thanks"
    case rest       = "Rest"
    case growth     = "Growth"
    case change     = "Change"
    case health     = "Health"
    case overcome   = "Overcome"
    case challenge  = "Challenge"
    
    var title: String {
        switch self {
        case .happiness:    return "행복"
        case .control:      return "절제"
        case .thanks:       return "감사"
        case .rest:         return "휴식"
        case .growth:       return "성장"
        case .change:       return "변화"
        case .health:       return "건강"
        case .overcome:     return "극복"
        case .challenge:    return "도전"
        }
    }
    
    func getImage(by level: Int = 4) -> UIImage? {
        let imageName = String(format: "img\(self.rawValue)%02d", level)
        return UIImage(named: imageName)
    }
}
