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
    
    @UserDefaultWrapper<String>(key: UserDefaultsKey.auth) private(set) var authToken
    @UserDefaultWrapper<String>(key: UserDefaultsKey.refresh) private(set) var refreshToken
    
    var hasToken: Bool        { return self.authToken != nil }
    var hasRefreshToken: Bool { return self.refreshToken != nil }
    
    func updateAuthToken(_ token: String, _ refreshToken: String) {
        self.authToken    = token
        self.refreshToken = refreshToken
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
    
    private(set) var user: PolarisUser?
    private let disposeBag = DisposeBag()
    
}
