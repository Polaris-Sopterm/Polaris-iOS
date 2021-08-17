//
//  UIView+.swift
//  polaris-ios
//
//  Created by USER on 2021/04/12.
//

import UIKit

extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get { return self.layer.cornerRadius     }
        set { self.layer.cornerRadius = newValue }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get { return self.layer.borderWidth     }
        set { self.layer.borderWidth = newValue }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            guard let color = self.layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
        
        set { self.layer.borderColor = newValue?.cgColor }
    }
    
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
    
    func makeShadow(color: UIColor, offset: CGSize = .zero, opacity: Float = 1, radius: CGFloat = 13) {
        self.layer.shadowColor   = color.cgColor
        self.layer.shadowOffset  = offset
        self.layer.shadowRadius  = radius
        self.layer.shadowOpacity = opacity
    }
    
    func setBorder(borderColor : UIColor?, borderWidth : CGFloat?) {
        
        if let borderColor_ = borderColor {
            self.layer.borderColor = borderColor_.cgColor
        } else {
            self.layer.borderColor = UIColor(red: 205/255, green: 209/255, blue: 208/255, alpha: 1.0).cgColor
        }
        if let borderWidth_ = borderWidth {
            self.layer.borderWidth = borderWidth_
        } else {
            self.layer.borderWidth = 1.0
        }
    }
}

