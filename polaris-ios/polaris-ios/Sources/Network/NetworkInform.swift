//
//  NetworkInform.swift
//  Polaris
//
//  Created by Dongmin on 2021/06/03.
//

import Foundation

struct NetworkInform {
    
    static var headers: [String: String] {
        let authToken = PolarisUserManager.shared.authToken ?? ""
        return ["Content-Type": "application/json", "Token": "Bearer \(authToken)"]
    }
    
}
