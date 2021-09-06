//
//  PolarisMakersViewController.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/09/04.
//

import RxSwift
import RxCocoa
import UIKit

final class PolarisMakersVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupPageControl()
        self.layoutCollectionView()
        self.setupCollectionView()
        self.bindButtons()
    }
    
    private func setupPageControl() {
        self.pageControl.numberOfPages = PolarisMaker.allCases.count
        
        self.viewModel.currentPageSubject.observeOnMain(onNext: { [weak self] currentPage in
            guard let self = self else { return }
            self.pageControl.currentPage = currentPage
        }).disposed(by: self.disposeBag)
    }
    
    private func layoutCollectionView() {
        let layout = self.collectionView.collectionViewLayout
        
        guard let flowLayout = layout as? UICollectionViewFlowLayout else { return }
        let cellWidth: CGFloat  = DeviceInfo.screenWidth
        let cellHeight: CGFloat = DeviceInfo.screenHeight
        
        flowLayout.itemSize                = CGSize(width: cellWidth, height: cellHeight)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing      = 0
        flowLayout.sectionInset            = .zero
    }
    
    private func setupCollectionView() {
        self.collectionView.registerCell(cell: PolarisMakerCollectionViewCell.self)
        self.collectionView.rx.setDelegate(self)
            .disposed(by: self.disposeBag)
        
        self.viewModel.makersRelay.bind(to: self.collectionView.rx.items) { collectionView, index, item in
            let indexPath = IndexPath(item: index, section: 0)
            let cell      = collectionView.dequeueReusableCell(cell: PolarisMakerCollectionViewCell.self,
                                                               forIndexPath: indexPath)
            
            guard let makerCell = cell else { return UICollectionViewCell() }
            makerCell.configure(item)
            
            return makerCell
        }.disposed(by: self.disposeBag)
    }
    
    private func bindButtons() {
        self.backButton.rx.tap.observeOnMain(onNext: { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }).disposed(by: self.disposeBag)
    }
    
    
    private let disposeBag = DisposeBag()
    private let viewModel  = PolarisMakerViewModel()
    
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var pageControl: UIPageControl!
    
}

extension PolarisMakersVC: UICollectionViewDelegate {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let targetOffsetX = targetContentOffset.pointee.x
        let estimatedPage = targetOffsetX / DeviceInfo.screenWidth
        let roundedPage   = Int(round(estimatedPage))
        
        self.viewModel.currentPageSubject.onNext(roundedPage)
    }
    
}

enum PolarisMaker: CaseIterable {
    case productManager
    case designer
    case iosDeveloper
    case serverDeveloper
}

extension PolarisMaker {
    
    var title: String {
        switch self {
        case .productManager:  return "Product Managers"
        case .designer:        return "Designers"
        case .iosDeveloper:    return "iOS Developers"
        case .serverDeveloper: return "Back-end Developers"
        }
    }
    
    var backgroundMoonImage: UIImage? {
        switch self {
        case .productManager:   return UIImage(named: ImageName.plannerBackMoon)
        case .designer:         return UIImage(named: ImageName.designerBackMoon)
        case .iosDeveloper:     return UIImage(named: ImageName.iosBackMoon)
        case .serverDeveloper:  return UIImage(named: ImageName.serverBackMoon)
        }
    }
    
    var memberImage: UIImage? {
        switch self {
        case .productManager:   return UIImage(named: ImageName.plannerMember)
        case .designer:         return UIImage(named: ImageName.designerMember)
        case .iosDeveloper:     return UIImage(named: ImageName.iosMember)
        case .serverDeveloper:  return UIImage(named: ImageName.serverMember)
        }
    }
    
}
