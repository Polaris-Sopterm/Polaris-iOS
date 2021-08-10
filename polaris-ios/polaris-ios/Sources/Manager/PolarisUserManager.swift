//
//  PolarisUserManager.swift
//  polaris-ios
//
//  Created by USER on 2021/04/15.
//

import Foundation
import RxSwift

class PolarisUserManager {
    
    static let shared = PolarisUserManager()
    
    var hasToken: Bool        { return self.authToken != nil }
    var hasRefreshToken: Bool { return self.refreshToken != nil }
    
    func updateAuthToken(_ token: String, _ refreshToken: String) {
        self.authToken    = token
        self.refreshToken = refreshToken
    }
    
    // 앱에 최초 한 번 진입한 경우 - Onboarding을 경험했다고 표시
    func updateOnboardingExperienceStatus() {
        self.isInitialMember = false
    }
    
    func resetUserInfo() {
        self.authToken    = nil
        self.refreshToken = nil
    }
    
    func requestAccessTokenUsingRefreshToken() {
        guard let refreshToken = self.refreshToken else { return }
        
        let reauthAPI = UserAPI.reauth(refreshToken: refreshToken)
        NetworkManager.request(apiType: reauthAPI).subscribe(onSuccess: { (authModel: AuthModel) in
            self.updateAuthToken(authModel.accessToken, authModel.refreshToken)
        }, onFailure: { error in
            print(error.localizedDescription)
        })
        .disposed(by: self.disposeBag)
    }
    
    func updateUser(_ polarisUser: PolarisUser) {
        self.user = polarisUser
    }
    
    private let disposeBag = DisposeBag()
    
    private(set) var user: PolarisUser?
    
    @UserDefaultWrapper<Bool>(key: UserDefaultsKey.isInitialMember) private(set) var isInitialMember
    @UserDefaultWrapper<String>(key: UserDefaultsKey.auth) private(set) var authToken
    @UserDefaultWrapper<String>(key: UserDefaultsKey.refresh) private(set) var refreshToken
    
}
