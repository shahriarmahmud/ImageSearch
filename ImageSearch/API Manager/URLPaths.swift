//
//  URLPaths.swift
//  ImageSearch
//
//  Created by Shahriar Mahmud on 1/20/22.
//


import Foundation



#if DEVELOPMENT
let KBasePath = "https://api.flickr.com/services/rest/"
#else
let KBasePath = "https://api.flickr.com/services/rest/"
#endif

enum OauthPath: String {
    case getSearchImage   = "?method=flickr.photos.search&format=json&nojsoncallback=1"
}
