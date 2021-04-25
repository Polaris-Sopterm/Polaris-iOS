//
//  PolarisToastView.swift
//  polaris-ios
//
//  Created by USER on 2021/04/25.
//

import UIKit

class PolarisToastView: UIView {
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var toastLabel: UILabel!
    
    // MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundView.makeRounded(cornerRadius: 17)
    }
}
