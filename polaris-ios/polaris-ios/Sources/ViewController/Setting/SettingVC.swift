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
            self.pushEditNicknameController()
        case .personalInformation:
            self.pushTermsWebViewController(.personal)
        case .serviceOfTerms:
            self.pushTermsWebViewController(.service)
        case .logout:
            self.handleLogout()
        case .signout:
            self.pushSignoOutViewController()
        }
    }
    
    private func handleLogout() {
        guard let confirmPopupView: PolarisPopupView = UIView.fromNib() else { return }
        
        confirmPopupView.configure(title: "로그아웃할까요?", confirmTitle: "로그아웃", confirmHandler:  { [weak self] in
            guard let self = self else { return }
            
            self.viewModel.requestLogout { isSuccess in
                guard isSuccess == true else { return }
                PolarisUserManager.shared.processClearUserInformation()
            }
        })
        confirmPopupView.show(in: self.view)
    }
    
    private func pushTermsWebViewController(_ termsKind: ServiceTermKind) {
        let viewController = PolarisWebViewController.instantiateFromStoryboard(StoryboardName.common)
        
        guard let webViewController = viewController else { return }
        webViewController.setWebViewTitle(termsKind.title)
        webViewController.setWebViewURL(termsKind.url)
        self.navigationController?.pushViewController(webViewController, animated: true)
    }
    
    private func pushSignoOutViewController() {
        let viewController = SignOutVC.instantiateFromStoryboard(StoryboardName.setting)
        
        guard let signOutViewController = viewController else { return }
        self.navigationController?.pushViewController(signOutViewController, animated: true)
    }
    
    private func pushEditNicknameController() {
        guard let nickVC = NickChangeVC.instantiateFromStoryboard(StoryboardName.setting) else { return }
        self.navigationController?.pushViewController(nickVC, animated: true)
    }
    
    private let disposeBag = DisposeBag()
    private let viewModel  = SettingViewModel()
    
    private let loadingIndicatorView = UIActivityIndicatorView(style: .medium)
    
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var tableView: UITableView!
    
}
