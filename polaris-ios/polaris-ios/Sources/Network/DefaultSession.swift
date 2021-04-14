//
//  DefaultSession.swift
//  polaris-ios
//
//  Created by USER on 2021/04/12.
//

import Foundation
import Moya

class DefaultSesssion: Session {
    static let shared: DefaultSesssion = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest  = 30
        configuration.timeoutIntervalForResource = 30
        configuration.requestCachePolicy         = .useProtocolCachePolicy
        return DefaultSesssion(configuration: configuration)
    }()
}
