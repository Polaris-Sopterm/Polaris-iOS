//
//  PolarisMakerCollectionViewCell.swift
//  polaris-ios
//
//  Created by Dongmin on 2021/09/04.
//

import RxCocoa
import RxSwift
import UIKit

class PolarisMakerCollectionViewCell: UICollectionViewCell {
    
    func configure(_ maker: PolarisMaker) {
        self.titleLabel.text = maker.title
        self.imageView.image = maker.image
    }
    
    private let disposeBag = DisposeBag()

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    
}
