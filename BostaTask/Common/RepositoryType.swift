//
//  RepositoryType.swift
//  BostaTask
//
//  Created by Dodo's Mac on 12/02/2025.
//

import Foundation
import Moya
import Combine

protocol RepositoryType {}
protocol RepositoryCommon: RepositoryType {
    var provider: MoyaProvider<JSONPlaceholderAPI> { get }
    func request<T: Decodable>(_ target: JSONPlaceholderAPI, decodeTo type: T.Type) -> AnyPublisher<T, Error>

}
extension RepositoryCommon{
    func request<T: Decodable>(_ target: JSONPlaceholderAPI, decodeTo type: T.Type) -> AnyPublisher<T, Error> {
        return Future<T, Error> { promise in
            self.provider.request(target) { result in
                switch result {
                case .success(let response):
                    do {
                        let decodedData = try JSONDecoder().decode(T.self, from: response.data)
                        promise(.success(decodedData))
                    } catch {
                        promise(.failure(error))
                    }
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
