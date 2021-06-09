//
//  LoginViewModel.swift
//  polaris-ios
//
//  Created by USER on 2021/05/23.
//

import Foundation
import RxSwift

class LoginViewModel {
    
    let idSubject = BehaviorSubject<String>(value: "")
    let pwSubject = BehaviorSubject<String>(value: "")
    
    let proceedAbleSubject = BehaviorSubject<Bool>(value: false)
    
    init() {
        Observable.combineLatest(self.idSubject, self.pwSubject)
            .subscribe(onNext: { [weak self] idInput, pwInput in
                guard let self = self else { return }
                
                let isProceedLogin = self.isProceedLogin(idInput, pwInput)
                self.proceedAbleSubject.onNext(isProceedLogin)
            })
            .disposed(by: self.disposeBag)
    }
    
    func isProceedLogin(_ idInput: String, _ pwInput: String) -> Bool {
        if idInput.isEmpty == false && pwInput.isEmpty == false { return true  }
        else                                                    { return false }
    }
    
    func requestLogin() {
        guard let id = try? self.idSubject.value(), let password = try? self.pwSubject.value() else { return }
        
        let userAPI = UserAPI.auth(email: id, password: password)
        NetworkManager.request(apiType: userAPI)
            .subscribe(onSuccess: { (authModel: AuthModel) in
                #warning("다음 화면 넘어가는 로직")
                print(authModel)
                PolarisUserManager.shared.updateAuthToken(authModel.accessToken, authModel.refreshToken)
            }, onFailure: { error in
                print(error.localizedDescription)
            })
            .disposed(by: self.disposeBag)
    }
    
    private var disposeBag = DisposeBag()
    
}
