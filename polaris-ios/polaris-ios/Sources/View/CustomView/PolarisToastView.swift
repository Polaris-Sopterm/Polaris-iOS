//
//  PolarisToastView.swift
//  polaris-ios
//
//  Created by USER on 2021/04/25.
//

import UIKit

class PolarisToastView: UIView {
    typealias TouchHandler = (() -> Void)
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var toastLabel: UILabel!
    
    var duration: TimeInterval = 1
    
    // MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundView.makeRounded(cornerRadius: 17)
        self.makeShadow(color: UIColor.maintext.withAlphaComponent(0.45))
        self.alpha = 0
    }
    
    // MARK: - Set Up
    func setupToastView(text: String, touchHandler: TouchHandler? = nil) {
        self.toastLabel.text = text
        self.touchHandler    = touchHandler
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapToast(_:)))
        self.backgroundView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc
    func didTapToast(_ recognizer: UITapGestureRecognizer) {
        guard let touchHandler = self.touchHandler else { return }
        touchHandler()
        self.dismissWithAnimation()
    }
    
    func presentWithAnimation() {
        UIView.animate(withDuration: self.duration, animations: { [weak self] in
            self?.alpha = 1
        }, completion: { [weak self] isFinished in
            guard let self = self else  { return }
            guard isFinished else       { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + self.duration) { [weak self] in
                self?.dismissWithAnimation()
            }
        })
    }
    
    func dismissWithAnimation() {
        UIView.animate(withDuration: self.duration, animations: {
            self.alpha = 0
        }, completion: { [weak self] isFinished in
            self?.removeFromSuperview()
        })
    }
    
    private var touchHandler: TouchHandler?
}
