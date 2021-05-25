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
    
    private var disposeBag = DisposeBag()
    
}
