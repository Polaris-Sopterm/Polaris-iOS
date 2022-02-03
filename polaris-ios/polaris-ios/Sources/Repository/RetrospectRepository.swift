//
//  RetrospectRepository.swift
//  Polaris
//
//  Created by Dongmin on 2022/01/26.
//

import RxSwift
import Foundation

protocol RetrospectRepository {
    func fetchListValues(ofDate date: PolarisDate?) -> Observable<RetrospectValueListModel>
    func fetchRetrospect(ofDate date: PolarisDate) -> Observable<RetrospectModel?>
}

final class RetrospectRepositoryImpl: RetrospectRepository {
    
    func fetchListValues(ofDate date: PolarisDate? = nil) -> Observable<RetrospectValueListModel> {
        let listValuesAPI = RetrospectAPI.listValues(date: date)
        return NetworkManager.request(apiType: listValuesAPI).asObservable()
    }
    
    func fetchRetrospect(ofDate date: PolarisDate) -> Observable<RetrospectModel?> {
        let getRetrospectAPI = RetrospectAPI.getRetrospect(date: date)
        return NetworkManager.request(apiType: getRetrospectAPI)
            .catchAndReturn(nil)
            .asObservable()
    }
    
}
