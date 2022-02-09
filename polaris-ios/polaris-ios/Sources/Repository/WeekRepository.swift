//
//  WeekRepository.swift
//  polaris-ios
//
//  Created by Dongmin on 2022/02/02.
//

import RxSwift
import Foundation

protocol WeekRepository {
    func fetchWeekNo(ofDate date: Date) -> Observable<Int>
    func fetchLastWeekOfMonth(year: Int, month: Int) -> Observable<Int>
}

final class WeekRepositoryImpl: WeekRepository {
    
    func fetchWeekNo(ofDate date: Date) -> Observable<Int> {
        let weekAPI = WeekAPI.getWeekNo(date: date)
        return NetworkManager.request(apiType: weekAPI)
            .map { (weekModel: WeekResponseModel) in
                return weekModel.weekNo
            }
            .asObservable()
    }
    
    func fetchLastWeekOfMonth(year: Int, month: Int) -> Observable<Int> {
        let weekAPI = WeekAPI.lastWeekOfMonth(year: year, month: month)
        return NetworkManager.request(apiType: weekAPI)
            .map { (lastWeekModel: LastWeekOfMonthResponseModel) in
                return lastWeekModel.weekNo
            }
            .asObservable()
    }
    
}
