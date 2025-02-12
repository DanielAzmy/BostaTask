//
//  APIService.swift
//  BostaTask
//
//  Created by Dodo's Mac on 12/02/2025.
//

import Foundation
import Moya

enum JSONPlaceholderAPI {
    case users
    case albums(userId: Int)
    case photos(albumId: Int)
}

extension JSONPlaceholderAPI: TargetType {
    var baseURL: URL { URL(string: "https://jsonplaceholder.typicode.com")! }
    
    var path: String {
        switch self {
        case .users: return "/users"
        case .albums: return "/albums"
        case .photos: return "/photos"
        }
    }
    
    var method: Moya.Method { .get}
    
    var task: Task {
        switch self {
        case .users:
            return .requestPlain
        case .albums(let userId):
            return .requestParameters(parameters: ["userId": userId], encoding: URLEncoding.default)
        case .photos(let albumId):
            return .requestParameters(parameters: ["albumId": albumId], encoding: URLEncoding.default)
        }
    }
    
    var headers: [String: String]? { nil }
}
protocol CommonTargetType: TargetType{
    
}
extension CommonTargetType{
    var baseURL: URL { URL(string: "https://jsonplaceholder.typicode.com")! }
    var method: Moya.Method { .get}
    var headers: [String: String]? { nil }
    
    
    
}




