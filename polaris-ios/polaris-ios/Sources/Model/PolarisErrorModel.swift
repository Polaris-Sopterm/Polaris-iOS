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
        case expiredToken           = 21   // Access Token 만료된 경우
        case expiredRefreshToken    = 22   // Refresh Token 만료된 경우
        case login_Info_Incorrect   = 13   // 로그인 정보 잘못 입력한 경우
        
        var message: String {
            switch self {
            case .expiredToken:         return "토큰이 만료되었습니다."
            case .expiredRefreshToken:  return "재발급 토큰이 만료되었습니다."
            case .login_Info_Incorrect: return "로그인 정보가 잘못되었습니다."
            }
        }
    }
    
}
