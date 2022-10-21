//
//  SaveDestinationBrowserViewModel.swift
//  Permanent
//
//  Created by Vlad Alexandru Rusu on 18.10.2022.
//

import Foundation

class SaveDestinationBrowserViewModel: FileBrowserViewModel {
    override init(filesRepository: FilesRepository = FilesRepository(), session: PermSession? = PermSession.currentSession) {
        super.init(filesRepository: filesRepository, session: session)
    
        navigationViewModel.workspaceName = "Private Files"
    }
    
    override func loadRootFolder() {
        filesRepository.getPrivateRoot { rootFolder, error in
            if let rootFolder = rootFolder {
                self.contentViewModels.append(FolderContentViewModel(folder: rootFolder))
            }
        }
    }
}
