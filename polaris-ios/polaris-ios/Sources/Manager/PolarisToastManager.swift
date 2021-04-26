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
        let toastView: PolarisToastView? = PolarisToastView.fromNib()
        toastView?.frame                 = CGRect(x: (DeviceInfo.screenWidth - type(of: self).toastWidth) / 2,
                                                  y: DeviceInfo.screenHeight - type(of: self).toastHeight - DeviceInfo.bottomSafeAreaInset - 20,
                                                  width: type(of: self).toastWidth,
                                                  height: type(of: self).toastHeight)
        toastView?.setupToastView(text: text, touchHandler: touchHandler)
        toastView?.duration = duration
        
        guard let keyWindow       = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first,
              let unWrapToastView = toastView else { return }
        keyWindow.addSubview(unWrapToastView)
        unWrapToastView.presentWithAnimation()
    }
    
    private static let toastHeight: CGFloat     = 48 * screenRatio
    private static let toastWidth: CGFloat      = 329 * screenRatio
    private static let screenRatio: CGFloat     = DeviceInfo.screenWidth / 375
}
