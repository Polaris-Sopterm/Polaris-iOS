//
//  Network.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/04/12.
//

import Foundation
import Moya
import RxSwift
import Network

class NetworkManager {
    
    static func request<T: Codable, U: TargetType>(provider: MoyaProvider<U> = MoyaProvider(session: DefaultSesssion.shared),
                                                   apiType: U) -> Single<T> {
        return Single<T>.create { single in
            let request = provider.request(apiType) { result in
                switch result {
                case .success(let response):
                    if let polarisError = response.polarisErrorModel?.polarisError {
                        self.handlePolarisError(polarisError)
                        single(.failure(polarisError))
                        return
                    }
                    
                    do {
                        guard let resultData = try response.mapString().data(using: .utf8) else {
                            throw NSError(domain: "JSON Parsing Error", code: -1, userInfo: nil)
                        }
                        
                        let responseJson = try JSONDecoder().decode(T.self, from: resultData)
                        single(.success(responseJson))
                    } catch let error {
                        single(.failure(error))
                    }
                case .failure(let error):
                    // TODO: 여기 전역적으로 네트워크 에러 띄우는 팝업창 코드 추가 예정
                    single(.failure(error))
                }
            }
            
            return Disposables.create { request.cancel() }
        }.retry { errorObservable -> Observable<Int> in
            return errorObservable.flatMap { error -> Observable<Int> in
                let polarisError = error as? PolarisErrorModel.PolarisError
                if polarisError == .expiredToken {
                    return Observable<Int>.timer(.milliseconds(1500), scheduler: MainScheduler.instance)
                }
                return Observable.error(error)
            }
        }
    }
    
    private static func handlePolarisError(_ polarisError: PolarisErrorModel.PolarisError) {
        switch polarisError {
        case .expiredToken:         self.handleExpiredAccessTokenError()
        case .expiredRefreshToken:  self.handleExpiredRefreshTokenError()
        case .login_Info_Incorrect: self.handleLoginError()
        default:                    return
        }
    }
    
}

extension NetworkManager {
    
    // AccessToken만 만료된 경우
    private static func handleExpiredAccessTokenError() {
        PolarisUserManager.shared.requestAccessTokenUsingRefreshToken()
    }
    
    // Access Token, Refresh Token 모두 만료된 경우
    private static func handleExpiredRefreshTokenError() {
        PolarisUserManager.shared.resetUserInfo()
        guard let loginViewController = LoginVC.instantiateFromStoryboard(StoryboardName.intro) else { return }
        UIApplication.shared.windows
            .filter({ $0.isKeyWindow }).first?.rootViewController = loginViewController
    }
    
    private static func handleLoginError() {
        guard let visibleController = UIViewController.getVisibleController() else { return }
        guard visibleController is LoginVC                                    else { return }
        
        guard let popupView: PolarisPopupView = UIView.fromNib() else { return }
        #warning("확인형 팝업으로 바꿔야함")
        popupView.configure(title: "로그인에 실패했어요.", subTitle: "실패했습니다.")
        popupView.show(in: visibleController.view)
    }
    
}
