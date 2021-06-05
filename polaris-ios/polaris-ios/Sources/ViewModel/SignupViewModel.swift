//
//  SignupViewModel.swift
//  polaris-ios
//
//  Created by USER on 2021/05/23.
//

import Foundation
import RxSwift
import RxRelay

class SignupViewModel {
    
    var isFirstStep: Bool  { return self.stepRelay.value == .firstStep }
    var isSecondStep: Bool { return self.stepRelay.value == .secondStep }
    var isLastStep: Bool   { return self.stepRelay.value == .lastStep }
    
    var isProcessableFirstStep: Bool {
        guard let idValidateState = try? self.validateIdSubejct.value()          else { return false }
        guard case .validation(true) = idValidateState, self.isFirstStep == true else { return false }
        return true
    }
    
    var isProcessableSecondStep: Bool {
        guard let pwValidateState = try? self.validatePwSubject.value()              else { return false }
        guard case .allValidation(true) = pwValidateState, self.isSecondStep == true else { return false }
        return true
    }
    
    var isProcessableCompleteSignup: Bool {
        guard self.isLastStep == true else { return false }
        
        guard let idValidate       = try? self.validateIdSubejct.value(),
              let pwValidate       = try? self.validatePwSubject.value(),
              let nicknameValidate = try? self.validateNicknameSubject.value() else { return false }
        
        if idValidate == .validation(true) && pwValidate == .allValidation(true) && nicknameValidate == .validation(true) { return true }
        else { return false }
    }
    
    let stepRelay = BehaviorRelay<SignupVC.InputOptions>(value: .firstStep)
    
    let idSubject       = BehaviorSubject<String>(value: "")
    let pwSubject       = BehaviorSubject<String>(value: "")
    let nicknameSubject = BehaviorSubject<String>(value: "")
    
    let validateIdSubejct       = BehaviorSubject<IdValidateState>(value: .empty)
    let validatePwSubject       = BehaviorSubject<PwValidateState>(value: .empty)
    let validateNicknameSubject = BehaviorSubject<NicknameValidateState>(value: .empty)
    
    let completeSignupSubject   = BehaviorSubject<Bool>(value: false)
    
    init() {
        self.idSubject
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] id in
                guard let self = self else { return }
                
                self.isValidateId(as: id)
            })
            .disposed(by: self.disposeBag)
        
        
        self.pwSubject
            .subscribe(onNext: { [weak self] pw in
                guard let self = self else { return }
                
                let validateState = self.isValidatePw(as: pw)
                self.validatePwSubject.onNext(validateState)
            })
            .disposed(by: self.disposeBag)
        
        self.nicknameSubject
            .subscribe(onNext: { [weak self] nickname in
                guard let self = self else { return }
                
                let validateState = self.isValidateNickname(as: nickname)
                self.validateNicknameSubject.onNext(validateState)
            })
            .disposed(by: self.disposeBag)
        
        
    }
    
    func isValidateId(as input: String) {
        if input.isEmpty == true { self.validateIdSubejct.onNext(.empty) }
        else                     { self.requestCheckEmail(input) }
    }
    
    func isValidatePw(as input: String) -> PwValidateState {
        if input.isEmpty == true { return .empty }
        
        let containAlphabet: Bool = input.containsCharacterSet(CharacterSet.letters)
        let containNumber: Bool   = input.containsCharacterSet(CharacterSet.decimalDigits)
        
        let combiValidate: Bool   = containAlphabet == true && containNumber == true
        let countValidate: Bool   = input.count >= 6
        
        if combiValidate == true && countValidate == true       { return .allValidation(true) }
        else if combiValidate == true && countValidate == false { return .eachValidation(.count) }
        else if combiValidate == false && countValidate == true { return .eachValidation(.combi) }
        else { return .allValidation(false) }
    }
    
    func isValidateNickname(as input: String) -> NicknameValidateState {
        if input.isEmpty        { return .empty }
        else if input.count < 6 { return .validation(false) }
        else                    { return .validation(true) }
    }
    
    func confirmCompleteSignup() {
        guard let email    = try? self.idSubject.value(),
              let password = try? self.pwSubject.value(),
              let nickname = try? self.nicknameSubject.value() else { return }
        
        self.requestSignup(email, password, nickname)
    }
    
    private func requestCheckEmail(_ email: String) {
        let userAPI = UserAPI.checkEmail(email: email)
        
        NetworkManager.request(apiType: userAPI).subscribe(onSuccess: { (checkEmail: CheckEmailModel) in
            if checkEmail.isDuplicated == true { self.validateIdSubejct.onNext(.validation(false)) }
            else                               { self.validateIdSubejct.onNext(.validation(true)) }
        }, onFailure: { error in
            #warning("이 뷰에서 독립적으로 Error 처리하는 경우")
            print(error.localizedDescription)
        })
        .disposed(by: self.disposeBag)
    }
    
    private func requestSignup(_ email: String, _ password: String, _ nickname: String) {
        let userAPI = UserAPI.createUser(email: email, password: password, nickname: nickname)
        
        NetworkManager.request(apiType: userAPI).subscribe(onSuccess: { (signupModel: SignupModel) in
            self.completeSignupSubject.onNext(true)
        }, onFailure: { error in
            self.completeSignupSubject.onNext(false)
        })
        .disposed(by: self.disposeBag)
    }
    
    private var disposeBag = DisposeBag()
    
}

/*
 중복 검사하는 부분 너무 구리게 짜서 나중에 고쳐야할 듯... 조건 늘어나면 추가하기 힘들듯
 */
enum IdValidateState: Equatable {
    case empty
    case validation(Bool)
    
    static func ==(lhs: Self, rhs: Self) -> Bool {
        if case .empty = lhs, case .empty = rhs { return true }
        
        if case validation(let lhsValiate) = lhs, case validation(let rhsValidate) = rhs {
            return lhsValiate == rhsValidate
        }
        
        return false
    }
}

enum PwValidateState: Equatable {
    case empty
    case allValidation(Bool)
    case eachValidation(PwInValidateType)
    
    // 둘 중 하나가 유효하지 못 한 경우 들어감
    enum PwInValidateType {
        case count
        case combi
    }
    
    static func ==(lhs: Self, rhs: Self) -> Bool {
        if case .empty = lhs, case .empty = rhs { return true }
        
        if case allValidation(let lhsValidate) = lhs, case allValidation(let rhsValidate) = rhs {
            return lhsValidate == rhsValidate
        }
        
        if case eachValidation(let lhsInvalid) = lhs, case eachValidation(let rhsInvalid) = rhs {
            return lhsInvalid == rhsInvalid
        }
        
        return false
    }
}

enum NicknameValidateState: Equatable {
    case empty
    case validation(Bool)
    
    static func ==(lhs: Self, rhs: Self) -> Bool {
        if case .empty = lhs, case .empty = rhs { return true }
        
        if case validation(let lhsValiate) = lhs, case validation(let rhsValidate) = rhs {
            return lhsValiate == rhsValidate
        }
        
        return false
    }
}
