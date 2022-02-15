//
//  WeekRepository.swift
//  polaris-ios
//
//  Created by Dongmin on 2022/02/02.
//

import RxSwift
import Foundation

protocol WeekRepository {
    func fetchWeekNo(ofDate date: Date) -> Observable<WeekResponseModel>
    func fetchLastWeekOfMonth() -> Observable<[LastWeekOfMonthDataModel]>
}

final class WeekRepositoryImpl: WeekRepository {
    
    func fetchWeekNo(ofDate date: Date) -> Observable<WeekResponseModel> {
        let weekAPI = WeekAPI.getWeekNo(date: date)
        return NetworkManager.request(apiType: weekAPI)
            .asObservable()
    }
    
    func fetchLastWeekOfMonth() -> Observable<[LastWeekOfMonthDataModel]> {
        let weekAPI = WeekAPI.lastWeekOfMonth
        return NetworkManager.request(apiType: weekAPI)
            .map { (lastWeekModel: LastWeekOfMonthResponseModel) in
                return lastWeekModel.data
            }
            .asObservable()
    }
    
}
