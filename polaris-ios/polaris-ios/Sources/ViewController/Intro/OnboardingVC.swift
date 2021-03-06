//
//  OnboardingVC.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/08/09.
//


import RxSwift
import RxCocoa
import UIKit

final class OnboardingVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.layoutCollectionView()
        self.setupCollectionView()
        self.bindButtons()
        self.observeViewModel()
        
        PolarisUserManager.shared.updateOnboardingExperienceStatus()
    }
    
    private func layoutCollectionView() {
        let naviHeight: CGFloat     = 54
        let horizonSpacing: CGFloat = 26 + 3
        let pageHeight: CGFloat     = 7
        let height: CGFloat
            = DeviceInfo.screenHeight - DeviceInfo.topSafeAreaInset - naviHeight - horizonSpacing - pageHeight
        
        guard let collectionViewLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        collectionViewLayout.itemSize                = CGSize(width: DeviceInfo.screenWidth, height: height)
        collectionViewLayout.minimumLineSpacing      = 0
        collectionViewLayout.minimumInteritemSpacing = 0
        collectionViewLayout.sectionInset            = .zero
    }
    
    private func setupCollectionView() {
        self.collectionView.registerCell(cell: OnboardingCollectionViewCell.self)
        self.collectionView.rx.setDelegate(self)
            .disposed(by: self.disposeBag)
        
        self.viewModel.onboardingLevelRelay
            .bind(to: self.collectionView.rx.items) { [weak self] collectionView, index, item in
                let indexPath = IndexPath(item: index, section: 0)
                let cell      = collectionView.dequeueReusableCell(cell: OnboardingCollectionViewCell.self,
                                                                   forIndexPath: indexPath)
                
                guard let onboardingCell = cell else { return UICollectionViewCell() }
                onboardingCell.delegate = self
                onboardingCell.configure(item)
                return onboardingCell
            }.disposed(by: self.disposeBag)
    }
    
    private func bindButtons() {
        self.backButton.rx.tap.observeOnMain(onNext: { [weak self] in
            self?.viewModel.updateCurrnetPage(.fourth)
        }).disposed(by: self.disposeBag)
        
        self.skipButton.rx.tap.observeOnMain(onNext: { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }).disposed(by: self.disposeBag)
    }
    
    private func observeViewModel() {
        self.viewModel.currentPageRelay.observeOnMain(onNext: { [weak self] page in
            guard let self = self else { return }
            
            self.pageControl.currentPage = page
            self.pageControl.isHidden    = page == OnboardingLevel.last.rawValue
            self.backButton.isHidden     = page != OnboardingLevel.last.rawValue
            
            let indexPath = IndexPath(item: page, section: 0)
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        }).disposed(by: self.disposeBag)
    }
    
    private let disposeBag = DisposeBag()
    private let viewModel  = OnboardingViewModel()
    
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var skipButton: UIButton!
    @IBOutlet private weak var pageControl: UIPageControl!
    @IBOutlet private weak var collectionView: UICollectionView!
    
}

extension OnboardingVC {
    
    enum OnboardingLevel: Int, CaseIterable {
        case first = 0, second, third, fourth, last
        
        var title: String {
            switch self {
            case .first:    return "????????? ??????,"
            case .second:   return "????????? ??????,"
            case .third:    return "????????? ??????,"
            case .fourth:   return "????????? ??????,"
            case .last:    return "????????? ???,"
            }
        }
        
        var subTitle: String {
            switch self {
            case .first:    return "?????? ?????? ?????? ????????? ????????????????"
            case .second:   return "???????????? ?????? ????????? ????????????????"
            case .third:    return "?????????????????????????"
            case .fourth:   return "?????? ?????? ?????? ????????? ??????????"
            case .last:    return "???????????? ?????? ????????????????"
            }
        }
        
        var description: String {
            switch self {
            case .first:    return "???????????? ????????? ?????? ???????????? ????????? ????????????\n?????? ????????? ???????????? ???????????????."
            case .second:   return "??? ????????? ???????????? ?????? ??????????????? ??? ?????? ????????????\n??????????????? ????????? ?????????."
            case .third:    return "???????????? ????????? ?????? ??????, ???????????? ????????? ????????????\n?????? ?????? ?????? ???????????? ????????????"
            case .fourth:   return "?????? ??????????????? ?????? ???????????? ?????????\n?????? ?????? ????????? ?????? ???????????????"
            case .last:    return "?????? ??? ????????? ???????????? ????????? ?????? ?????? ??????,\n??????????????? ?????? ?????? ?????? ????????????????"
            }
        }
        
        var image: UIImage? {
            switch self {
            case .first:    return UIImage(named: ImageName.imgOnboarding1)
            case .second:   return UIImage(named: ImageName.imgOnboarding2)
            case .third:    return UIImage(named: ImageName.imgOnboarding3)
            case .fourth:   return UIImage(named: ImageName.imgOnboarding4)
            case .last:     return UIImage(named: ImageName.imgOnboarding5)
            }
        }
        
        // WIDTH / HEIGHT
        var imageRatio: CGFloat {
            switch self {
            case .first:  return 328 / 524
            case .second: return 328 / 524
            case .third:  return 328 / 524
            case .fourth: return 328 / 524
            case .last:   return 291 / 367
            }
        }
    }
    
}

extension OnboardingVC: OnboardingCollectionViewCellDelegate {
    
    func onboardingCollectionViewCellDidTapPrevious(_ cell: OnboardingCollectionViewCell) {
        let currentLevel  = self.viewModel.currentPageRelay.value
        let previousLevel = currentLevel - 1
        
        guard let level = OnboardingLevel(rawValue: previousLevel) else { return }
        self.viewModel.updateCurrnetPage(level)
    }
    
    func onboardingCollectionViewCellDidTapNext(_ cell: OnboardingCollectionViewCell) {
        let currentLevel = self.viewModel.currentPageRelay.value
        let nextLevel    = currentLevel + 1
        
        guard let level = OnboardingLevel(rawValue: nextLevel) else { return }
        self.viewModel.updateCurrnetPage(level)
    }
    
    func onboardingCollectionViewCellDidTapStart(_ cell: OnboardingCollectionViewCell) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension OnboardingVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let onboardingCell = cell as? OnboardingCollectionViewCell else { return }
        onboardingCell.willDisplay()
    }
    
}
