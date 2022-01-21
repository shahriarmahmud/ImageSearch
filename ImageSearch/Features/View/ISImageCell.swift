//
//  ISImageCell.swift
//  ImageSearch
//
//  Created by Shahriar Mahmud on 1/20/22.
//

import UIKit

class ISImageCell: UICollectionViewCell {
    static let identifier = "ISImageCell"
    
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var loadingIndicator: UIActivityIndicatorView!
    
    func updateAppearanceFor(_ image: UIImage?) {
        DispatchQueue.main.async { [weak self] in
            guard let wSelf = self else {return}
            wSelf.displayImage(image)
        }
    }
    
    private func displayImage(_ image: UIImage?) {
        if let _image = image {
            imageView.image = _image
            loadingIndicator.stopAnimating()
        } else {
            loadingIndicator.startAnimating()
            imageView.image = UIImage(systemName: "photo")
        }
    }
    
    func getCellImage()-> UIImage?{
        return imageView.image
    }
}
