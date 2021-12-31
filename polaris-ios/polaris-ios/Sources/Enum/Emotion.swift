//
//  Emotion.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/12/22.
//

import UIKit

enum Emotion: String {
    case comfortable    // 편안
    case inconvenient   // 불편
    case expectation    // 기대
    case frustrated     // 답답
    case easy           // 무난
    case joy            // 기쁨
    case angry          // 화남
    case regretful      // 아쉬움
    case satisfaction   // 만족
    
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
    
    var name: String {
        switch self {
        case .comfortable:  return "편안"
        case .inconvenient: return "불편"
        case .expectation:  return "기대"
        case .frustrated:   return "답답"
        case .easy:         return "무난"
        case .joy:          return "기쁨"
        case .angry:        return "화남"
        case .regretful:    return "아쉬운"
        case .satisfaction: return "만족"
        }
    }
}
