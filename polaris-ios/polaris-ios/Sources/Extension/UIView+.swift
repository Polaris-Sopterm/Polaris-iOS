//
//  UIView+.swift
//  polaris-ios
//
//  Created by USER on 2021/04/12.
//

import UIKit

extension UIView {
    static var isExistNibFile: Bool {
        let nibName = String(describing: self)
        return Bundle.main.path(forResource: nibName, ofType: "nib") != nil
    }
    
    static func fromNib<T: UIView>() -> T? {
        let identifier = String(describing: T.self)
        guard let nib = Bundle.main.loadNibNamed(identifier, owner: nil, options: nil) else { return nil }
        return nib.first as? T
    }
}

