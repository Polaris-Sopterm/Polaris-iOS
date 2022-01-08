//
//  RetrospectEmotionItemCell.swift
//  polaris-ios
//
//  Created by Dongmin on 2022/01/08.
//

import UIKit

class RetrospectEmotionItemCell: UICollectionViewCell {
    
    static var cellSize: CGSize { CGSize(width: 74, height: 74) }
    
    func configure(emotion: Emotion) {
        self.emotionLabel.text = emotion.name
        self.emotionImageView.image = emotion.image
    }
    
    @IBOutlet private weak var emotionImageView: UIImageView!
    @IBOutlet private weak var emotionLabel: UILabel!
    
}
