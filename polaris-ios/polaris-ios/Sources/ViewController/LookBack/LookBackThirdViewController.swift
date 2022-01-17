//
//  LookBackThirdViewController.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2022/01/01.
//

import UIKit
import SnapKit
import Combine

class LookBackThirdViewController: UIViewController, LookBackViewModelProtocol{

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    
    @IBOutlet weak var titleLabelYPos: NSLayoutConstraint!
    @IBOutlet weak var imageViewYPos: NSLayoutConstraint!
    @IBOutlet weak var buttonYPos: NSLayoutConstraint!
    
    private let slider = LookBackSlider()
    private let amountLabel = UILabel()
    private var questionNo = 0
    private let deviceHeightRatio = DeviceInfo.screenHeight/812.0
    private var viewModel = LookBackViewModel()
    
    private weak var pageDelegate: LookBackPageDelegate?

    
    private var backgroundImageNameSubscription: AnyCancellable?
    private var titleLabelSubscription: AnyCancellable?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUIs()
        self.bindViewModel()
        // Do any additional setup after loading the view.
    }
    
    private func setUIs() {
        self.titleLabel.textColor = .maintext
        self.titleLabel.setPartialBold(originalText: "한 주 동안 당신만을 위한 시간을\n얼마나 보냈나요?", boldText: "당신만을 위한 시간", fontSize: 22, boldFontSize: 22)
        self.subTitleLabel.textColor = .maintext

        self.nextButton.setTitle("", for: .normal)
        self.nextButton.setImage(UIImage(named: "btnNextEnabled"), for: .normal)
        
        self.view.addSubview(self.slider)
        self.slider.isUserInteractionEnabled = true
        self.slider.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(510 * deviceHeightRatio)
            make.leading.equalToSuperview().offset(53)
            make.trailing.equalToSuperview().offset(-53)
            make.height.equalTo(40 * deviceHeightRatio)
        }
        
  
        self.slider.value = 0
        self.slider.addTarget(self, action: #selector(sliderValueChanged(sender:)), for: .valueChanged)
        self.slider.viewModel = self.viewModel
        
        self.backgroundImageView.image = UIImage(named: "lookBack3Illust00")
        
        self.view.addSubview(self.amountLabel)
        self.amountLabel.text = ""
        self.amountLabel.textColor = .white
        self.amountLabel.font = UIFont.systemFont(ofSize: 12)
        
        
        self.titleLabelYPos.constant *= self.deviceHeightRatio
        self.imageViewYPos.constant *= self.deviceHeightRatio
        self.buttonYPos.constant *= self.deviceHeightRatio
    }
    
    private func bindViewModel() {
        self.backgroundImageNameSubscription = self.viewModel.$thirdvcImageNameInfo
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] value in
                guard !value.isEmpty else { return }
                guard let self = self else { return }
                UIView.transition(with: self.backgroundImageView, duration: 0.2, options: .transitionCrossDissolve, animations: {
                    self.backgroundImageView.image = UIImage(named: value.last ?? "")
                }, completion: nil)
            })
        
        self.titleLabelSubscription = self.viewModel.$thirdvcTitle
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] value in
                guard let self = self else { return }
                UIView.transition(with: self.titleLabel, duration: 0.2, options: .transitionCrossDissolve, animations: {
                    self.titleLabel.setPartialBold(originalText: value.text, boldText: value.highlightedText, fontSize: 22, boldFontSize: 22)
                }, completion: nil)
                
            })
        
    }
    
    func setViewModel(viewModel: LookBackViewModel) {
        self.viewModel = viewModel
    }
    
    @objc func sliderValueChanged(sender: UISlider!) {
        switch round(sender.value) {
        case 1:
            self.slider.value = 1
            self.slider.setMinimumTrackImage(UIImage(named: "sliderFilled1"), for: .normal)
            self.viewModel.thirdvcAnswerChange(value: 1)
            self.amountLabel.text = "조금"
        case 2:
            self.slider.value = 2
            self.slider.setMinimumTrackImage(UIImage(named: "sliderFilled2"), for: .normal)
            self.viewModel.thirdvcAnswerChange(value: 2)
            self.amountLabel.text = "그럭저럭"
        case 3:
            self.slider.value = 3
            self.slider.setMinimumTrackImage(UIImage(named: "sliderFilled3"), for: .normal)
            self.viewModel.thirdvcAnswerChange(value: 3)
            self.amountLabel.text = "많이"
        case 4:
            self.slider.value = 4
            self.slider.setMinimumTrackImage(UIImage(named: "sliderFilled4"), for: .normal)
            self.viewModel.thirdvcAnswerChange(value: 4)
            self.amountLabel.text = "아주 많이"
        default:
            self.slider.value = 0
            self.viewModel.thirdvcAnswerChange(value: 0)
            self.amountLabel.text = ""
        }
        
        let sliderLength = Float(DeviceInfo.screenWidth - 106)
        self.amountLabel.snp.remakeConstraints { make in
            make.bottom.equalTo(self.slider.snp.top).offset(-27)
            make.centerX.equalTo(self.view.snp.leading).offset(53 + sender.value * Float(sliderLength / 4.0))
        }
    }
    
    
    private func makeBackgroundImageName(value: Int) -> String {
        return "lookBack3Illust" + String(self.questionNo) + String(value)
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
        self.viewModel.thirdvcNextButtonTapped()
        self.slider.value = 0
        self.amountLabel.text = ""
    }
    
    func setPageDelegate(delegate: LookBackPageDelegate) {
        self.pageDelegate = delegate
    }

}
