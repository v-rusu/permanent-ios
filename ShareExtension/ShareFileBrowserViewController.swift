//
//  ShareFileBrowserViewController.swift
//  ShareExtension
//
//  Created by Vlad Alexandru Rusu on 20.10.2022.
//

import Foundation
import UIKit

class ShareFileBrowserViewController: BaseViewController<SaveDestinationBrowserViewModel> {
    let folderContentView: FolderContentView = FolderContentView()
    let folderNavigationView: FolderNavigationView = FolderNavigationView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Choose Destination"
        
        viewModel = SaveDestinationBrowserViewModel()
        viewModel?.loadRootFolder()
        
        initUI()
        styleNavBar()
        
        NotificationCenter.default.addObserver(forName: FileBrowserViewModel.didUpdateContentViewModels, object: viewModel, queue: nil) { [weak self] notif in
            guard let self = self else { return }
            self.folderContentView.viewModel = self.viewModel?.contentViewModels.last
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        folderContentView.invalidateLayout()
    }
    
    func initUI() {
        folderContentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(folderContentView)
        
        folderNavigationView.translatesAutoresizingMaskIntoConstraints = false
        folderNavigationView.viewModel = viewModel?.navigationViewModel
        view.addSubview(folderNavigationView)
        
        NSLayoutConstraint.activate([
            folderNavigationView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            folderNavigationView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            folderNavigationView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            folderNavigationView.heightAnchor.constraint(equalToConstant: 40),
            folderContentView.topAnchor.constraint(equalTo: folderNavigationView.bottomAnchor, constant: 0),
            folderContentView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            folderContentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            folderContentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0)
        ])
    }
}
