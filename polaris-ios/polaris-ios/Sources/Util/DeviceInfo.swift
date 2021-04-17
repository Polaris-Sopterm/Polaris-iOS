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
}
