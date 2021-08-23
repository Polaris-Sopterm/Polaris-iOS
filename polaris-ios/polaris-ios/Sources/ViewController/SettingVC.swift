//
//  SettingVC.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/08/17.
//

import RxCocoa
import RxSwift
import UIKit

final class SettingVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupLoadingIndicatorView()
        self.setupTableView()
        self.bindButtons()
        self.observeViewModel()
    }
    
    private func setupLoadingIndicatorView() {
        self.view.addSubview(self.loadingIndicatorView)
        self.loadingIndicatorView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        
        self.loadingIndicatorView.isHidden = true
        self.loadingIndicatorView.stopAnimating()
    }
    
    private func setupTableView() {
        self.tableView.registerCell(cell: SettingMenuTableViewCell.self)
        self.tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: DeviceInfo.bottomSafeAreaInset, right: 0)
        self.tableView.rowHeight    = 54
        
        self.viewModel.menusSubject.bind(to: self.tableView.rx.items) { tableView, index, item in
            let indexPath = IndexPath(row: index, section: 0)
            let cell      = tableView.dequeueReusableCell(cell: SettingMenuTableViewCell.self, forIndexPath: indexPath)
            
            guard let settingMenuCell = cell else { return UITableViewCell() }
            settingMenuCell.configure(item.title)
            return settingMenuCell
        }.disposed(by: self.disposeBag)
        
        self.tableView.rx.itemSelected.observeOnMain(onNext: { [weak self] selectedIndexPath in
            guard let selectedMenu = SettingMenu(rawValue: selectedIndexPath.row) else { return }
            self?.handleSettingMenuEvent(selectedMenu)
            self?.tableView.deselectRow(at: selectedIndexPath, animated: false)
        }).disposed(by: self.disposeBag)
    }
    
    private func bindButtons() {
        self.backButton.rx.tap.observeOnMain(onNext: { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }).disposed(by: self.disposeBag)
    }
    
    private func observeViewModel() {
        self.viewModel.loadingSubject.observeOnMain(onNext: { [weak self] loading in
            self?.loadingIndicatorView.isHidden = loading == false
            loading ? self?.loadingIndicatorView.startAnimating() : self?.loadingIndicatorView.stopAnimating()
        }).disposed(by: self.disposeBag)
    }
    
    private func handleSettingMenuEvent(_ menu: SettingMenu) {
        switch menu {
        case .editNickname:
            #warning("여기에 윤재가 별명 변경하기로 연결되는 부분 추가")
            guard let nickVC = UIStoryboard(name: "NickChange", bundle: nil).instantiateViewController(withIdentifier: "NickChangeVC") as? NickChangeVC else { break }
            self.navigationController?.pushViewController(nickVC, animated: true)
            break
        case .personalInformation:
            self.pushTermsWebViewController(.personal)
        case .serviceOfTerms:
            self.pushTermsWebViewController(.service)
        case .logout:
            self.handleLogout()
        case .withdrawal:
            #warning("회원 탈퇴 연결")
            break
        }
    }
    
    private func handleLogout() {
        self.viewModel.requestLogout { isSuccess in
            guard isSuccess == true else { return }
            PolarisUserManager.shared.resetUserInfo()
            
            let viewController = LoginVC.instantiateFromStoryboard(StoryboardName.intro)
            guard let loginVieController = viewController else { return }
            UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController = loginVieController
        }
    }
    
    private func pushTermsWebViewController(_ termsKind: ServiceTermKind) {
        let viewController = PolarisWebViewController.instantiateFromStoryboard(StoryboardName.common)
        
        guard let webViewController = viewController else { return }
        webViewController.setWebViewTitle(termsKind.title)
        webViewController.setWebViewURL(termsKind.url)
        self.navigationController?.pushViewController(webViewController, animated: true)
    }
    
    private let disposeBag = DisposeBag()
    private let viewModel  = SettingViewModel()
    
    private let loadingIndicatorView = UIActivityIndicatorView(style: .medium)
    
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var tableView: UITableView!
    
}
