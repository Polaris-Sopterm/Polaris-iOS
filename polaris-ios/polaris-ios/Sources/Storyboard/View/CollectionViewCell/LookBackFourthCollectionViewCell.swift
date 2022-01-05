//
//  LookBackFourthCollectionViewCell.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2022/01/02.
//

import UIKit

class LookBackFourthCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var emotionImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    private var emotion: LookBackEmotion? {
        didSet {
            guard let emotion = self.emotion else { return }
            self.emotionImageView.image = UIImage(named: emotion.emotionImageName)
            self.titleLabel.text = emotion.emotion
            if emotion.isSelected {
                self.backgroundImageView.image = UIImage(named: "rectangleSelected")
                self.titleLabel.textColor = .white
            }
            else {
                self.backgroundImageView.image = UIImage(named: "rectangleUnselected")
                self.titleLabel.textColor = .white30
            }
        }
    }
    private var viewModel: LookBackViewModel?
    private var index: Int?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setLabel()
        self.addTapGestureRecognizer()
    }

    func setLabel() {
        self.titleLabel.textColor = .white30
        self.titleLabel.font = UIFont.systemFont(ofSize: 13)
    }
    
    func setEmotion(emotion: LookBackEmotion, index: Int) {
        self.emotion = emotion
        self.index = index
    }
    
    func setViewModel(viewModel: LookBackViewModel) {
        self.viewModel = viewModel
    }
    
    private func addTapGestureRecognizer() {
        self.isUserInteractionEnabled = true
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(setSelected))
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc func setSelected() {
        guard let index = self.index else { return }
        self.viewModel?.setEmotionSelectedFourthVC(index: index)
    }
}
