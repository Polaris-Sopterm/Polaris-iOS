//
//  AddTodoFixOnTopTableViewCell.swift
//  polaris-ios
//
//  Created by USER on 2021/04/18.
//

import UIKit
import RxSwift

protocol AddTodoFixOnTopTableViewCellDelegate: AddTodoTableViewCellDelegate {
    func addTodoFixOnTopTableViewCell(_ addTodoFixOnTopTableViewCell: AddTodoFixOnTopTableViewCell, shouldFixed isFixed: Bool)
}

class AddTodoFixOnTopTableViewCell: AddTodoTableViewCell {
    override class var cellHeight: CGFloat {
        let verticalInset: CGFloat  = 10
        let labelHeight: CGFloat    = 17
        let spacing: CGFloat        = 15
        let buttonHeight: CGFloat   = 61
        return (verticalInset * 2) + labelHeight + spacing + buttonHeight
    }
    
    override weak var delegate: AddTodoTableViewCellDelegate? { didSet { self._delegate = self.delegate as? AddTodoFixOnTopTableViewCellDelegate; self._delegate?.addTodoFixOnTopTableViewCell(self, shouldFixed: false) } }
    weak var _delegate: AddTodoFixOnTopTableViewCellDelegate?
    
    // MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupButtons()
        self.bindButton()
        self.bindUI()
    }
    
    // MARK: - Set Up
    private func setupButtons() {
        self.notFixBackgroundView.makeRounded(cornerRadius: 15)
        self.fixBackgroundView.makeRounded(cornerRadius: 15)
    }
    
    private func setFixSelected() {
        self.fixBackgroundView.layer.borderWidth    = 1
        self.fixBackgroundView.layer.borderColor    = type(of: self).selectedBorderColor.cgColor
        self.fixBackgroundView.backgroundColor      = type(of: self).selectedBackgroundColor
        self.fixImageView.image                     = UIImage(named: ImageName.icnFixed)
        self.fixLabel.textColor                     = type(of: self).selectedBorderColor
        
        self.notFixBackgroundView.layer.borderWidth = 0
        self.notFixBackgroundView.layer.borderColor = UIColor.clear.cgColor
        self.notFixBackgroundView.backgroundColor   = type(of: self).unselectedBackgroundColor
        self.notFixImageView.image                  = UIImage(named: ImageName.icnUnfixedInactive)
        self.notFixLabel.textColor                  = type(of: self).unselectedBorderColor
    }
    
    private func setNotFixSelected() {
        self.notFixBackgroundView.layer.borderWidth = 1
        self.notFixBackgroundView.layer.borderColor = type(of: self).selectedBorderColor.cgColor
        self.notFixBackgroundView.backgroundColor   = type(of: self).selectedBackgroundColor
        self.notFixImageView.image                  = UIImage(named: ImageName.icnUnfixed)
        self.notFixLabel.textColor                  = type(of: self).selectedBorderColor
        
        self.fixBackgroundView.layer.borderWidth    = 0
        self.fixBackgroundView.layer.borderColor    = UIColor.clear.cgColor
        self.fixBackgroundView.backgroundColor      = type(of: self).unselectedBackgroundColor
        self.fixImageView.image                     = UIImage(named: ImageName.icnFixedInactive)
        self.fixLabel.textColor                     = type(of: self).unselectedBorderColor
    }
    
    // MARK: - Bind
    private func bindButton() {
        self.fixButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.fixed.onNext(true)
            })
            .disposed(by: self.disposeBag)
        
        self.notFixButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.fixed.onNext(false)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func bindUI() {
        self.fixed.distinctUntilChanged()
            .subscribe(onNext: { [weak self] isFixed in
                guard let self = self else { return }
                
                if isFixed == true  { self.setFixSelected() }
                else                { self.setNotFixSelected() }
                
                self._delegate?.addTodoFixOnTopTableViewCell(self, shouldFixed: isFixed)
            })
            .disposed(by: self.disposeBag)
    }
    
    private static let selectedBackgroundColor: UIColor     = UIColor.inactiveSky
    private static let unselectedBackgroundColor: UIColor   = UIColor.field
    
    private static let selectedBorderColor: UIColor         = UIColor.mainSky
    private static let unselectedBorderColor: UIColor       = UIColor.inactiveText
    
    private var disposeBag = DisposeBag()
    private var fixed      = BehaviorSubject<Bool>(value: false)
    
    @IBOutlet private weak var notFixBackgroundView: UIView!
    @IBOutlet private weak var notFixButton: UIButton!
    @IBOutlet private weak var notFixImageView: UIImageView!
    @IBOutlet private weak var notFixLabel: UILabel!
    @IBOutlet private weak var fixBackgroundView: UIView!
    @IBOutlet private weak var fixButton: UIButton!
    @IBOutlet private weak var fixImageView: UIImageView!
    @IBOutlet private weak var fixLabel: UILabel!
    
}
