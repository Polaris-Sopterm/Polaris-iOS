//
//  Journey.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/08/19.
//

import UIKit

enum Journey: String, CaseIterable {
    case happiness = "행복"
    case control   = "절제"
    case thanks    = "감사"
    case rest      = "휴식"
    case growth    = "성장"
    case change    = "변화"
    case health    = "건강"
    case overcome  = "극복"
    case challenge = "도전"
}

extension Journey {
    
    var imageName: String {
        switch self {
        case .happiness: return "Happiness"
        case .control:   return "Control"
        case .thanks:    return "Thanks"
        case .rest:      return "Rest"
        case .growth:    return "Growth"
        case .change:    return "Change"
        case .health:    return "Health"
        case .overcome:  return "Overcome"
        case .challenge: return "Challenge"
        }
    }
    
    var color: UIColor {
        switch self {
        case .happiness: return .peachyPink
        case .control:   return .peachyPink2
        case .thanks:    return .maize
        case .rest:      return .lightGreen
        case .growth:    return .seafoamBlue2
        case .change:    return .cornflower
        case .health:    return .seafoamBlue
        case .overcome:  return .liliac
        case .challenge: return .bubblegumPink
        }
    }
    
    func getImage(by level: Int = 4) -> UIImage? {
        let imageName = String(format: "img\(self.imageName)%02d", level)
        return UIImage(named: imageName)
    }
    
}
