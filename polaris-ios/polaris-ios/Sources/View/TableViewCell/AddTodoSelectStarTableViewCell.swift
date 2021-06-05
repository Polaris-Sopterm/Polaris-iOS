//
//  AddTodoSelectStarTableViewCell.swift
//  polaris-ios
//
//  Created by USER on 2021/04/25.
//

import UIKit
import RxCocoa
import RxSwift

protocol AddTodoSelectStarTableViewCellDelegate: AddTodoTableViewCellDelegate {
    func addTodoSelectStarTableViewCell(_ addTodoSelectStarTableViewCell: AddTodoSelectStarTableViewCell, didSelectedStars stars: Set<PolarisStar>)
}

class AddTodoSelectStarTableViewCell: AddTodoTableViewCell {
    
    override class var cellHeight: CGFloat { return 397 * screenRatio }
    
    override weak var delegate: AddTodoTableViewCellDelegate? { didSet { self._delegate = self.delegate as? AddTodoSelectStarTableViewCellDelegate } }
    weak var _delegate: AddTodoSelectStarTableViewCellDelegate?

    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.registerCell()
        self.layoutCollectionView()
        self.bindCollectionView()
    }
    
    // MARK: - Set Up
    private func registerCell() {
        self.collectionView.registerCell(cell: SelectStarItemCollectionViewCell.self)
    }
    
    private func layoutCollectionView() {
        if let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize                 = CGSize(width: type(of: self).starCellWidth,
                                                     height: type(of: self).starCellHeight)
            layout.sectionInset             = .zero
            layout.minimumLineSpacing       = type(of: self).itemSpacing
            layout.minimumInteritemSpacing  = type(of: self).itemSpacing
        }
    }
    
    // MARK: - Bind
    private func bindCollectionView() {
        self.viewModel.starsSubject
            .bind(to: self.collectionView.rx.items) { collectionView, index, item in
                guard let starItemCell = collectionView.dequeueReusableCell(cell: SelectStarItemCollectionViewCell.self, forIndexPath: IndexPath(row: index
                                                                                                                                                 , section: 0)) else { return UICollectionViewCell() }
                
                let isSelected = self.viewModel.selectedStarsSet.contains(item)
                starItemCell.configure(by: item, isSelected)
                return starItemCell
            }
            .disposed(by: self.disposeBag)
        
        self.collectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                guard let selectedStar = try? self.viewModel.starsSubject.value()[safe: indexPath.row] else { return }
                
                self.viewModel.selectedFlagSubject.onNext(selectedStar)
                self._delegate?.addTodoSelectStarTableViewCell(self, didSelectedStars: self.viewModel.selectedStarsSet)
            })
            .disposed(by: self.disposeBag)
    }
    
    private static let screenRatio: CGFloat         = DeviceInfo.screenWidth / 375
    private static let verticalInset: CGFloat       = 10
    private static let horizontalInset: CGFloat     = 23
    private static let itemSpacing: CGFloat         = 8
    private static let starCellWidth: CGFloat       = (DeviceInfo.screenWidth - (2 * horizontalInset) - (2 * itemSpacing)) / 3
    private static let starCellHeight: CGFloat      = starCellWidth
    
    private var disposeBag = DisposeBag()
    private var viewModel  = AddTodoSelectStarViewModel()
    
}
