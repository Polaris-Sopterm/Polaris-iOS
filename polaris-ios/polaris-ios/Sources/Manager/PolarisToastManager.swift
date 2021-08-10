//
//  PolarisToastManager.swift
//  polaris-ios
//
//  Created by USER on 2021/04/25.
//

import UIKit

class PolarisToastManager {
    typealias TouchHandler = (() -> Void)
    
    static let shared = PolarisToastManager()
    
    func showToast(with text: String, duration: TimeInterval = 1, touchHandler: TouchHandler? = nil) {
        guard let toastView: PolarisToastView = PolarisToastView.fromNib()                  else { return }
        guard let keyWindow = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first else { return }
        
        toastView.frame = CGRect(x: 23, y: DeviceInfo.screenHeight - 51 - type(of: self).toastHeight,
                                 width: type(of: self).toastWidth, height: type(of: self).toastHeight)
        toastView.configure(text: text, touchHandler: touchHandler)
        toastView.duration = duration
        
        keyWindow.addSubview(toastView)
        toastView.show()
    }
    
    private static let toastHeight: CGFloat = 48
    private static let toastWidth: CGFloat  = DeviceInfo.screenWidth - (23 * 2)
}
