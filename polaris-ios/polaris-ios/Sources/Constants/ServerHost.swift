//
//  File.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/05/29.
//

import Foundation

struct ServerHost {
    
    static var main: String {
        switch BuildPhase.current {
        case .dev:  return "https://polaris-dev-n3c7rawkea-du.a.run.app"
        case .real: return "https://polaris-main-n3c7rawkea-du.a.run.app"
        }
    }
    
}
