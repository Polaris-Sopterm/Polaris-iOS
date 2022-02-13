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
                    self.printForDebug(apiType, response)
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
                    self.handleNetworkDisconnectIfNeeded()
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
    
    private static func printForDebug(_ api: TargetType, _ response: Moya.Response) {
        #if DEV
        guard let mapJSONString = try? response.mapString() else { return }
        
        print("")
        print("----------------------------DEBUG----------------------------")
        print("REQUEST API : \(String(describing: api.self))")
        print("RESPONSE JSON : \(mapJSONString)")
        print("----------------------------DEBUG----------------------------")
        print("")
        #endif
    }
    
    private static func handleNetworkDisconnectIfNeeded() {
        if NetworkDetector.shared.isConnected == false {
            PolarisToastManager.shared.showToast(with: "연결이 원활하지 않아요. 다시 시도해주세요.")
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
        PolarisUserManager.shared.processClearUserInformation()
    }
    
    private static func handleLoginError() {
        guard let visibleController = UIViewController.getVisibleController() else { return }
        guard visibleController is LoginVC                                    else { return }
        
        guard let popupView: ConfirmPopupView = UIView.fromNib() else { return }
        popupView.configure(title: "로그인에 실패했어요.")
        popupView.show(in: visibleController.view)
    }
    
}
