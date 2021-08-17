//
//  SceneDelegate.swift
//  polaris-ios
//
//  Created by USER on 2021/04/11.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        self.setInitRootViewController()
    }
    
}

extension SceneDelegate {
    
    func setInitRootViewController() {
        if PolarisUserManager.shared.hasToken == true {
            guard let mainVC = MainVC.instantiateFromStoryboard(StoryboardName.main) else { return }
            let navigationController = UINavigationController(rootViewController: mainVC)
            navigationController.setNavigationBarHidden(true, animated: false)
            self.window?.rootViewController = navigationController
            self.window?.makeKeyAndVisible()
        } else {
            guard let loginVC = LoginVC.instantiateFromStoryboard(StoryboardName.intro) else { return }
            self.window?.rootViewController = loginVC
            self.window?.makeKeyAndVisible()
            
            if PolarisUserManager.shared.isInitialMember == nil {
                guard let onboardingVC = OnboardingVC.instantiateFromStoryboard(StoryboardName.intro) else { return }
                onboardingVC.modalPresentationStyle = .fullScreen
                onboardingVC.modalTransitionStyle   = .crossDissolve
                loginVC.present(onboardingVC, animated: false, completion: nil)
            }
        }
    }
    
}

