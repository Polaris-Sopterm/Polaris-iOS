//
//  PolarisToastView.swift
//  polaris-ios
//
//  Created by USER on 2021/04/25.
//

import UIKit

class PolarisToastView: UIView {
    
    typealias TouchHandler = (() -> Void)
    
    var duration: TimeInterval = 1
    
    // MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundView.makeShadow(color: .maintext, opacity: 0.45)
    }
    
    // MARK: - Set Up
    func configure(text: String, touchHandler: TouchHandler? = nil) {
        self.toastLabel.text = text
        self.touchHandler    = touchHandler
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapToast(_:)))
        self.backgroundView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc
    func didTapToast(_ recognizer: UITapGestureRecognizer) {
        guard let touchHandler = self.touchHandler else { return }
        touchHandler()
        self.hide()
    }
    
    func show() {
        self.alpha = 0
        UIView.animate(withDuration: self.duration, animations: { [weak self] in
            self?.alpha = 1
        }, completion: { [weak self] _ in
            guard let self = self else  { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + self.duration) { [weak self] in
                self?.hide()
            }
        })
    }
    
    func hide() {
        UIView.animate(withDuration: self.duration, animations: {
            self.alpha = 0
        }, completion: { [weak self] isFinished in
            self?.removeFromSuperview()
        })
    }
    
    private var touchHandler: TouchHandler?
    
    @IBOutlet private weak var backgroundView: UIView!
    @IBOutlet private weak var toastLabel: UILabel!

}
