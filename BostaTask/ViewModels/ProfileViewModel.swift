//
//  ProfileViewModel.swift
//  BostaTask
//
//  Created by Dodo's Mac on 12/02/2025.
//
import Foundation
import Combine
import Moya

class ProfileViewModel: ObservableObject {
    @Published var user: User? = nil
    @Published var albums: [Album] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private var cancellables = Set<AnyCancellable>()
    private let provider = MoyaProvider<JSONPlaceholderAPI>()
    
    
    func fetchUser() {
        defer{
            print("end")
        }
        print("start")
        isLoading = true
        errorMessage = nil
        
        provider.request(.users) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                do {
                    let users = try JSONDecoder().decode([User].self, from: response.data)
                    if let randomUser = users.randomElement() {
                        self.user = randomUser
                        self.fetchAlbums(userId: randomUser.id)
                        print("User data received: \(users)")
                    } else {
                        self.errorMessage = "No users found"
                        self.isLoading = false
                    }
                } catch {
                    self.errorMessage = "Failed to decode users: \(error.localizedDescription)"
                    self.isLoading = false
                }
                
            case .failure(let error):
                self.errorMessage = "Failed to fetch users: \(error.localizedDescription)"
                print("Failed to fetch user: \(error.localizedDescription)")
                self.isLoading = false
            }
        }
    }
    
    private func fetchAlbums(userId: Int) {
        provider.request(.albums(userId: userId)) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                do {
                    let albums = try JSONDecoder().decode([Album].self, from: response.data)
                    self.albums = albums
                } catch {
                    self.errorMessage = "Failed to decode albums: \(error.localizedDescription)"
                }
                
            case .failure(let error):
                self.errorMessage = "Failed to fetch albums: \(error.localizedDescription)"
            }
            
            self.isLoading = false
        }
    }
}
