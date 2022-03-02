//
//  UserDefaultsKeys.swift
//  polaris-ios
//
//  Created by USER on 2021/04/15.
//

import Foundation

struct UserDefaultsKey {
    static let auth             = "authrorication"
    static let refresh          = "refreshToken"
    
    static let isInitialMember  = "isInitialMember"         // 처음으로 앱에 진입하는 유저인지 - Onboarding
    static let jumpDates         = "jumpDates"                // 건너뛰기를 한 날짜들(PolarisDate 기준)
}
