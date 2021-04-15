//
//  Network.swift
//  polaris-ios
//
//  Created by USER on 2021/04/12.
//

import Foundation
import Moya
import RxSwift

class NetworkManager {
    static func request<T: Codable, U: TargetType>(provider: MoyaProvider<U> = MoyaProvider(session: DefaultSesssion.shared),
                                                   apiType: U) -> Single<T> {
        return Single<T>.create { single in
            provider.request(apiType) { result in
                switch result {
                case .success(let response):
                    guard self.isProcessableResponse(response) == true else { return }
                    
                    do {
                        guard let resultData = try response.mapString().data(using: .utf8) else {
                            throw NSError(domain: "JSON Parsing Error", code: -1, userInfo: nil)
                        }
                        
                        let responseJson = try JSONDecoder().decode(T.self, from: resultData)
                        single(.success(responseJson))
                    } catch let error {
                        single(.failure(error))
                    }
                case .failure(let error):
                    // TODO: 여기 전역적으로 네트워크 에러 띄우는 팝업창 코드 추가 예정
                    single(.failure(error))
                }
            }
            
            return Disposables.create()
        }
        
    }
    
    private static func isProcessableResponse(_ response: Moya.Response) -> Bool {
        // TODO: 서버 데이터 타입보고 에러 코드 전역적으로 처리하기 위한 메소드
        return true
    }
}
