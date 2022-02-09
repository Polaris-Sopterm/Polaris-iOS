//
//  NickChangeViewModel.swift
//  polaris-ios
//
//  Created by Dongmin on 2022/02/09.
//

import RxSwift
import Foundation

final class NickChangeViewModel {
    
    let loadingSubject = PublishSubject<Bool>()
    let completeSubejct = PublishSubject<Void>()
    
    func requestChangeNickname(nickname: String) {
        self.loadingSubject.onNext(true)
        let userAPI = UserAPI.updateUser(nickname: nickname)
        
        NetworkManager.request(apiType: userAPI).subscribe(onSuccess: { [weak self] (polarisUser: PolarisUser) in
            PolarisUserManager.shared.updateUser(polarisUser)
            self?.loadingSubject.onNext(false)
            self?.completeSubejct.onNext(())
        }, onFailure: { error in
            self.loadingSubject.onNext(false)
        }).disposed(by: self.disposeBag)
    }
    
    private let disposeBag = DisposeBag()
    
}
