//
//  ProfileViewModel.swift
//  BostaTask
//
//  Created by Dodo's Mac on 12/02/2025.
//
import Foundation
import Combine

class ProfileViewModel: ObservableObject {
    @Published var user: User? = nil
    @Published var albums: [Album] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private var cancellables = Set<AnyCancellable>()
    private let userRepository: UserRepositoryType
    
    init(
        userRepository: UserRepositoryType = UserRepository()
    ) {
        self.userRepository = userRepository
    }
    
    
    func fetchUser() {
        isLoading = true
        errorMessage = nil
        
        userRepository.fetchUsers()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.errorMessage = "Failed to fetch users: \(error.localizedDescription)"
                    self?.isLoading = false
                }
            } receiveValue: { [weak self] users in
                if let randomUser = users.randomElement() {
                    self?.user = randomUser
                    self?.fetchAlbums(userId: randomUser.id)
                } else {
                    self?.errorMessage = "No users found"
                    self?.isLoading = false
                }
            }
            .store(in: &cancellables)
    }
    
    private func fetchAlbums(userId: Int) {
        userRepository.fetchAlbums(userId: userId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.errorMessage = "Failed to fetch albums: \(error.localizedDescription)"
                }
                self?.isLoading = false
            } receiveValue: { [weak self] albums in
                self?.albums = albums
            }
            .store(in: &cancellables)
    }
    
}
