//
//  PolarisUserManager.swift
//  polaris-ios
//
//  Created by USER on 2021/04/15.
//

import Foundation

class PolarisUserManager {
    @UserDefaultWrapper<String>(key: UserDefaultsKey.auth) var authToken
    
    static let shared = PolarisUserManager()
}
