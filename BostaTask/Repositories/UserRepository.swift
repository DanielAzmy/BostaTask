//
//  UserRepository.swift
//  BostaTask
//
//  Created by Dodo's Mac on 12/02/2025.
//

import Foundation
import Combine
import Moya


protocol UserRepositoryType: RepositoryType{
    func fetchUsers() -> AnyPublisher<[User], Error>
    func fetchAlbums(userId: Int) -> AnyPublisher<[Album], Error>
}


class UserRepository: UserRepositoryType, RepositoryCommon {
    let provider = MoyaProvider<JSONPlaceholderAPI>()
    
    func fetchUsers() -> AnyPublisher<[User], Error> {
        return request(.users, decodeTo: [User].self)
    }
    
    func fetchAlbums(userId: Int) -> AnyPublisher<[Album], Error> {
        return request(.albums(userId: userId), decodeTo: [Album].self)
    }
}

