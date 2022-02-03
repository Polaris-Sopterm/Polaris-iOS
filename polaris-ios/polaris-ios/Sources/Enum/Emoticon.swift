//
//  Emotion.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/12/22.
//

import UIKit

enum Emoticon: String {
    case comfortable  = "편안"
    case inconvenient = "불편"
    case expectation  = "기대"
    case frustrated   = "답답"
    case easy         = "무난"
    case joy          = "기쁨"
    case angry        = "화남"
    case regretful    = "아쉬운"
    case satisfaction = "만족"
    
    var image: UIImage? {
        switch self {
        case .comfortable:  return UIImage(named: "imgFaceComfortable")
        case .inconvenient: return UIImage(named: "imgFaceInconvenience")
        case .expectation:  return UIImage(named: "imgFaceExpectation")
        case .frustrated:   return UIImage(named: "imgFaceFrustrated")
        case .easy:         return UIImage(named: "imgFaceEasy")
        case .joy:          return UIImage(named: "imgFaceJog")
        case .angry:        return UIImage(named: "imgFaceAngry")
        case .regretful:    return UIImage(named: "imgFaceRegretful")
        case .satisfaction: return UIImage(named: "imgFaceSatisfaction")
        }
    }
    
}
