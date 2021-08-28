//
//  SignoutViewModel.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/08/28.
//

import RxSwift
import Foundation

final class SignoutViewModel {
    
    let completeSubject = PublishSubject<Void>()
    let loadingSubject  = BehaviorSubject<Bool>(value: false)
    
    func requestSignout() {
        let signoutAPI = UserAPI.signout
        
        self.loadingSubject.onNext(true)
        NetworkManager.request(apiType: signoutAPI).subscribe(onSuccess: { [weak self] (successModel: SuccessModel) in
            self?.loadingSubject.onNext(false)
            guard successModel.isSuccess == true else { return }
            self?.completeSubject.onNext(())
        }, onFailure: { [weak self] _ in
            self?.loadingSubject.onNext(false)
        }).disposed(by: self.dipsoseBag)
    }

    private let dipsoseBag = DisposeBag()
    
}
