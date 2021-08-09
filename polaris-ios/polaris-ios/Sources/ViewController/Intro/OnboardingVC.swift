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
            case .first:    return "당신의 일상,"
            case .second:   return "당신의 여정,"
            case .third:    return "당신의 여정,"
            case .fourth:   return "당신의 우주,"
            case .last:    return "당신의 별,"
            }
        }
        
        var subTitle: String {
            switch self {
            case .first:    return "어떤 별을 위한 여정을 떠나볼까요?"
            case .second:   return "완료하기 위해 무엇을 해야하나요?"
            case .third:    return "만족스러우셨나요?"
            case .fourth:   return "어떤 별이 밝게 빛나고 있나요?"
            case .last:    return "지금부터 함께 찾아볼까요?"
            }
        }
        
        var description: String {
            switch self {
            case .first:    return "일주일의 목표를 미리 세워보며 당신이 추구하는\n삶의 가치가 무엇인지 고민해봐요."
            case .second:   return "각 여정을 완성하기 위해 세부적으로 할 일을 계획하며\n폴라리스를 완성해 나가요."
            case .third:    return "일주일의 여정이 끝난 다음, 여러분의 일상을 돌아보며\n어떤 별을 가장 빛냈는지 알아봐요"
            case .fourth:   return "여정 돌아보기를 통해 일주일의 여정과\n가장 밝게 빛나는 별을 확인해봐요"
            case .last:    return "일상 속 빛나는 여러분의 가치를 찾기 위한 여정,\n폴라리스와 함께 별을 찾아 떠나볼까요?"
            }
        }
        
        var image: UIImage? {
            switch self {
            case .first:    return UIImage(named: ImageName.mockImageFirst)
            case .second:   return UIImage(named: ImageName.mockImageSecond)
            case .third:    return UIImage(named: ImageName.mockImageThird)
            case .fourth:   return UIImage(named: ImageName.mockImageFourth)
            case .last:     return UIImage(named: ImageName.mockImageLast)
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
