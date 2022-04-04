//
//  AddTodoDayTableViewCell.swift
//  polaris-ios
//
//  Created by USER on 2021/04/21.
//

import UIKit
import RxSwift

protocol AddTodoDayTableViewCellDelegate: AddTodoTableViewCellDelegate {
    func addTodoDayTableViewCell(_ addTodoDayTableViewCell: AddTodoDayTableViewCell, didSelectDate date: Date)
}

class AddTodoDayTableViewCell: AddTodoTableViewCell {
    
    override class var cellHeight: CGFloat {
        let labelHeight: CGFloat = 17
        let spacing: CGFloat     = 15
        return (verticalInset * 2) + dayCellHeight + spacing + labelHeight
    }
    
    override weak var delegate: AddTodoTableViewCellDelegate? {
        didSet { self._delegate = delegate as? AddTodoDayTableViewCellDelegate }
    }
    
    // MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.registerCell()
        self.layoutColletionView()
        self.bindCollectionView()
    }
    
    override func configure(by addMode: AddTodoVC.AddMode, date: Date? = nil) {
        super.configure(by: addMode, date: date)
        
        switch addMode {
        case .editTodo(let todo):
            self.viewModel.occur(viewEvent: .configureForEdit(todo))
            
        default:
            break
        }
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
        self.viewModel.datesObservable.bind(to: self.collectionView.rx.items) { collectionView, index, item in
            let indexPath = IndexPath(item: index, section: 0)
            let cell = collectionView.dequeueReusableCell(
                cell: PerDayItemCollectionViewCell.self,
                forIndexPath: indexPath
            )
            
            guard let perDayCell = cell else { return UICollectionViewCell() }
            perDayCell.configure(item)
            return perDayCell
        }.disposed(by: self.disposeBag)
        
        self.viewModel.selectedDateObservable
            .withUnretained(self)
            .observeOnMain(onNext: { owner, selectedDate in
                guard let selectedDate = selectedDate else { return }
                
                owner.updateSelectedDateCell(selectedDate)
                owner._delegate?.addTodoDayTableViewCell(owner, didSelectDate: selectedDate)
            })
            .disposed(by: self.disposeBag)
        
        self.collectionView.rx.itemSelected
            .withUnretained(self)
            .subscribe(onNext: { owner, indexPath in
                owner.viewModel.occur(viewEvent: .selectCollectionView(indexPath: indexPath))
            })
            .disposed(by: self.disposeBag)
    }
    
    private func updateSelectedDateCell(_ selectedDate: Date) {
        guard let selectedIndex = self.viewModel.dates.firstIndex(of: selectedDate) else { return }
        
        let selectedIndexPath = IndexPath(item: selectedIndex, section: 0)
        self.collectionView.selectItem(at: selectedIndexPath, animated: false, scrollPosition: [])
    }
    
    private weak var _delegate: AddTodoDayTableViewCellDelegate?
    
    private static let horizontalInset: CGFloat     = 23
    private static let verticalInset: CGFloat       = 10
    private static let screenRatio: CGFloat         = DeviceInfo.screenWidth / 375
    private static let dayCellHeight: CGFloat       = 66 * screenRatio
    private static let dayCellWidth: CGFloat        = (DeviceInfo.screenWidth - (2 * horizontalInset) - (6 * 2)) / 7
    
    private var viewModel  = AddTodoDayViewModel()
    private var disposeBag = DisposeBag()
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
}
