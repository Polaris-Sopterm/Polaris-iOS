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
        
        toastView.configure(text: text, touchHandler: touchHandler)
        toastView.duration = duration
        
        keyWindow.addSubview(toastView)
        toastView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(23)
            make.trailing.equalToSuperview().offset(-23)
            make.bottom.equalToSuperview().offset(-51)
            make.height.equalTo(48)
        }
        
        toastView.show()
    }
    
    private init() { }
    
}
