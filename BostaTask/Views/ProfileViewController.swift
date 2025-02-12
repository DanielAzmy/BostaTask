//
//  ProfileViewController.swift
//  BostaTask
//
//  Created by Dodo's Mac on 12/02/2025.
//

import UIKit
import Combine

class ProfileViewController: UIViewController {
    private let viewModel = ProfileViewModel()
    private var cancellables = Set<AnyCancellable>()
    private let nameLabel = UILabel()
    private let addressLabel = UILabel()
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ProfileViewController loaded")
        setupUI()
        setupLoadingIndicator()
        bindViewModel()
        viewModel.fetchUser()
    }
    
    private func setupUI() {
        // Configure UI components
        nameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        addressLabel.font = UIFont.systemFont(ofSize: 14)
        addressLabel.numberOfLines = 0
        
        // Add subviews and constraints
        view.addSubview(nameLabel)
        view.addSubview(addressLabel)
        view.addSubview(tableView)
        
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
            addressLabel.translatesAutoresizingMaskIntoConstraints = false
            tableView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
                nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                
                addressLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
                addressLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                addressLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                
                tableView.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 16),
                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        
        
        // Set up table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    // MARK: - Bind ViewModel
    private func bindViewModel() {
        viewModel.$user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                guard let self = self, let user = user else { return }
                self.nameLabel.text = user.name
                self.addressLabel.text = "\(user.address.street), \(user.address.suite), \(user.address.city), \(user.address.zipcode)"
            }
            .store(in: &cancellables)
        
        viewModel.$albums
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                        guard let self = self else { return }
                        
                        if isLoading {
                            self.showLoadingIndicator()
                        } else {
                            self.hideLoadingIndicator()
                        }
                    }
            .store(in: &cancellables)
        
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                if let errorMessage = errorMessage {
                    self?.showErrorAlert(message: errorMessage)
                }
            }
            .store(in: &cancellables)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .gray
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private func setupLoadingIndicator() {
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

     func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }

     func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = viewModel.albums[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let album = viewModel.albums[indexPath.row]
        let albumDetailVC = AlbumDetailViewController(albumId: album.id)
        navigationController?.pushViewController(albumDetailVC, animated: true)
    }
}
