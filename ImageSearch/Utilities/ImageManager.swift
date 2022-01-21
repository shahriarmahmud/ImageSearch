//
//  ImageManager.swift
//  ImageSearch
//
//  Created by Shahriar Mahmud on 1/21/22.
//

import Foundation
import UIKit

class ImageManager{
    
    static let shared = ImageManager()
    private init() {}
    
    private let imageCache = NSCache<NSString, UIImage>()
    
    func downloadImageFrom(_ model: SearchImage, size: CGSize, completeHandler: @escaping (UIImage?) -> ()) {
        guard let serverId = model.server else {return}
        guard let photoId = model.id else {return}
        guard let secret = model.secret else {return}
        guard let url = URL(string: Constants.imageURL + "/\(serverId)/\(photoId)_\(secret)_w.jpg") else {completeHandler(nil); return}
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let cachedImage = self.imageCache.object(forKey: photoId as NSString) {
                completeHandler(cachedImage)
                return
            }
            // Recommendation #3: Make image loading asynchronous, moving the work off the main queue.
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let wSelf = self else {
                    completeHandler(nil)
                    return
                }
                
                guard
                    let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                    let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                    let data = data, error == nil,
                    let _image = UIImage(data: data)
                else { completeHandler(nil); return }
                
                // Recommendation #4: After loading an image from disk, resize it appropriately
                let resizedImage = _image.resized(to: size)
                
                wSelf.imageCache.setObject(resizedImage, forKey: photoId as NSString)
                completeHandler(resizedImage)
            }
        }.resume()
    }
}
