//
//  PolarisWebViewController.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/07/21.
//

import RxCocoa
import RxSwift
import UIKit
import WebKit

class PolarisWebViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupCancelButton()
        self.setupWebView()
        self.bindButtons()
    }
    
    func setWebViewURL(_ urlString: String) {
        self.urlString = urlString
    }
    
    func setWebViewTitle(_ title: String) {
        self.webViewTitle = title
    }
    
    private func setupWebView() {
        self.polarisWebView.polarisNavigationDelegate = self

        self.titleLabel.text = self.webViewTitle
        guard let urlString = self.urlString          else { return }
        guard let webViewURL = URL(string: urlString) else { return }

        let webViewRequest = URLRequest(url: webViewURL)
        self.polarisWebView.load(webViewRequest)
    }
    
    private func setupCancelButton() {
        if self.navigationController != nil {
            self.cancelButton.setImage(#imageLiteral(resourceName: "btnBackLookBack").withTintColor(.maintext), for: .normal)
        } else {
            self.cancelButton.setImage(#imageLiteral(resourceName: "btnCloseJoin"), for: .normal)
        }
    }
    
    private func bindButtons() {
        self.cancelButton.rx.tap.observeOnMain(onNext: { [weak self] in
            if let navigationController = self?.navigationController {
                navigationController.popViewController(animated: true)
            } else {
                self?.dismiss(animated: true, completion: nil)
            }
        }).disposed(by: self.disposeBag)
    }
    
    private var webViewTitle: String?
    private var urlString: String?
    private let disposeBag = DisposeBag()
    
    @IBOutlet private weak var polarisWebView: PolarisWebView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var cancelButton: UIButton!
    
}

extension PolarisWebViewController: PolarisWebViewNavigationDelegate {
    
    func polarisWebView(_ polarisWebView: PolarisWebView, didCommit navigation: WKNavigation!) {
        
    }
    
    func polarisWebView(_ polarisWebView: PolarisWebView, didFinish navigation: WKNavigation!) {
        
    }
    
    func polarisWebView(_ polarisWebView: PolarisWebView, didFail navigation: WKNavigation!, withError error: Error) {

    }
    
}
