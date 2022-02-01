//
//  RetrospectReportViewModelFormatter.swift
//  polaris-ios
//
//  Created by Dongmin on 2022/01/28.
//

import Foundation

enum RetrospectReportPresentableFormatter {
    
    static func formatToFoundStarViewModel(fromModel model: RetrospectValueListModel, date: PolarisDate) -> RetrospectReportPresentable {
        return RetrospectFoundStarModel(foundStar: model, date: date)
    }
    
    static func formatToFarStarViewModel(fromModel model: RetrospectModel) -> RetrospectReportPresentable {
        let starsList = model.value.n.compactMap { Journey(rawValue: $0) }
        return RetrospectFarStarsModel(farStars: starsList)
    }
    
    static func formatToCloseStarViewModel(fromModel model: RetrospectModel) -> RetrospectReportPresentable {
        let starsList = model.value.y.compactMap { Journey(rawValue: $0) }
        return RetrospectCloseStarsModel(closeStars: starsList)
    }
    
    static func formatToEmoticonViewModel(fromModel model: RetrospectModel) -> RetrospectReportPresentable {
        let emoticons = model.value.emoticon.compactMap { Emoticon(rawValue: $0) }
        return RetrospectEmoticonModel(emoticons: emoticons)
    }
    
    static func formatToEmoticonReasonViewModel(fromModel model: RetrospectModel) -> RetrospectReportPresentable {
        let reasons = [model.record1, model.record2, model.record3].compactMap { $0 }
        return RetrospectEmoticonReasonModel(reasons: reasons)
    }
    
}
