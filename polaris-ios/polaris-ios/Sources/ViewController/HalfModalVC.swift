//
//  HalfModalVC.swift
//  polaris-ios
//
//  Created by USER on 2021/04/16.
//

import UIKit
import RxCocoa
import RxSwift

class HalfModalVC: UIViewController {
    @IBOutlet weak var halfModalView: UIView!
    private var backgroundView: UIView?
    
    // MARK: - Life Cycle
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.modalPresentationStyle = .overFullScreen
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setupDimView()
        self.bindDimViewGesture()
        self.bindHalfModalPanGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard self.isBeingPresented == true || self.isMovingToParent else { return }
        self.halfModalViewWillAppear()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupHalfModalView()
    }
    
    private func halfModalViewWillAppear() {
        self.backgroundView?.alpha   = 0
        self.halfModalView.transform = CGAffineTransform(translationX: 0, y: DeviceInfo.screenHeight)
        
        UIView.animate(withDuration: type(of: self).animationDuration, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 1.0, options: [], animations: {
            self.halfModalView.transform  = .identity
            self.backgroundView?.alpha    = 0.5
        }, completion: nil)
    }
    
    func halfModalViewWillDisappear() {
        UIView.animate(withDuration: type(of: self).animationDuration, animations: {
            self.halfModalView.transform = CGAffineTransform(translationX: 0, y: DeviceInfo.screenHeight)
            self.backgroundView?.alpha   = 0
        }, completion: { finished in
            guard finished == true else { return }
            self.dismiss(animated: false, completion: nil)
        })
    }
    
    // MARK: - Set Up
    private func setupDimView() {
        let backgroundView              = UIView(frame: .zero)
        backgroundView.frame            = self.view.bounds
        backgroundView.backgroundColor  = UIColor.maintext
        self.backgroundView             = backgroundView
        
        self.view.addSubview(backgroundView)
        self.view.bringSubviewToFront(self.halfModalView)
    }
    
    private func setupHalfModalView() {
        self.halfModalView.makeRoundCorner(directions: [.topLeft, .topRight],
                                           radius: 15)
    }
    
    // MARK: - Bind
    private func bindDimViewGesture() {
        let tapGesture = UITapGestureRecognizer()
        self.backgroundView?.addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event
            .bind(onNext: { [weak self] recognizer in
                guard let self = self else { return }
                self.halfModalViewWillDisappear()
            })
            .disposed(by: self.disposeBag)
    }
    
    private func bindHalfModalPanGesture() {
        let panGesture = UIPanGestureRecognizer()
        self.halfModalView.addGestureRecognizer(panGesture)
        
        panGesture.rx.event
            .bind(onNext: { [weak self] recognizer in
                guard let self = self else { return }
                let thresholdY: CGFloat = 100
                
                let transition  = recognizer.translation(in: self.halfModalView)
                let changedY    = transition.y
                let resultY     = changedY + self.halfModalView.transform.ty
                
                switch recognizer.state {
                case .changed:
                    self.halfModalView.transform = CGAffineTransform(translationX: 0, y: resultY)
                    self.backgroundView?.alpha   = 0.5 - (min(max(0, resultY), thresholdY) / thresholdY) * 0.5
                case .ended, .cancelled, .failed:
                    guard resultY <= thresholdY else { self.halfModalViewWillDisappear(); return }
                    
                    UIView.animate(withDuration: type(of: self).animationDuration, animations: {
                        self.halfModalView.transform = .identity
                        self.backgroundView?.alpha   = 0.5
                    })
                default: break
                }
                
                recognizer.setTranslation(.zero, in: self.halfModalView)
            })
            .disposed(by: self.disposeBag)
    }
    
    static let animationDuration: TimeInterval  = 0.4
    private var disposeBag                      = DisposeBag()
}
