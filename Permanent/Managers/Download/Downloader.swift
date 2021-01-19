//  
//  Downloadable.swift
//  Permanent
//
//  Created by Adrian Creteanu on 14.01.2021.
//

import Foundation

protocol Downloader {
    
    func download(_ file: FileDownloadInfo,
                  onDownloadStart: @escaping VoidAction,
                  onFileDownloaded: @escaping DownloadResponse,
                  progressHandler: ProgressHandler?)
    
    func cancelDownload()
    
}
