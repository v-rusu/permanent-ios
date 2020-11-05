//
//  FileInfo.swift
//  Permanent
//
//  Created by Adrian Creteanu on 22/10/2020.
//

import Foundation

class FileInfo: NSObject, NSCoding {
    var fileContents: Data?
    var mimeType: String?
    var name: String
    var url: URL
    var folder: FolderInfo

    init(withURL url: URL, named name: String, folder: FolderInfo) {
        fileContents = try? Data(contentsOf: url)

        self.name = name
        self.url = url
        mimeType = UploadManager.instance.getMimeType(forExtension: url.pathExtension)
        self.folder = folder
    }

    static func createFiles(from urls: [URL], parentFolder: FolderInfo) -> [FileInfo] {
        return urls.map {
            FileInfo(withURL: $0,
                     named: $0.lastPathComponent,
                     folder: parentFolder)
        }
    }

    func encode(with coder: NSCoder) {
        coder.encode(name, forKey: "name")
        coder.encode(url, forKey: "url")
        coder.encode(folder, forKey: "folder")
    }
    
    required convenience init?(coder: NSCoder) {
        let name = coder.decodeObject(forKey: "name") as! String
        let url = coder.decodeObject(forKey: "url") as! URL
        let folder = coder.decodeObject(forKey: "folder") as! FolderInfo
        
        self.init(withURL: url, named: name, folder: folder)
    }
}
