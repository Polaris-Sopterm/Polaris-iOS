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
    let code: Int
    let message: String
}

extension PolarisErrorModel {
    
    var polarisError: PolarisError? { return PolarisError(rawValue: self.code) }
    
    enum PolarisError: Int, Error {
        case expiredToken        = 21
        case expiredRefreshToken = 22
        
        var message: String {
            switch self {
            case .expiredToken:        return "토큰이 만료되었습니다."
            case .expiredRefreshToken: return "재발급 토큰이 만료되었습니다."
            }
        }
    }
    
}
