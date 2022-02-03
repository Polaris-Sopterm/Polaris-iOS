//
//  UIImage+.swift
//  polaris-ios
//
//  Created by Dongmin on 2022/01/23.
//

import UIKit

extension UIImage {
    
    func cropImage(rect: CGRect) -> UIImage? {
        guard let cgImageFromSourceImage = self.cgImage                      else { return nil }
        guard let croppedCGImage = cgImageFromSourceImage.cropping(to: rect) else { return nil }
        return UIImage(
            cgImage: croppedCGImage,
            scale: UIScreen.main.scale,
            orientation: self.imageOrientation
        )
    }
    
}
