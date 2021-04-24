//
//  AddTodoDayTableViewCell.swift
//  polaris-ios
//
//  Created by USER on 2021/04/21.
//

import UIKit
import RxSwift

class AddTodoDayTableViewCell: AddTodoTableViewCell {
    override class var cellHeight: CGFloat {
        let labelHeight: CGFloat = 17
        let spacing: CGFloat     = 15
        return (verticalInset * 2) + dayCellHeight + spacing + labelHeight
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.registerCell()
        self.layoutColletionView()
        self.bindCollectionView()
        
        print(Date.todayDay)
        print(Date.todayWeekDay)
    }
    
    // MARK: - Set Up
    private func registerCell() {
        self.collectionView.registerCell(cell: PerDayItemCollectionViewCell.self)
    }
    
    private func layoutColletionView() {
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize                 = CGSize(width:  type(of: self).dayCellWidth,
                                                     height: type(of: self).dayCellHeight)
            layout.sectionInset             = .zero
            layout.minimumLineSpacing       = 2
            layout.minimumInteritemSpacing  = 0
        }
    }
    
    // MARK: - Bind
    private func bindCollectionView() {
        self.collectionView.rx.setDelegate(self)
            .disposed(by: self.disposeBag)
        
        self.viewModel.days
            .bind(to: self.collectionView.rx.items) { collectionView, index, item in
                guard let perDayCell = collectionView.dequeueReusableCell(cell: PerDayItemCollectionViewCell.self, forIndexPath: IndexPath(row: index, section: 0)) else { return UICollectionViewCell() }
                
                perDayCell.configure(day: "월", dayNumber: 1)
                
                return perDayCell
            }
            .disposed(by: self.disposeBag)
    }
    
    private static let horizontalInset: CGFloat     = 23
    private static let verticalInset: CGFloat       = 10
    private static let screenRatio: CGFloat         = DeviceInfo.screenWidth / 375
    private static let dayCellHeight: CGFloat       = 66 * screenRatio
    private static let dayCellWidth: CGFloat        = (DeviceInfo.screenWidth - (2 * horizontalInset) - (6 * 2)) / 7
    
    private var viewModel  = AddTodoDayViewModel()
    private var disposeBag = DisposeBag()
}

extension AddTodoDayTableViewCell: UICollectionViewDelegate {
    
}
