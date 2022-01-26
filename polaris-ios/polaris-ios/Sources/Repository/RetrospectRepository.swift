//
//  RetrospectRepository.swift
//  Polaris
//
//  Created by Dongmin on 2022/01/26.
//

import RxSwift
import Foundation

protocol RetrospectRepository {
    func fetchListValues(asDate date: PolarisDate) -> Observable<RetrospectValuesModel>
}

final class RetrospectRepositoryImpl: RetrospectRepository {
    
    func fetchListValues(asDate date: PolarisDate) -> Observable<RetrospectValuesModel> {
        let listValuesAPI = RetrospectAPI.listValues(date: date)
        return NetworkManager.request(apiType: listValuesAPI).asObservable()
    }
    
}
