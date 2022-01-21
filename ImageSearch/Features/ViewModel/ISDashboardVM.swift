//
//  ISDashboardVM.swift
//  ImageSearch
//
//  Created by Shahriar Mahmud on 1/20/22.
//

import Foundation

class ISDashboardVM{
    var photosList: [SearchImage]?
    
    func getSearchImage(searchTxt: String, page: Int, completion: @escaping (_ success: Bool) -> Void){
        var url = ""
        if searchTxt.isEmpty{
            url = KBasePath + OauthPath.getSearchImage.rawValue + "&api_key=\(Constants.API_KEY)&text=\(searchTxt)&page=\(page)&lat=37.7994&lon=122.3950"
        }else{
            url = KBasePath + OauthPath.getSearchImage.rawValue + "&api_key=\(Constants.API_KEY)&text=\(searchTxt)&page=\(page)"
        }
        
        APIClient.shared.objectAPICall(url: url, modelType: ImageResponse.self, method: .get, parameters: [String: Any]()) { (response) in
            switch response {
            case .success(let value):
                if page == 1{
                    self.photosList = value.photos
                }else{
                    var temp: [SearchImage] = []
                    temp = self.photosList ?? []
                    temp.append(contentsOf: value.photos ?? [])
                    self.photosList = temp
                }
                completion(true)
            case .failure((let code, let data, let err)):
                debugPrint("code = \(code)")
                debugPrint("data = \(String(describing: data))")
                debugPrint("error = \(err.localizedDescription)")
                completion(false)
            }
        }
    }
    
    func getImageURL(index: Int)-> String{
        guard let serverId = photosList?[index].server else {return ""}
        guard let photoId = photosList?[index].id else {return ""}
        guard let secret = photosList?[index].secret else {return ""}
        return Constants.imageURL + "/\(serverId)/\(photoId)_\(secret)_w.jpg"
    }
    
    public func loadImage(at index: Int, size: CFloat) -> DataLoadOperation? {
        guard let images = photosList else {return nil}
        if (0..<images.count).contains(index) {
            return DataLoadOperation(images[index], size: size)
        }
        return .none
    }
}
