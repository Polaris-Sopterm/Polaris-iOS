//
//  HalfModalVC.swift
//  polaris-ios
//
//  Created by USER on 2021/04/16.
//

import UIKit
import RxCocoa
import RxSwift

open class HalfModalVC: UIViewController {
    /// `HalfModalView` 반 모달로 띄우기 원하는 UIView
    public weak var halfModalView: UIView? {
        didSet { self.setupHalfModalView() }
    }
    
    // MARK: - Life Cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setupDimView()
        self.bindDimViewGesture()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.halfModalView?.makeRoundCorner(directions: [.topLeft, .topRight], radius: 15)
    }
    
    /// Present 시에, `HalfModalView`가 Animation되기 전에 불림.
    open func willPresentWithAnimation() { }
    
    /// Present 시에, `HalfModalView`가 Animation이 완료되고 불림.
    open func didPresentWithAnimation() { }
    
    /// Dismiss 시에, `HalfModalView`가 Animation 되기 전에 불림.
    open func willDismissWithAnimation() { }
    
    /// Dismiss 시에, `HalfModalView`가 Animation이 완료되고 불림.
    open func didDismissWithAnimation() { }
    
    /// `viewController`로부터 `HalfModalViewController`를 상속받은 `UIViewController`가 present 됩니다.
    public func presentWithAnimation(from viewController: UIViewController) {
        self.modalPresentationStyle = .overFullScreen
        self.willPresentWithAnimation()
        viewController.present(self, animated: false) {
            UIView.animate(withDuration: type(of: self).animationDuration, delay: 0, usingSpringWithDamping: 0.85,
                           initialSpringVelocity: 1.0, options: [.curveEaseInOut], animations: { [weak self] in
                            self?.halfModalView?.transform = .identity
                            self?.backgroundView?.alpha    = 0.5
                           }, completion: { [weak self] isFinished in
                            guard isFinished == true else { return }
                            self?.didPresentWithAnimation()
                           })
        }
    }
    
    /// `HalfModalViewControlelr`를 상속받은 `UIViewController`가 dismiss 됩니다.
    public func dismissWithAnimation() {
        guard let halfModalView = self.halfModalView else { return }
        self.willDismissWithAnimation()
        UIView.animate(withDuration: Self.animationDuration, animations: {
            halfModalView.transform     = CGAffineTransform(translationX: 0, y: type(of: self).screen_height)
            self.backgroundView?.alpha  = 0
        }, completion: { [weak self] isFinished in
            guard isFinished == true else { return }
            self?.didDismissWithAnimation()
            self?.dismiss(animated: false, completion: nil)
        })
    }
    
    // MARK: - Set Up
    private func setupHalfModalView() {
        guard let halfModalView = self.halfModalView else { return }
        
        halfModalView.transform = CGAffineTransform(translationX: 0, y: type(of: self).screen_height)
        self.bindHalfModalPanGesture()
        self.view.bringSubviewToFront(halfModalView)
    }
    
    private func setupDimView() {
        let backgroundView              = UIView(frame: .zero)
        backgroundView.frame            = self.view.bounds
        backgroundView.backgroundColor  = UIColor.maintext
        backgroundView.alpha            = 0.5
        self.backgroundView             = backgroundView
        
        self.view.addSubview(backgroundView)
        
        if let halfModalView = self.halfModalView { self.view.bringSubviewToFront(halfModalView) }
    }
    
    // MARK: - Bind
    private func bindDimViewGesture() {
        let tapGesture = UITapGestureRecognizer()
        self.backgroundView?.addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event
            .bind(onNext: { [weak self] recognizer in
                guard let self = self else { return }
                self.dismissWithAnimation()
            })
            .disposed(by: self.disposeBag)
    }
    
    private func bindHalfModalPanGesture() {
        guard let halfModalView = self.halfModalView else { return }
        
        let panGesture = UIPanGestureRecognizer()
        halfModalView.addGestureRecognizer(panGesture)
        
        panGesture.rx.event
            .bind(onNext: { [weak self] recognizer in
                guard let self = self else { return }
                let thresholdY: CGFloat = 100
                
                let transition  = recognizer.translation(in: self.halfModalView)
                let changedY    = transition.y
                let resultY     = changedY + halfModalView.transform.ty
                let velocityY   = recognizer.velocity(in: halfModalView).y
                
                switch recognizer.state {
                case .changed:
                    guard resultY >= 0 else { return }
                    print(velocityY)
                    halfModalView.transform = CGAffineTransform(translationX: 0, y: resultY)
                    self.backgroundView?.alpha   = 0.5 - (min(max(0, resultY), thresholdY) / thresholdY) * 0.5
                case .ended, .cancelled, .failed:
                    guard resultY <= thresholdY, velocityY <= 1200 else { self.dismissWithAnimation(); return }
                    
                    UIView.animate(withDuration: type(of: self).animationDuration, animations: {
                        halfModalView.transform    = .identity
                        self.backgroundView?.alpha = 0.5
                    })
                default: break
                }
                
                recognizer.setTranslation(.zero, in: halfModalView)
            })
            .disposed(by: self.disposeBag)
    }
    
    static let animationDuration: TimeInterval  = 0.4
    
    private static var screen_height: CGFloat               { return UIScreen.main.bounds.height }
    private static var screen_width: CGFloat                { return UIScreen.main.bounds.width  }
    
    private var backgroundView: UIView?
    private var disposeBag = DisposeBag()
    
}
