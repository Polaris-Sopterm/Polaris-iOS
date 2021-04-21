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
        self.layoutColletionView()
    }
    
    // MARK: - Set Up
    private func layoutColletionView() {
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize                 = CGSize(width:  type(of: self).dayCellWidth,
                                                     height: type(of: self).dayCellHeight)
            layout.sectionInset             = .zero
            layout.minimumLineSpacing       = 2
            layout.minimumInteritemSpacing  = 0
        }
    }
    
    
    private static let horizontalInset: CGFloat     = 23
    private static let verticalInset: CGFloat       = 10
    private static let screenRatio: CGFloat         = DeviceInfo.screenWidth / 375
    private static let dayCellHeight: CGFloat       = 66 * screenRatio
    private static let dayCellWidth: CGFloat        = (DeviceInfo.screenWidth - (2 * horizontalInset) - (6 * 2)) / 7
    
    var viewModel  = AddTodoDayViewModel()
    var disposeBag = DisposeBag()
}
