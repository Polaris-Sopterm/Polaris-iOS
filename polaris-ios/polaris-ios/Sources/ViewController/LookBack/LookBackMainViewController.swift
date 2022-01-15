//
//  LookBackMainViewController.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2021/12/26.
//

import UIKit
import Combine

class LookBackMainViewController: UIViewController {

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var backButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerViewHeightConstraint: NSLayoutConstraint!

    let deviceHeightRatio = DeviceInfo.screenHeight/812.0
    private var pageInstance : LookBackPageViewController?
    private var viewModel = LookBackViewModel()
    private var originPage = 0
    
    private var pageSubscription: AnyCancellable?
    private var lookbackEndSubscription: AnyCancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUIs()
        self.bindViewModel()
        // Do any additional setup after loading the view.
    }
    
    private func setUIs() {
        self.pageControl.numberOfPages = 6
        self.pageControl.pageIndicatorTintColor = .mainPurple10
        self.pageControl.currentPageIndicatorTintColor = .mainSky
        if #available(iOS 14.0, *) {
            self.pageControl.backgroundStyle = .minimal
            self.pageControl.allowsContinuousInteraction = false
        }
        self.backButtonHeightConstraint.constant *= deviceHeightRatio
        self.containerViewHeightConstraint.constant *= deviceHeightRatio
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pageSegue"{
            pageInstance = segue.destination as? LookBackPageViewController
        }
        pageInstance?.viewModel = self.viewModel
        
        guard let vcArr = self.pageInstance?.VCArray else { return }
        for vc in vcArr {
            guard let delegateVC = vc as? LookBackViewModelProtocol else { return }
            delegateVC.setPageDelegate(delegate: self)
        }
        
    }
    
    private func bindViewModel() {
        self.pageSubscription = self.viewModel.$page
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { value in
                self.pageControl.currentPage = value
                self.pageInstance?.setViewControllers([(self.pageInstance?.VCArray[safe: value])!],
                                                      direction: self.originPage < value ? .forward : .reverse,
                                                      animated: true,
                                                      completion: nil
                )
                self.originPage = value
            })
        self.lookbackEndSubscription = self.viewModel.$lookbackEnd
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { value in
                if value {
                    self.navigationController?.popViewController(animated: true)
                }
            })
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.viewModel.toPreviousPage()
    }
    
    
    @IBAction func xButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

protocol LookBackPageDelegate: AnyObject {
    func toNextPage()
    func toPreviousPage()
}

protocol LookBackViewModelProtocol {
    func setViewModel(viewModel: LookBackViewModel)
    func setPageDelegate(delegate: LookBackPageDelegate)
}

extension LookBackMainViewController: LookBackPageDelegate {
    func toNextPage() {
        self.viewModel.toNextPage()
    }
    
    func toPreviousPage() {
        self.viewModel.toPreviousPage()
    }
}

