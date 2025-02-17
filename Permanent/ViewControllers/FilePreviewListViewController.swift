//
//  FilePreviewListViewController.swift
//  Permanent
//
//  Created by Vlad Alexandru Rusu on 20.04.2021.
//

import UIKit

class FilePreviewListViewController: BaseViewController<FilesViewModel> {
    var pageVC: UIPageViewController!

    let controllersCache: NSCache<NSNumber, FilePreviewViewController> = NSCache<NSNumber, FilePreviewViewController>()
    
    var filteredFiles: [FileViewModel] {
        viewModel?.viewModels.filter({ $0.type.isFolder == false }) ?? []
    }

    var currentFile: FileViewModel!
    
    // Transition Variables
    var nextFile: FileViewModel?
    var nextTitle: String?
    var hasChanges: Bool = false
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = currentFile.name

        extendedLayoutIncludesOpaqueBars = true
        edgesForExtendedLayout = .all
        
        setupPageVC()
        setupNavigationBar()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onDidUpdateData(_:)), name: .filePreviewVMDidSaveData, object: nil)
    }
    
    func setupPageVC() {
        pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageVC.dataSource = self
        pageVC.delegate = self
        
        addChild(pageVC)
        view.addSubview(pageVC.view)
        pageVC.view.frame = view.bounds
        pageVC.didMove(toParent: self)
        
        if let indexOfFileVC = filteredFiles.firstIndex(of: currentFile) {
            let fileDetailsVC = dequeueViewController(atIndex: indexOfFileVC)!
            
            pageVC.setViewControllers([fileDetailsVC], direction: .forward, animated: false, completion: nil)
        }
    }
    
    func setupNavigationBar() {
        let shareButton = UIBarButtonItem(image: .more, style: .plain, target: self, action: #selector(shareButtonAction(_:)))
        
        let infoButton = UIBarButtonItem(image: .info, style: .plain, target: self, action: #selector(infoButtonAction(_:)))
        navigationItem.rightBarButtonItems = [shareButton, infoButton]
        
        let leftButtonImage: UIImage!
        leftButtonImage = UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(weight: .regular))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: leftButtonImage, style: .plain, target: self, action: #selector(closeButtonAction(_:)))
    }
    
    @objc func closeButtonAction(_ sender: Any) {
        (navigationController as! FilePreviewNavigationController).filePreviewNavDelegate?.filePreviewNavigationControllerWillClose(self, hasChanges: hasChanges)
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func shareButtonAction(_ sender: Any) {
        (pageVC.viewControllers?.first as! FilePreviewViewController).showShareMenu(sender)
    }
    
    @objc private func infoButtonAction(_ sender: Any) {
        let viewModel = (pageVC.viewControllers?.first as! FilePreviewViewController).viewModel
        
        let fileDetailsVC = UIViewController.create(withIdentifier: .fileDetailsOnTap, from: .main) as! FileDetailsViewController
        fileDetailsVC.file = currentFile
        fileDetailsVC.viewModel = viewModel
        fileDetailsVC.delegate = self
        
        let navControl = FilePreviewNavigationController(rootViewController: fileDetailsVC)
        navControl.modalPresentationStyle = .fullScreen
        present(navControl, animated: false, completion: nil)
    }
    
    @objc func onDidUpdateData(_ notification: Notification) {
        let viewModel = (pageVC.viewControllers?.first as! FilePreviewViewController).viewModel
        if let notifVM = notification.object as? FilePreviewViewModel, notifVM.file == viewModel?.file {
            title = viewModel?.name
            view.showNotificationBanner(title: "Change was saved.".localized())
        }
        
        hasChanges = true
    }
}

// MARK: - UIPageViewControllerDataSource, UIPageViewControllerDelegate
extension FilePreviewListViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        let nextVC = pendingViewControllers.first as! FilePreviewViewController
        nextFile = nextVC.file
        nextTitle = nextVC.viewModel?.name
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            title = nextTitle
            currentFile = nextFile
            
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let indexOfFileVC = filteredFiles.firstIndex(of: (viewController as! FilePreviewViewController).file) {
            let dequeuedVC = dequeueViewController(atIndex: Int(indexOfFileVC) - 1)
            
            return dequeuedVC
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let indexOfFileVC = filteredFiles.firstIndex(of: (viewController as! FilePreviewViewController).file) {
            let dequeuedVC = dequeueViewController(atIndex: Int(indexOfFileVC) + 1)
            return dequeuedVC
        }
        
        return nil
    }
    
    @discardableResult
    func dequeueViewController(atIndex index: Int, preloadLeftRightLevel: Int = 0) -> FilePreviewViewController? {
        if let fileDetailsVC = controllersCache.object(forKey: NSNumber(value: index)) {
            // Preload left and right controllers after the current one is loaded
            if preloadLeftRightLevel <= 2 {
                if fileDetailsVC.recordLoaded {
                    dequeueViewController(atIndex: index - 1, preloadLeftRightLevel: preloadLeftRightLevel + 1)
                    dequeueViewController(atIndex: index + 1, preloadLeftRightLevel: preloadLeftRightLevel + 1)
                } else {
                    fileDetailsVC.recordLoadedCB = { [weak self] fileDetailsVC in
                        self?.dequeueViewController(atIndex: index - 1, preloadLeftRightLevel: preloadLeftRightLevel + 1)
                        self?.dequeueViewController(atIndex: index + 1, preloadLeftRightLevel: preloadLeftRightLevel + 1)
                    }
                }
            }
            
            return fileDetailsVC
        } else if index >= 0 && index < filteredFiles.count {
            let fileDetailsVC = UIViewController.create(withIdentifier: .filePreview, from: .main) as! FilePreviewViewController
            
            // Preload left and right controllers after the current one is loaded
            if preloadLeftRightLevel <= 2 {
                fileDetailsVC.recordLoadedCB = { [weak self] fileDetailsVC in
                    self?.dequeueViewController(atIndex: index - 1, preloadLeftRightLevel: preloadLeftRightLevel + 1)
                    self?.dequeueViewController(atIndex: index + 1, preloadLeftRightLevel: preloadLeftRightLevel + 1)
                }
            }
            let file = filteredFiles[index]
            fileDetailsVC.file = file
            fileDetailsVC.view.isHidden = false // preload the view
            fileDetailsVC.loadVM()
            
            if let publicArchiveVM = viewModel as? PublicArchiveViewModel {
                fileDetailsVC.viewModel?.publicURL = publicArchiveVM.publicURL(forFile: file)
            }
            
            if let publicArchiveVM = viewModel as? PublicFilesViewModel {
                fileDetailsVC.viewModel?.publicURL = publicArchiveVM.publicURL(forFile: file)
            }
            
            controllersCache.setObject(fileDetailsVC, forKey: NSNumber(value: index))
            
            return fileDetailsVC
        }
        
        return nil
    }
}

extension FilePreviewListViewController: FilePreviewNavigationControllerDelegate {
    func filePreviewNavigationControllerWillClose(_ filePreviewNavigationVC: UIViewController, hasChanges: Bool) {
        if hasChanges == true {
            self.hasChanges = true
        }
        
        dismiss(animated: true) {
            (self.navigationController as? FilePreviewNavigationController)?.filePreviewNavDelegate?.filePreviewNavigationControllerWillClose(self, hasChanges: self.hasChanges)
        }
    }
    
    func filePreviewNavigationControllerDidChange(_ filePreviewNavigationVC: UIViewController, hasChanges: Bool) {
        let viewModel = (pageVC.viewControllers?.first as! FilePreviewViewController).viewModel
        title = viewModel?.name
        
        if hasChanges == true {
            self.hasChanges = true
        }
    }
}
