//
//  AlbumDetailViewModel.swift
//  BostaTask
//
//  Created by Dodo's Mac on 12/02/2025.
//

import Foundation
import Combine
import Moya

class AlbumDetailViewModel: ObservableObject {
    @Published var photos: [Photo] = []
    @Published var filteredPhotos: [Photo] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    private var cancellables = Set<AnyCancellable>()
    private let provider = MoyaProvider<JSONPlaceholderAPI>()
    private let albumId: Int
    
    init(albumId: Int) {
        self.albumId = albumId
    }
    
    
    func fetchPhotos() {
        isLoading = true
        errorMessage = nil
        
        provider.request(.photos(albumId: albumId)) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                do {
                    let photos = try JSONDecoder().decode([Photo].self, from: response.data)
                    self.photos = photos
                    print(photos)
                    self.filteredPhotos = photos
                } catch {
                    self.errorMessage = "Failed \(error.localizedDescription)"
                }
                
            case .failure(let error):
                self.errorMessage = "Failed \(error.localizedDescription)"
            }
            
            self.isLoading = false
        }
    }
    
    func filterPhotos(with query: String) {
        if query.isEmpty {
            filteredPhotos = photos
        } else {
            filteredPhotos = photos.filter { $0.title.lowercased().contains(query.lowercased()) }
        }
    }
}
