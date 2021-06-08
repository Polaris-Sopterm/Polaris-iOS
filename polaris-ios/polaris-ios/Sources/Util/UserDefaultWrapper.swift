//
//  UserDefaultWrapper.swift
//  polaris-ios
//
//  Created by USER on 2021/04/15.
//

import Foundation

@propertyWrapper struct UserDefaultWrapper<T> {
    var wrappedValue: T? {
        get { return UserDefaults.standard.object(forKey: self.key) as? T }
        set {
            if newValue == nil { UserDefaults.standard.removeObject(forKey: key) }
            else               { UserDefaults.standard.setValue(newValue, forKey: key) }
        }
    }
    
    init(key: String) {
        self.key = key
    }
    
    private let key: String
}
