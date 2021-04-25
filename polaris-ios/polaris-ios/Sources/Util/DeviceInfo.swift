//
//  DeviceInfo.swift
//  polaris-ios
//
//  Created by USER on 2021/04/17.
//

import UIKit

struct DeviceInfo {
    static var screenWidth: CGFloat     { return UIScreen.main.bounds.width }
    static var screenHeight: CGFloat    { return UIScreen.main.bounds.height }
    static var statusBarHeight: CGFloat {
        return UIApplication.shared.windows.filter({ $0.isKeyWindow }).first?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
    }
    
    static var bottomSafeAreaInset: CGFloat { return UIApplication.shared.windows.filter({ $0.isKeyWindow }).first?.safeAreaInsets.bottom ?? 0 }
    static var topSafeAreaInset: CGFloat    { return UIApplication.shared.windows.filter({ $0.isKeyWindow }).first?.safeAreaInsets.top ?? 0 }
}
