//
//  ServiceTermKind.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/07/22.
//

import Foundation

enum ServiceTermKind {
    case personal
    case service
    
    var url: String {
        switch self {
        case .personal: return "https://sites.google.com/view/term-of-personal-info-polaris"
        case .service:  return "https://sites.google.com/view/term-of-service-polaris"
        }
    }
    
    var title: String {
        switch self {
        case .personal: return "개인정보처리방침"
        case .service:  return "서비스 이용약관 동의"
        }
    }
}
