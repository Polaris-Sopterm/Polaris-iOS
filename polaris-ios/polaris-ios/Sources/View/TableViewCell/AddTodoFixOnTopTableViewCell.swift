//
//  AddTodoFixOnTopTableViewCell.swift
//  polaris-ios
//
//  Created by USER on 2021/04/18.
//

import UIKit
import RxSwift

class AddTodoFixOnTopTableViewCell: AddTodoTableViewCell {
    override class var cellHeight: CGFloat {
        let verticalInset: CGFloat  = 10
        let labelHeight: CGFloat    = 17
        let spacing: CGFloat        = 15
        let buttonHeight: CGFloat   = 61
        return (verticalInset * 2) + labelHeight + spacing + buttonHeight
    }
    
    @IBOutlet weak var notFixBackgroundView: UIView!
    @IBOutlet weak var notFixButton: UIButton!
    @IBOutlet weak var notFixImageView: UIImageView!
    @IBOutlet weak var notFixLabel: UILabel!
    @IBOutlet weak var fixBackgroundView: UIView!
    @IBOutlet weak var fixButton: UIButton!
    @IBOutlet weak var fixImageView: UIImageView!
    @IBOutlet weak var fixLabel: UILabel!
    
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
            })
            .disposed(by: self.disposeBag)
    }
    
    private var fixed = BehaviorSubject<Bool?>(value: nil)
    
    static var selectedBackgroundColor: UIColor     = UIColor.inactiveSky
    static var unselectedBackgroundColor: UIColor   = UIColor.field
    
    static var selectedBorderColor: UIColor         = UIColor.mainSky
    static var unselectedBorderColor: UIColor       = UIColor.inactiveText
    
    var disposeBag = DisposeBag()
}
