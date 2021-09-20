//
//  MainLookBackCollectionViewCell.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2021/06/19.
//

import UIKit
import RxCocoa
import RxSwift

enum MainLookBackCellState {
    case build
    case lookback
    case rest
}


class MainLookBackCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var containView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var lookBackButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var titleLabelTopConstraint: NSLayoutConstraint!
    
    
    @IBOutlet var yDiffConstraints: [NSLayoutConstraint]!
    @IBOutlet var heightConstraints: [NSLayoutConstraint]!
    
    
    private var state: MainLookBackCellState = .lookback
    internal var delegate: LookBackCloseDelegate?
    private let deviceRatio = DeviceInfo.screenHeight/812.0
    private let deviceRatioSquare = DeviceInfo.screenHeight/812.0*DeviceInfo.screenHeight/812.0*DeviceInfo.screenHeight/812.0*DeviceInfo.screenHeight/812.0
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setUIs()
    }
    
    func setUIs() {
        self.containView.backgroundColor = .white40
        self.containView.makeRounded(cornerRadius: 12*deviceRatio)
        self.titleLabel.textColor = .maintext
        self.titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        self.subTitleLabel.textColor = .white
        self.subTitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        self.lookBackButton.backgroundColor = .mainSky
        self.lookBackButton.makeRounded(cornerRadius: 18)
        self.lookBackButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        for constraint in self.yDiffConstraints {
            constraint.constant *= self.deviceRatioSquare
        }
        for constraint in self.heightConstraints {
            constraint.constant *= self.deviceRatio
        }
    }
    
    func setState(state: MainLookBackCellState, bannerTitle: String?, bannerText: String?, buttonText: String?) {
        self.titleLabel.text = bannerTitle ?? ""
        self.subTitleLabel.text = bannerText ?? ""
        self.lookBackButton.setTitle(buttonText ?? "", for: .normal)
        switch state {
        case .build :
            self.closeButton.isHidden = true
            self.titleLabelTopConstraint.constant = 34*self.deviceRatio
        default :
            self.closeButton.isHidden = false
            self.titleLabelTopConstraint.constant = 39*self.deviceRatio
        }
    }
    
    func setTitles(title: String, boldText: String, subTitle: String){
        self.titleLabel.setPartialBold(originalText: title, boldText: boldText, fontSize: 16.0, boldFontSize: 16.0)
        self.subTitleLabel.text = subTitle
    }
    
    @IBAction func closeButtonAction(_ sender: Any) {
        self.delegate?.close()
    }
    
    @IBAction func lookBackButtonAction(_ sender: Any) {
        self.delegate?.apply(isLookBack: self.lookBackButton.titleLabel?.text == "여정 돌아보기")
    }
    
}

protocol LookBackCloseDelegate {
    func close()
    func apply(isLookBack: Bool)
}
