//
//  JourneyTodoTableViewCell.swift
//  polaris-ios
//
//  Created by USER on 2021/05/16.
//

import RxCocoa
import RxSwift
import UIKit

protocol JourneyTodoTableViewCellDelegate: AnyObject {
    #warning("나중에 들어갈 ID 또는 check 플래그 필요")
    func journeyTodoTableViewCell(_ journeyTodoTableViewCell: JourneyTodoTableViewCell, didTapCheck todo: String)
}

class JourneyTodoTableViewCell: UITableViewCell {
    
    static var cellHeight: CGFloat { return 63 * screenRatio }
    
    weak var delegate: JourneyTodoTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.bindCheckButton()
    }
    
    func configure() {
        
    }
    
    func updateUI(as checkState: Bool) {
        let checkImage: UIImage?   = #imageLiteral(resourceName: "btnCheck")
        let uncheckImage: UIImage? = #imageLiteral(resourceName: "btnUncheck")
        
        let checkTextColor: UIColor   = .inactiveTextPurple
        let uncheckTextColor: UIColor = .maintext
        
        if checkState == true {
            self.titleLabel.textColor    = checkTextColor
            self.subTitleLabel.textColor = checkTextColor
            self.fixImageView.alpha      = 0.5
            self.checkButton.setImage(checkImage, for: .normal)
        } else {
            self.titleLabel.textColor    = uncheckTextColor
            self.subTitleLabel.textColor = uncheckTextColor
            self.fixImageView.alpha      = 1
            self.checkButton.setImage(uncheckImage, for: .normal)
        }
    }
    
    private func bindCheckButton() {
        self.checkButton.rx.tap
            .throttle(.milliseconds(500), latest: false, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                self.delegate?.journeyTodoTableViewCell(self, didTapCheck: "")
            })
            .disposed(by: self.disposeBag)
    }
    
    private static let screenRatio: CGFloat = DeviceInfo.screenWidth / 375
    
    private var disposeBag = DisposeBag()
    
    @IBOutlet private weak var fixImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subTitleLabel: UILabel!
    @IBOutlet private weak var checkButton: UIButton!
    
}
