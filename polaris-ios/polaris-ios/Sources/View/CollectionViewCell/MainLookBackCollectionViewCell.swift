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
    
    var state: MainLookBackCellState = .lookback
    
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
    
    func setState(state: MainLookBackCellState) {
        switch state {
        case .build :
            self.titleLabel.text = "폴라리스와 함께하는 일주일"
            self.subTitleLabel.text = """
                다음주의 여정을 세워보고
                이번엔 어떤 별을 찾을지 생각해보세요.
                """
            self.closeButton.isHidden = true
            self.titleLabelTopConstraint.constant = 34
            self.lookBackButton.setTitle("여정 세우기", for: .normal)
            
            
        case .lookback :
            self.titleLabel.text = "여정을 돌아볼 시간이에요."
            self.subTitleLabel.text = """
                이번주의 여정을 돌아보면서
                어떤 일주일을 보냈는지 되돌아보세요.
                """
            self.closeButton.isHidden = false
            self.titleLabelTopConstraint.constant = 39
            self.lookBackButton.setTitle("여정 돌아보기", for: .normal)
            
        case .rest :
            self.titleLabel.text = "쉬어간 여정을 돌아보는 의미"
            self.subTitleLabel.text = """
                쉬는 것은 써버린 시간이 아니라
                더 나은 다음주를 위한 도움닫기니까요.
                """
            self.closeButton.isHidden = false
            self.titleLabelTopConstraint.constant = 39
            self.lookBackButton.setTitle("여정 돌아보기", for: .normal)
        }
        
        
    }
    
    
    func setTitles(title: String, subTitle: String){
        self.titleLabel.text = title
        self.subTitleLabel.text = subTitle
    }

}
