//
//  LookBackSecondCollectionViewCell.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2022/01/01.
//

import UIKit

enum LookBackStarViewControllerCase: Int {
    case second
    case sixth
}

class LookBackSecondCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var starImageView: UIImageView!
    @IBOutlet weak var starNameLabel: UILabel!
        
    private var viewModel: LookBackViewModel?
    private var lookBackStarViewControllerCase: LookBackStarViewControllerCase?
    private var star: LookBackStar? {
        didSet {
            guard let star = self.star else { return }
            self.starImageView.image = UIImage(named: star.starImageName)
            self.starNameLabel.text = star.starName
            if star.selected {
                self.backgroundImage.image = UIImage(named: "rectangleSelected")
            }
            else {
                self.backgroundImage.image = UIImage(named: "rectangleUnselected")
            }
        }
    }
    private var index: Int?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setLabel()
        self.backgroundImage.image = UIImage(named: "rectangleUnselected")
        self.addTapGestureRecognizer()
    }
    
    func setLabel() {
        self.starNameLabel.textColor = .white
        self.starNameLabel.font = UIFont.systemFont(ofSize: 13)
    }
    
    func setStar(star: LookBackStar, index: Int) {
        self.star = star
        self.index = index
    }
    
    func setViewModel(viewModel: LookBackViewModel) {
        self.viewModel = viewModel
    }
    
    func setViewControllerCase(input: LookBackStarViewControllerCase) {
        self.lookBackStarViewControllerCase = input
    }
    
    private func addTapGestureRecognizer() {
        self.isUserInteractionEnabled = true
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(setSelected))
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc func setSelected() {
        guard let index = self.index,
              let vcCase = self.lookBackStarViewControllerCase
        else { return }
        switch vcCase {
        case .second:
            self.viewModel?.setStarSelectedSecondVC(index: index)
        case .sixth:
            self.viewModel?.setStarSelectedSixthVC(index: index)
        }
    }
}
