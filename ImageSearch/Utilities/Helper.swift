//
//  Helper.swift
//  ImageSearch
//
//  Created by Shahriar Mahmud on 1/20/22.
//


import UIKit

struct Helper{
            
    static func emptyMessageInCollectionView(_ collectionView: UICollectionView,_ title: String){
        let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height))
        noDataLabel.textColor        = .lightGray
        noDataLabel.font             = UIFont(name: "Open Sans", size: 15)
        noDataLabel.textAlignment    = .center
        collectionView.backgroundView = noDataLabel
        noDataLabel.text = title
    }
}

class DataLoadOperation: Operation {
    var image: UIImage?
    var loadingCompleteHandler: ((UIImage?) -> ())?
    private var _image: SearchImage
    private var _size: CGSize
    
    init(_ image: SearchImage, size: CFloat) {
        _image = image
        _size = CGSize(width: CGFloat(size), height: CGFloat(size))
    }
    
    override func main() {
        if isCancelled { return }
        ImageManager.shared.downloadImageFrom(_image, size: _size) { (image) in
            DispatchQueue.main.async() { [weak self] in
                guard let `self` = self else { return }
                if self.isCancelled { return }
                self.image = image
                self.loadingCompleteHandler?(self.image)
            }
        }
    }
}
