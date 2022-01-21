//
//  UIImageView+Helper.swift
//  ImageSearch
//
//  Created by Shahriar Mahmud on 1/20/22.
//


import Foundation
import UIKit

extension UIImage {
    func resized(to targetSize: CGSize) -> UIImage {
        let widthRatio  = (targetSize.width  / size.width)
        let heightRatio = (targetSize.height / size.height)
        let effectiveRatio = max(widthRatio, heightRatio)
        let newSize = CGSize(width: size.width * effectiveRatio, height: size.height * effectiveRatio)
        let rect = CGRect(origin: .zero, size: newSize)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
