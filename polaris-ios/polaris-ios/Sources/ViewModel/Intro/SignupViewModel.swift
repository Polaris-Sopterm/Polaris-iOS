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

final class SignupViewModel {
    
    let stepRelay = BehaviorRelay<SignupVC.InputOptions>(value: .firstStep)
    
    let idSubject       = BehaviorSubject<String>(value: "")
    let pwSubject       = BehaviorSubject<String>(value: "")
    let nicknameSubject = BehaviorSubject<String>(value: "")
    
    let idDuplicatedValidRelay   = BehaviorRelay<Bool>(value: false)
    let idFormatValidRelay       = BehaviorRelay<Bool>(value: false)
    let pwCountValidRelay        = BehaviorRelay<Bool>(value: false)
    let pwFormatValidRelay       = BehaviorRelay<Bool>(value: false)
    let nicknameCountValidRelay  = BehaviorRelay<Bool>(value: false)
    let nicknameFormatValidRelay = BehaviorRelay<Bool>(value: false)
    
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
                self?.checkNicknameFormatValidation(nickname)
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
        let trimmedNickname = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        let nicknameCountValidation = trimmedNickname.isEmpty == false
        self.nicknameCountValidRelay.accept(nicknameCountValidation)
    }
    
    // 닉네임에 이모지, 특수 부호가 포함된 경우 제한
    private func checkNicknameFormatValidation(_ nickname: String) {
        let regex = try? NSRegularExpression(pattern: "^[0-9a-zA-Z가-힣ㄱ-ㅎㅏ-ㅣ\\s]*$", options: .caseInsensitive)
        let range = NSRange(location: 0, length: nickname.count)
        
        if let _ = regex?.firstMatch(in: nickname, options: .reportCompletion, range: range) {
            self.nicknameFormatValidRelay.accept(true)
        } else {
            self.nicknameFormatValidRelay.accept(false)
        }
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
            && self.nicknameFormatValidRelay.value == true
    }
    
    private var disposeBag = DisposeBag()
    
}
