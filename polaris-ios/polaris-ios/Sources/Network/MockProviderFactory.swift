//
//  MockProviderFactory.swift
//  polaris-ios
//
//  Created by USER on 2021/04/15.
//

import Foundation
import Moya

class MockProviderFactory {
    static func createMockProvider<T: TargetType>(sampleStatusCode: Int) -> MoyaProvider<T> {
        let endPointClosure = { (target: T) -> Endpoint in
            return Endpoint(url: URL(target: target).absoluteString,
                            sampleResponseClosure: { .networkResponse(sampleStatusCode,
                                                                      target.sampleData) },
                            method: target.method,
                            task: target.task,
                            httpHeaderFields: target.headers)
        }
        
        return MoyaProvider<T>(endpointClosure: endPointClosure,
                               stubClosure: MoyaProvider.immediatelyStub)
    }
}
