//
// APIClient.swift
//  ImageSearch
//
//  Created by Shahriar Mahmud on 1/20/22.
//


import Foundation
import UIKit

public enum Result<T> {
    case success(T)
    case failure(ErrorResponse)
}

typealias CompletionHandler<T> = (Result<T>) -> ()
public typealias ErrorResponse = (Int, Data?, Error)

class APIClient{
    private static var privateShared : APIClient?

    class var shared: APIClient {
        guard let uwShared = privateShared else {
            privateShared = APIClient()
            return privateShared!
        }
        return uwShared
    }

    class func destroy() {
        privateShared = nil
    }

    private init() {}

    deinit {
        debugPrint("deinit singleton")
    }
    
    
    func objectAPICall<T: Decodable>(url: String, modelType: T.Type, method: method, parameters: [String: Any], completion: @escaping CompletionHandler<T>){
        
        let url = URL(string: url)!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = method.rawValue
        
        request.httpBody = parameters.percentEncoded()

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                  let dataResponse = response as? HTTPURLResponse,
                error == nil else {
                    debugPrint("error: \(error?.localizedDescription ?? "Unknown error")")
                    let mError = ErrorResponse(404, nil, error!)
                    completion(Result.failure(mError))
                    return
                }

            do {
                let res = try JSONDecoder().decode(modelType, from: data)
                DispatchQueue.main.async {
                    completion(Result.success(res))
                }
            } catch let error {
                let mError = ErrorResponse(dataResponse.statusCode, Data(), error)
                debugPrint(error)
                completion(Result.failure(mError))
            }
        }

        task.resume()
    }
}


enum method: String{
    case get = "GET"
    case post = "POST"
}

extension Dictionary {
    func percentEncoded() -> Data? {
        return map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}
