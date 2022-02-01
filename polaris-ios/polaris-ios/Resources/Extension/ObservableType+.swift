//
//  Observable+.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/07/21.
//

import Foundation
import RxSwift

extension ObservableType {
    
    func observeOnMain(onNext: @escaping (Self.Element) -> Void, onError: ((Error) -> Void)? = nil) -> Disposable {
        return self.observe(on: MainScheduler.instance).subscribe(onNext: onNext, onError: onError)
    }
    
}
