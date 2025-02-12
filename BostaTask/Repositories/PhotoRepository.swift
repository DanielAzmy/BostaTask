//
//  PhotoRepository.swift
//  BostaTask
//
//  Created by Dodo's Mac on 12/02/2025.
//

import Foundation
import Moya
import Combine

protocol PhotosRepositoryType: RepositoryType{
    func fetchAlbum() -> AnyPublisher<[Album], Error>
}

class PhotoRepository: PhotosRepositoryType, RepositoryCommon{
    let provider = MoyaProvider<JSONPlaceholderAPI>()
    
    func fetchAlbum() -> AnyPublisher<[Album], Error> {
        return request(.users, decodeTo: [Album].self)
    }
}
