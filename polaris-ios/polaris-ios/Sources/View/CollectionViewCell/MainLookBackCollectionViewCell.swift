//
//  MainLookBackCollectionViewCell.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2021/06/19.
//

import UIKit

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
    
    private var state: MainLookBackCellState = .lookback
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setUIs()
    }
    
    func setUIs() {
        self.containView.backgroundColor = .white40
        self.containView.makeRounded(cornerRadius: 12)
        self.titleLabel.textColor = .maintext
        self.titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        self.subTitleLabel.textColor = .white
        self.subTitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        self.lookBackButton.backgroundColor = .mainSky
        self.lookBackButton.makeRounded(cornerRadius: 18)
        self.lookBackButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
    }
    
    func setState(state: MainLookBackCellState,bannerTitle: String?, bannerText: String?, buttonText: String?) {
        self.titleLabel.text = bannerTitle ?? ""
        self.subTitleLabel.text = bannerText ?? ""
        self.lookBackButton.setTitle(buttonText ?? "", for: .normal)
        switch state {
        case .build :
            self.closeButton.isHidden = true
            self.titleLabelTopConstraint.constant = 34

        default :
            self.closeButton.isHidden = false
            self.titleLabelTopConstraint.constant = 39

        }
        
        
    }
    
    
    func setTitles(title: String, subTitle: String){
        self.titleLabel.text = title
        self.subTitleLabel.text = subTitle
    }

}
