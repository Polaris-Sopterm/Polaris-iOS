//
//  WeekRepository.swift
//  polaris-ios
//
//  Created by Dongmin on 2022/02/02.
//

import RxSwift
import Foundation

protocol WeekRepository {
    func fetchLastWeekOfMonth() -> Observable<[LastWeekOfMonthDataModel]>
}

final class WeekRepositoryImpl: WeekRepository {
    
    func fetchLastWeekOfMonth() -> Observable<[LastWeekOfMonthDataModel]> {
        let weekAPI = WeekAPI.lastWeekOfMonth
        return NetworkManager.request(apiType: weekAPI)
            .map { (lastWeekModel: LastWeekOfMonthResponseModel) in
                return lastWeekModel.data
            }
            .asObservable()
    }
    
}
