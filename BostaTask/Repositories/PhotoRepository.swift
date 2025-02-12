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
    func fetchPhotos(albumId: Int) -> AnyPublisher<[Album], Error>
}

class PhotoRepository: PhotosRepositoryType, RepositoryCommon{
    let provider = MoyaProvider<JSONPlaceholderAPI>()
    
    func fetchPhotos(albumId: Int) -> AnyPublisher<[Album], Error> {
        return request(.photos(albumId: albumId),decodeTo: [Album].self)
    }
}
