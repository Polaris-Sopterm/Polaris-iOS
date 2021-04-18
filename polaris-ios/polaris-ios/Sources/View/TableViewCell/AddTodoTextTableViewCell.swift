//
//  AddTodoTextTableViewCell.swift
//  polaris-ios
//
//  Created by USER on 2021/04/17.
//

import UIKit
import RxSwift
import RxCocoa

class AddTodoTextTableViewCell: AddTodoTableViewCell {
    class override var cellHeight: CGFloat {
        let textFieldHeight: CGFloat = (screenRaito * 53)
        let space: CGFloat           = 15
        return (verticalInset * 2) + space + textFieldHeight
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textFieldContainerView: UIView!
    var polarisMarginTextFieldView: PolarisMarginTextField? = UIView.fromNib()
    
    // MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupTextFieldView()
    }
    
    private func setupTextFieldView() {
        guard let polarisMarginTextFieldView = self.polarisMarginTextFieldView else { return }
        self.textFieldContainerView.addSubview(polarisMarginTextFieldView)
    }
    
    static let screenRaito: CGFloat         = DeviceInfo.screenWidth / 375
    static let verticalInset: CGFloat       = 10
}
