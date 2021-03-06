//
//  LoginViewModel.swift
//  polaris-ios
//
//  Created by USER on 2021/05/23.
//

import Foundation
import RxSwift

final class LoginViewModel {
    
    let idSubject = BehaviorSubject<String>(value: "")
    let pwSubject = BehaviorSubject<String>(value: "")
    
    let loadingSubject          = BehaviorSubject<Bool>(value: false)
    let canProcessLoginSubject  = BehaviorSubject<Bool>(value: false)
    let completeLoginSubject    = PublishSubject<Void>()
    
    init() {
        Observable.combineLatest(self.idSubject, self.pwSubject)
            .subscribe(onNext: { [weak self] idInput, pwInput in
                guard let self = self else { return }
                
                let isProceedLogin = self.isProceedLogin(idInput, pwInput)
                self.canProcessLoginSubject.onNext(isProceedLogin)
            }).disposed(by: self.disposeBag)
    }
    
    func isProceedLogin(_ idInput: String, _ pwInput: String) -> Bool {
        if idInput.isEmpty == false && pwInput.isEmpty == false { return true  }
        else                                                    { return false }
    }
    
    func requestLogin() {
        guard let id = try? self.idSubject.value(), let password = try? self.pwSubject.value() else { return }
        
        self.loadingSubject.onNext(true)
        let userAPI = UserAPI.auth(email: id, password: password)
        NetworkManager.request(apiType: userAPI)
            .subscribe(onSuccess: { [weak self] (authModel: AuthModel) in
                PolarisUserManager.shared.updateAuthToken(authModel.accessToken, authModel.refreshToken)
                self?.completeLoginSubject.onNext(())
                self?.loadingSubject.onNext(false)
            }, onFailure: { [weak self] error in
                print(error.localizedDescription)
                self?.loadingSubject.onNext(false)
            }).disposed(by: self.disposeBag)
    }
    
    private var disposeBag = DisposeBag()
    
}
