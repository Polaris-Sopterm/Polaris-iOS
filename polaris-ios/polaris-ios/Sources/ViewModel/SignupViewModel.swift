//
//  SignupViewModel.swift
//  polaris-ios
//
//  Created by USER on 2021/05/23.
//

import Foundation
import RxSwift
import RxRelay
import OSLog

class SignupViewModel {
    
    let stepRelay = BehaviorRelay<SignupVC.InputOptions>(value: .firstStep)
    
    let idSubject       = BehaviorSubject<String>(value: "")
    let pwSubject       = BehaviorSubject<String>(value: "")
    let nicknameSubject = BehaviorSubject<String>(value: "")
    
    let idDuplicatedValidRelay  = BehaviorRelay<Bool>(value: false)
    let idFormatValidRelay      = BehaviorRelay<Bool>(value: false)
    let pwCountValidRelay       = BehaviorRelay<Bool>(value: false)
    let pwFormatValidRelay      = BehaviorRelay<Bool>(value: false)
    let nicknameCountValidRelay = BehaviorRelay<Bool>(value: false)
    
    let completeSignupSubject   = BehaviorSubject<Bool>(value: false)
    
    var isFirstStep: Bool  { return self.stepRelay.value == .firstStep }
    var isSecondStep: Bool { return self.stepRelay.value == .secondStep }
    var isLastStep: Bool   { return self.stepRelay.value == .lastStep }
    
    init() {
        self.idSubject
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] id in
                self?.checkEmailFormatValidation(id)
                self?.checkEmailDuplicatedValidation(id)
            })
            .disposed(by: self.disposeBag)
        
        self.pwSubject
            .subscribe(onNext: { [weak self] pw in
                self?.checkPasswordFormatValidation(pw)
                self?.checkPasswordCountValidation(pw)
            })
            .disposed(by: self.disposeBag)
        
        self.nicknameSubject
            .subscribe(onNext: { [weak self] nickname in
                self?.checkNicknameCountValidation(nickname)
            })
            .disposed(by: self.disposeBag)
    }
    
    func requestSignup(completion: @escaping () -> Void) {
        guard let id = try? self.idSubject.value(), let pw = try? self.pwSubject.value(),
              let nickname = try? self.nicknameSubject.value() else { return }
        let userAPI = UserAPI.createUser(email: id, password: pw, nickname: nickname)
        NetworkManager.request(apiType: userAPI)
            .subscribe(onSuccess: { (signupModel: PolarisUser) in
                PolarisUserManager.shared.updateUser(signupModel)
                completion()
            }, onFailure: { error in
                #warning("네트워크 에러일 때, 처리 필요")
                print(error.localizedDescription)
            })
            .disposed(by: self.disposeBag)
    }
    
    func processFirstStep() {
        guard self.isFirstStep == true else { return }
        
        if self.isProcessableFirstStep == true { self.stepRelay.accept(.secondStep) }
    }
    
    func processSecondStep() {
        guard self.isSecondStep == true else { return }
        
        if self.isProcessableSecondStep == true { self.stepRelay.accept(.lastStep) }
    }
    
    func processLastStep() {
        guard self.isLastStep == true else { return }
        
        if self.isProcessableLastStep == true { self.completeSignupSubject.onNext(true) }
        else { self.completeSignupSubject.onNext(false) }
    }
    
    private func checkEmailFormatValidation(_ id: String) {
        guard id.isEmailFormat() == true else { self.idFormatValidRelay.accept(false); return }
        self.idFormatValidRelay.accept(true)
    }
    
    private func checkEmailDuplicatedValidation(_ id: String) {
        let userAPI = UserAPI.checkEmail(email: id)
        
        NetworkManager.request(apiType: userAPI)
            .subscribe(onSuccess: { [weak self] (checkEmailModel: CheckEmailModel) in
                guard let self = self else { return }
                
                if checkEmailModel.isDuplicated == true { self.idDuplicatedValidRelay.accept(false) }
                else { self.idDuplicatedValidRelay.accept(true) }
            }, onFailure: { [weak self] error in
                self?.idDuplicatedValidRelay.accept(false)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func checkPasswordFormatValidation(_ password: String) {
        let passwordFormatValidation = password.isPasswordFormat()
        self.pwFormatValidRelay.accept(passwordFormatValidation)
    }
    
    private func checkPasswordCountValidation(_ password: String) {
        let passwordCountValidation = password.count >= 6
        self.pwCountValidRelay.accept(passwordCountValidation)
    }
    
    private func checkNicknameCountValidation(_ nickname: String) {
        let nicknameCountValidation = nickname.count >= 6
        self.nicknameCountValidRelay.accept(nicknameCountValidation)
    }
    
    private var isProcessableFirstStep: Bool {
        return self.idDuplicatedValidRelay.value == true && self.idFormatValidRelay.value == true
    }
    
    private var isProcessableSecondStep: Bool {
        return self.isProcessableFirstStep == true && self.pwFormatValidRelay.value == true
            && self.pwCountValidRelay.value == true
    }
    
    private var isProcessableLastStep: Bool {
        return self.isProcessableSecondStep == true && self.nicknameCountValidRelay.value == true
    }
    
    private var disposeBag = DisposeBag()
    
}
