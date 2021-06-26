//
//  PolarisHalfModalViewController.swift
//  PolarisUIComponent
//
//  Created by Dongmin on 2021/06/26.
//

import UIKit

open class PolarisHalfModalViewController: UIViewController {
    
    public weak var halfModalView: UIView? {
        didSet {
            guard let halfModalView = self.halfModalView else { return }
            self.view.bringSubviewToFront(halfModalView)
            
            halfModalView.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.height)
        }
    }
    
    public var dimView = UIView(frame: .zero)
    
    /// Present, Dismiss Animation Duration 설정 가능
    public var animateDuration: TimeInterval = 0.2
    
    /// `HalfModalView`의 Pan Gesture 가능 여부를 결정합니다.
    public var enablePanning: Bool = true
    
    /// background를 Tap 했을 때, dismiss 기능을 활성화 여부를 결정합니다.
    /// - `true`: background를 Tap 했을 때, dimiss 됩니다
    /// - `false` : background를 Tap 했을 때, dismiss가 불가능합니다.
    public var enableTapOfDimView: Bool = true
    
    /// 현재 `halfModalView`가 Panning 중인지 알 수 있는 변수
    public var isPanning: Bool = false

    open override func viewDidLoad() {
        super.viewDidLoad()
        self.setupHalfModalView()
        self.setupDimView()
    }
    
    /// Present 시에 `halfModalView`가 animate 되기 전에 호출된다.
    open func halfModalViewWillAppearWithAnimation() { }
    
    /// Present 시에 `halfModalView`가 animaate가 완료되고 호출된다.
    open func halfModalViewDidAppearWithAnimation() { }
    
    /// Dismiss 시에 `halfModalView`가 animate 되기 전에 호출된다.
    open func halfModalViewWillDisappearWithAnimation() { }
    
    /// Dismiss 시에 `halfModalView`가 animate가 완료되고 호출된다.
    open func halfModalViewDidDisappearWithAnimation() { }
    
    /// HalfModalView를 present하기 위해 사용하는 메소드
    public func presentHalfModalView(from viewController: UIViewController,
                                     completion: (() -> Void)? = nil) {
        self.modalPresentationStyle = .overFullScreen
        
        viewController.present(self, animated: false) {
            self.halfModalViewWillAppearWithAnimation()
            
            UIView.animate(withDuration: self.animateDuration, animations: {
                self.halfModalView?.transform = .identity
            }) { [weak self] _ in
                self?.halfModalViewDidAppearWithAnimation()
                completion?()
            }
        }
    }
    
    public func dismissHalfModalView(completion: (() -> Void)? = nil) {
        self.halfModalViewWillDisappearWithAnimation()
        
        UIView.animate(withDuration: self.animateDuration, animations: {
            self.halfModalView?.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.height)
        }) { [weak self] _ in
            self?.halfModalViewDidDisappearWithAnimation()
            self?.dismiss(animated: false, completion: completion)
        }
    }
    
    private func setupDimView() {
        self.view.backgroundColor = .clear
        
        self.dimView.frame = self.view.bounds
        self.view.addSubview(self.dimView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapDimView(_:)))
        self.dimView.addGestureRecognizer(tapGesture)
    }
    
    private func setupHalfModalView() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPanningHalfModalView(_:)))
        self.halfModalView?.addGestureRecognizer(panGesture)
    }
    
    @objc private func didTapDimView(_ sender: UITapGestureRecognizer) {
        guard self.enableTapOfDimView == true else { return }
        self.dismissHalfModalView(completion: nil)
    }
    
    @objc private func didPanningHalfModalView(_ sender: UIPanGestureRecognizer) {
        guard self.enablePanning == true else { return }
        guard let halfModalView = self.halfModalView else { return }
        
        let thresholdY: CGFloat = 50
        let transitionY = sender.translation(in: halfModalView).y
        let changedY    = transitionY + halfModalView.transform.ty
        
        switch sender.state {
        case .changed:
            self.isPanning = true
            guard changedY >= 0 else { self.isPanning = false; return }
            halfModalView.transform = CGAffineTransform(translationX: 0, y: changedY)
        case .ended, .cancelled, .failed:
            guard changedY <= thresholdY,
                  sender.velocity(in: halfModalView).y <= 1200 else { self.dismissHalfModalView(); return }
            
            UIView.animate(withDuration: self.animateDuration) { self.halfModalView?.transform = .identity }
            self.isPanning = false
        default: break
        }
        
        sender.setTranslation(.zero, in: halfModalView)
    }

}
