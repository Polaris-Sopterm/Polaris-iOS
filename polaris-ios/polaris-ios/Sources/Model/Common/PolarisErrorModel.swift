//
//  PolarisErrorModel.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/06/09.
//

import Foundation
import Moya

extension Moya.Response {
    
    var polarisErrorModel: PolarisErrorModel? {
        guard let decodeData = try? JSONDecoder().decode(PolarisErrorModel.self, from: self.data) else { return nil }
        return decodeData
    }
    
}

struct PolarisErrorModel: Codable {
    let code: Int?
    let message: String?
}

extension PolarisErrorModel {
    
    var polarisError: PolarisError? {
        guard let code = self.code else { return nil }
        return PolarisError(rawValue: code)
    }
    
    enum PolarisError: Int, Error {
        case didNotFoundUser        = 3    // Access Token 바뀌고 User를 못찾는 경우
        case login_Info_Incorrect   = 13   // 로그인 정보 잘못 입력한 경우
        case expiredToken           = 21   // Access Token 만료된 경우
        case expiredRefreshToken    = 22   // Refresh Token 만료된 경우
        case notFoundRetrospect     = 29   // 해당 주차 회고가 없는 경우
        case alreadyExistRetrospect = 28   // 이미 등록된 회고 정보인 경우
        
        var message: String {
            switch self {
            case .didNotFoundUser:          return "사용자를 찾을 수 없습니다."
            case .login_Info_Incorrect:     return "로그인 정보가 잘못되었습니다."
            case .expiredToken:             return "토큰이 만료되었습니다."
            case .expiredRefreshToken:      return "재발급 토큰이 만료되었습니다."
            case .notFoundRetrospect:       return "해당 주차 회고 기록이 없습니다."
            case .alreadyExistRetrospect:   return "이미 존재하는 회고 기록입니다."
            }
        }
    }
    
}
