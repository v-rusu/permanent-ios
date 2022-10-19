//
//  FolderContentViewModel.swift
//  Permanent
//
//  Created by Vlad Alexandru Rusu on 14.10.2022.
//

import Foundation

class FolderContentViewModel: ViewModelInterface {
    static let didUpdateFilesNotification = Notification.Name("FolderContentViewModel.didUpdateFilesNotification")
    
    let session: PermSession!
    let folder: FileViewModel
    let filesRepository: FilesRepository
    
    var files: [FileViewModel] = [] {
        didSet {
            NotificationCenter.default.post(name: Self.didUpdateFilesNotification, object: self, userInfo: nil)
        }
    }
    
    var isGridView: Bool {
        get {
            session.isGridView
        }
    }
    
    init(folder: FileViewModel, filesRepository: FilesRepository = FilesRepository(), session: PermSession?) {
        self.folder = folder
        self.filesRepository = filesRepository
        self.session = session
        
        refreshFolder()
    }
    
    func refreshFolder() {
        filesRepository.folderContent(archiveNo: folder.archiveNo, folderLinkId: folder.folderLinkId) { files, error in
            self.files = files
        }
    }
    
    func insertFile(_ file: FileViewModel) {
        files.insert(file, at: 0)
    }
    
    func numberOfSections() -> Int {
        return 1
    }
    
    func numberOfItems(inSection section: Int) -> Int {
        return files.count
    }
    
    func fileForRow(atIndexPath indexPath: IndexPath) -> FileViewModel {
        return files[indexPath.row]
    }
}
