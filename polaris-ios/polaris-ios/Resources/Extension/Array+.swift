//
//  Array+.swift
//  polaris-ios
//
//  Created by USER on 2021/04/22.
//

import Foundation

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}
