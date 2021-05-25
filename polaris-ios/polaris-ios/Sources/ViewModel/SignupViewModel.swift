//
//  SignupViewModel.swift
//  polaris-ios
//
//  Created by USER on 2021/05/23.
//

import Foundation
import RxSwift
import RxRelay

enum IdValidateState: Equatable {
    case empty
    case validation(Bool)
    
    static func ==(lhs: Self, rhs: Self) -> Bool {
        if case .validation(let lhsValidate) = lhs, case .validation(let rhsValidate) = rhs {
            return lhsValidate == rhsValidate
        }
        
        if case .empty = lhs, case .empty = rhs { return true }
        else                                    { return false }
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

class SignupViewModel {
    
    let totalInputStateRelay = BehaviorRelay<SignupVC.InputOptions>(value: .firstStep)
    
    let idSubject       = BehaviorSubject<String>(value: "")
    let pwSubject       = BehaviorSubject<String>(value: "")
    let nicknameSubject = BehaviorSubject<String>(value: "")
    
    let validateIdSubejct       = BehaviorSubject<IdValidateState>(value: .empty)
    let validatePwSubject       = BehaviorSubject<PwValidateState>(value: .empty)
    let validateNicknameSubject = BehaviorSubject<Bool>(value: false)
    
    init() {
        self.idSubject
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] id in
                guard let self = self else { return }
                
                let validateState = self.isValidateId(as: id)
                self.validateIdSubejct.onNext(validateState)
            })
            .disposed(by: self.disposeBag)
        
        
            
    }
    
    func isValidateId(as input: String) -> IdValidateState {
        if input.isEmpty == true { return .empty }
        else                     { return .validation(true) }
    }
    
    func isValidatePw(as input: String) -> PwValidateState {
        if input.isEmpty == true { return .empty }
        
        let containAlphabet: Bool = input.containsCharacterSet(CharacterSet.alphanumerics)
        let containNumber: Bool   = input.containsCharacterSet(CharacterSet.decimalDigits)
        
        let combiValidate: Bool   = containAlphabet == true && containNumber == true
        let countValidate: Bool   = input.count >= 6
        
        if combiValidate == true && countValidate == true       { return .allValidation(true) }
        else if combiValidate == true && countValidate == false { return .eachValidation(.count) }
        else if combiValidate == false && countValidate == true { return .eachValidation(.combi) }
        else { return .allValidation(false) }
    }
    
    func isProcessableFirstStep(_ idValidateState: IdValidateState) -> Bool {
        guard case .validation(true) = idValidateState, self.isFirstStep == true else { return false }
        return true
    }
    
    func isProcessableSecondStep(_ pwValidateState: PwValidateState) -> Bool {
        guard case .allValidation(true) = pwValidateState, self.isSecondStep == true else { return false }
        return true
    }
    
    private var disposeBag = DisposeBag()
    
    private var isFirstStep: Bool  { return self.totalInputStateRelay.value == .firstStep }
    private var isSecondStep: Bool { return self.totalInputStateRelay.value == .secondStep }
    
}
