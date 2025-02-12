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
    private let photosRepository: PhotosRepositoryType
    
    init(
        albumId: Int,
        photosRepository: PhotosRepositoryType = PhotoRepository()
    ) {
        self.albumId = albumId
        self.photosRepository = photosRepository
    }
    
    
    func fetchPhotos() {
        isLoading = true
        errorMessage = nil
        photosRepository.fetchPhotos(albumId: albumId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.errorMessage = "Failed to fetch users: \(error.localizedDescription)"
                }
            } receiveValue: { [weak self] photos in
                print(photos)
                self?.photos = photos
                self?.filteredPhotos = photos
                
            }
            .store(in: &cancellables)}
    
    func filterPhotos(with query: String) {
        if query.isEmpty {
            filteredPhotos = photos
        } else {
            filteredPhotos = photos.filter { $0.title.lowercased().contains(query.lowercased()) }
        }
    }
}
