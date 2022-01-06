//
//  RetrospectViewModel.swift
//  polaris-ios
//
//  Created by Dongmin on 2022/01/05.
//

import Foundation

enum RetrospectReportCategory: Int, CaseIterable {
    case foundStar
    case closeStar
    case farStar
    case emotion
    case emotionReason
    
    var cellType: RetrospectReportCell.Type {
        switch self {
        case .foundStar:     return RetrospectFoundStarTableViewCell.self
        case .closeStar:     return RetrospectCloseStarTableViewCell.self
        case .farStar:       return RetrospectFarStarTableViewCell.self
        case .emotion:       return RetrospectFarStarTableViewCell.self
        case .emotionReason: return RetrospectFarStarTableViewCell.self
        }
    }
    
}

class RetrospectReportViewModel {
    
    
    
}
