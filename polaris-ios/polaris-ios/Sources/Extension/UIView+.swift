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
    
    func makeRounded(cornerRadius : CGFloat?){
        if let cornerRadius_ = cornerRadius {
            self.layer.cornerRadius = cornerRadius_
        }  else {
            // cornerRadius 가 nil 일 경우의 default
            self.layer.cornerRadius = self.layer.frame.height / 2
        }
        self.layer.masksToBounds = true
    }
    
    func makeRoundCorner(directions: UIRectCorner = .allCorners, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds,
                                byRoundingCorners: directions,
                                cornerRadii: CGSize(width: radius, height: radius))
        
        let mask        = CAShapeLayer()
        mask.path       = path.cgPath
        self.layer.mask = mask
    }
}

