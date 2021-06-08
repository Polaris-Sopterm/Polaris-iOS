//
//  PolarisUserManager.swift
//  polaris-ios
//
//  Created by USER on 2021/04/15.
//

import Foundation

class PolarisUserManager {
    
    static let shared = PolarisUserManager()
    
    @UserDefaultWrapper<String>(key: UserDefaultsKey.auth) private(set) var authToken
    @UserDefaultWrapper<String>(key: UserDefaultsKey.refresh) private(set) var refreshToken
    
    var hasToken: Bool        { return self.authToken != nil }
    var hasRefreshToken: Bool { return self.refreshToken != nil }
    
    func updateAuthToken(_ token: String, _ refreshToken: String) {
        self.authToken = token
        self.refreshToken = refreshToken
    }
    
}
