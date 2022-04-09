//
//  JourneyCollectionViewCell.swift
//  polaris-ios
//
//  Created by Dongmin on 2022/04/09.
//

import Kingfisher
import SnapKit
import UIKit

class JourneyCollectionViewCell: UICollectionViewCell {
    
    private(set) var journey: Journey?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupStackView()
        self.setupJourneyImageView()
        self.setupJourneyLabel()
        self.layoutUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.journey = nil
        self.journeyImageView.kf.cancelDownloadTask()
        self.journeyImageView.image = nil
    }
    
    func configure(journey: Journey) {
        self.journey = journey
        self.journeyImageView.image = journey.getImage()
        self.journeyLabel.text = journey.rawValue
    }
    
    func updateJourneyImage(size: CGFloat, journeyLevel: Int) {
        self.journeyImageView.image = self.journey?.getImage(by: journeyLevel)
        self.journeyImageView.snp.remakeConstraints { make in
            make.size.equalTo(size)
        }
    }
    
    private func setupStackView() {
        self.stackView.alignment = .center
        self.stackView.distribution = .fill
        self.stackView.axis = .vertical
        self.stackView.spacing = 0
        self.contentView.addSubview(self.stackView)
    }
    
    private func setupJourneyLabel() {
        self.journeyLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        self.journeyLabel.textColor = .white
        self.journeyLabel.textAlignment = .center
        self.stackView.addArrangedSubview(self.journeyLabel)
    }
    
    private func setupJourneyImageView() {
        self.journeyImageView.contentMode = .scaleAspectFit
        self.stackView.addArrangedSubview(self.journeyImageView)
    }
    
    private func layoutUI() {
        self.stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.journeyImageView.snp.makeConstraints { make in
            make.size.equalTo(61)
        }
    }
    
    private let stackView = UIStackView(frame: .zero)
    private let journeyImageView = UIImageView(frame: .zero)
    private let journeyLabel = UILabel(frame: .zero)
    
}
