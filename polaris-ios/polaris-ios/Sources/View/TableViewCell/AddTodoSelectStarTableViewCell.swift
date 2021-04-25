//
//  AddTodoSelectStarTableViewCell.swift
//  polaris-ios
//
//  Created by USER on 2021/04/25.
//

import UIKit
import RxCocoa
import RxSwift

class AddTodoSelectStarTableViewCell: AddTodoTableViewCell {
    override class var cellHeight: CGFloat {
        return 100
    }

    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layoutCollectionView()
    }
    
    // MARK: - Set Up
    private func layoutCollectionView() {
        if let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize                 = CGSize(width: type(of: self).starCellWidth,
                                                     height: type(of: self).starCellHeight)
            layout.sectionInset             = .zero
            layout.minimumLineSpacing       = type(of: self).itemSpacing
            layout.minimumInteritemSpacing  = type(of: self).itemSpacing
        }
    }
    
    private static let verticalInset: CGFloat       = 10
    private static let horizontalInset: CGFloat     = 23
    private static let itemSpacing: CGFloat         = 8
    private static let starCellWidth: CGFloat       = (DeviceInfo.screenWidth - (2 * horizontalInset) - (2 * itemSpacing)) / 3
    private static let starCellHeight: CGFloat      = starCellWidth
}
