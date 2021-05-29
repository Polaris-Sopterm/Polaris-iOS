//
//  BuildPhase.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/05/29.
//

import Foundation

enum BuildPhase {
    case real
    case dev
    
    static var current: BuildPhase {
        #if DEV
        return .dev
        #elseif REAL
        return .real
        #endif
    }
}
