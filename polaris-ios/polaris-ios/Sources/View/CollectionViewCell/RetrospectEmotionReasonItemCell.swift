//
//  RetrospectEmotionReasonItemCell.swift
//  polaris-ios
//
//  Created by Dongmin on 2022/01/08.
//

import UIKit

class RetrospectEmotionReasonItemCell: UICollectionViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layoutCell()
    }
    
    func configure(reasonText: String) {
        self.reasonLabel.text = reasonText
        self.reasonLabel.sizeToFit()
    }
    
    private func layoutCell() {
        self.reasonLabelWidthConstraint.constant = DeviceInfo.screenWidth - (23 * 2) - (16 * 2) - (20 * 2)
    }

    @IBOutlet private weak var reasonLabel: UILabel!
    @IBOutlet private weak var reasonLabelWidthConstraint: NSLayoutConstraint!
    
}
