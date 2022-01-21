//
//  ImageResponse.swift
//  ImageSearch
//
//  Created by Shahriar Mahmud on 1/20/22.
//

import Foundation

struct ImageResponse: Decodable, CustomStringConvertible {
    var description: String{
        return ""
    }
    
    @NestedKey
    var total: Int?
    @NestedKey
    var photos: [SearchImage]?
    

    enum CodingKeys: String, NestableCodingKey {
        case total  = "photos/total"
        case photos = "photos/photo"
        
    }
}


struct SearchImage: Decodable, CustomStringConvertible {
    var description: String{
        return ""
    }
    
    var id: String?
    var owner: String?
    var secret: String?
    var server: String?
    var farm: Int?
    var title: String?
    var ispublic: Int?
    var isfriend: Int?
    var isfamily: Int?
    

    enum CodingKeys: String, NestableCodingKey {
        case id
        case owner
        case secret
        case server
        case farm
        case title
        case ispublic
        case isfriend
        case isfamily
    }
}
