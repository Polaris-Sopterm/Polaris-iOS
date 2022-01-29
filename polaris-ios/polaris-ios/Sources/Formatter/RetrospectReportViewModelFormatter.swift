//
//  RetrospectReportViewModelFormatter.swift
//  polaris-ios
//
//  Created by Dongmin on 2022/01/28.
//

import Foundation

enum RetrospectReportPresentableFormatter {
    
    static func formatToFarStarViewModel(fromModel model: RetrospectModel) -> RetrospectReportPresentable {
        let starsList = model.value.n.compactMap { Journey(rawValue: $0) }
        return RetrospectFarStarsModel(farStars: starsList)
    }
    
    static func formatToCloseStarViewModel(fromModel model: RetrospectModel) -> RetrospectReportPresentable {
        let starsList = model.value.y.compactMap { Journey(rawValue: $0) }
        return RetrospectCloseStarsModel(closeStars: starsList)
    }
    
}
