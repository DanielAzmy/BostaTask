//
//  AlbumDetailViewController.swift
//  BostaTask
//
//  Created by Dodo's Mac on 12/02/2025.
//



import Foundation
import UIKit
import Combine
import Kingfisher

class AlbumDetailViewController: UIViewController {
    private let viewModel: AlbumDetailViewModel
    private var cancellables = Set<AnyCancellable>()
    private let searchBar = UISearchBar()
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (UIScreen.main.bounds.width / 3) - 10, height: (UIScreen.main.bounds.width / 3) - 10)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .gray
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    init(albumId: Int) {
        self.viewModel = AlbumDetailViewModel(albumId: albumId)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLoadingIndicator()
        bindViewModel()
        viewModel.fetchPhotos()
    }
    
    private func setupUI() {
        title = "Album Details"
        view.addSubview(searchBar)
        view.addSubview(collectionView)
        
        searchBar.placeholder = "Search photos by title"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        collectionView.delegate = self
        collectionView.dataSource = self
        searchBar.delegate = self
    }
    
    private func setupLoadingIndicator() {
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    private func bindViewModel() {
        // Reload collection view when filtered photos change
        viewModel.$filteredPhotos
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.showLoadingIndicator()
                } else {
                    self?.hideLoadingIndicator()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                if let errorMessage = errorMessage {
                    print("Error: \(errorMessage)")
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
}

extension AlbumDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.filteredPhotos.count
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let photo = viewModel.filteredPhotos[indexPath.row]
            openImageViewController(with: photo.url) // Use the full-size image URL
        }
        
        private func openImageViewController(with imageUrl: String) {
            let imageViewController = ImageViewController()
            imageViewController.imageUrl = imageUrl
            imageViewController.modalPresentationStyle = .fullScreen
            present(imageViewController, animated: true, completion: nil)
        }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let photo = viewModel.filteredPhotos[indexPath.row]
        
        print("\(photo.thumbnailUrl)")
        
        cell.viewWithTag(100)?.removeFromSuperview()
        
        let imageView = UIImageView(frame: cell.bounds)
        imageView.tag = 100
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        if let imageUrl = URL(string: photo.thumbnailUrl) {
            imageView.kf.setImage(
                with: imageUrl,
                placeholder: UIImage(named: "placeholder"),
                options: [
                    .transition(.fade(0.3))
                ],
                completionHandler: { result in
                    switch result {
                    case .failure:
                        imageView.image = UIImage(named: "placeholder")
                    case .success:
                        break
                    }
                }
            )
        } else {
            imageView.image = UIImage(named: "placeholder")
        }

        
        cell.addSubview(imageView)
        
        return cell
    }
    
}

extension AlbumDetailViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.filterPhotos(with: searchText)
    }
}

