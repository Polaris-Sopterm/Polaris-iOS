//
//  SettingViewModel.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/08/17.
//

import Foundation
import RxSwift

enum SettingMenu: Int, CaseIterable {
    case editNickname = 0
    case personalInformation
    case serviceOfTerms
    case makerPolaris
    case logout
    case signout
    
    var title: String {
        switch self {
        case .editNickname:        return "별명 변경하기"
        case .personalInformation: return "개인정보 수집 이용 안내"
        case .serviceOfTerms:      return "서비스 이용약관 안내"
        case .makerPolaris:        return "폴라리스를 소개합니다!"
        case .logout:              return "로그아웃"
        case .signout:             return "서비스 탈퇴"
        }
    }
}

final class SettingViewModel {
    
    let menusSubject   = BehaviorSubject<[SettingMenu]>(value: SettingMenu.allCases)
    let loadingSubject = PublishSubject<Bool>()
    
    func requestLogout(completion: @escaping (Bool) -> Void) {
        let logoutAPI = UserAPI.logout
        self.loadingSubject.onNext(true)
        NetworkManager.request(apiType: logoutAPI).subscribe(onSuccess: { [weak self] (successModel: SuccessModel) in
            self?.loadingSubject.onNext(false)
            guard let isSuccess = successModel.isSuccess else { return }
            completion(isSuccess)
        }, onFailure: { [weak self] _ in
            self?.loadingSubject.onNext(false)
        }).disposed(by: self.disposeBag)
    }
    
    private let disposeBag = DisposeBag()
    
}
