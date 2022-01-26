//
//  RetrospectViewModel.swift
//  polaris-ios
//
//  Created by Dongmin on 2022/01/05.
//

import RxRelay
import RxSwift
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
        case .emotion:       return RetrospectEmotionTableViewCell.self
        case .emotionReason: return RetrospectEmotionReasonTableViewCell.self
        }
    }
}

class RetrospectReportViewModel {
    
    var reportDate: PolarisDate { return self.reportDateRelay.value }
    
    let reportDateRelay = BehaviorRelay<PolarisDate>(value: PolarisDate(year: Date.currentYear,
                                                                         month: Date.currentMonth,
                                                                         weekNo: Date.currentWeekNoOfMonth))
    
    init(repository: RetrospectRepository = RetrospectRepositoryImpl()) {
        self.repository = repository
    }
    
    func updateReportDate(date: PolarisDate) {
        self.reportDateRelay.accept(date)
    }
    
    private let repository: RetrospectRepository
    private let disposeBag = DisposeBag()
    
}
