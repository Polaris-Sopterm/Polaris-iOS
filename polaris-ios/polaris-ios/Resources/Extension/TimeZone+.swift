//
//  TimeZone+.swift
//  polaris-ios
//
//  Created by Dongmin on 2022/03/19.
//

import Foundation

extension TimeZone {
    
    static var korea: TimeZone {
        TimeZone(abbreviation: "KST") ?? TimeZone.autoupdatingCurrent
    }
    
}
