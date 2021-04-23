//
//  FilePreviewNavigationController.swift
//  Permanent
//
//  Created by Vlad Alexandru Rusu on 15.03.2021.
//

import UIKit

protocol FilePreviewNavigatable {
    func willMoveOffScreen()
    func willMoveOnScreen()
    func willClose()
}

protocol FilePreviewNavigationControllerDelegate: class {
    func filePreviewNavigationControllerDidChange(_ filePreviewNavigationVC: UIViewController, hasChanges: Bool)
    func filePreviewNavigationControllerWillClose(_ filePreviewNavigationVC: UIViewController, hasChanges: Bool)
}

class FilePreviewNavigationController: UINavigationController {
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait] //topViewController?.supportedInterfaceOrientations ?? (UIDevice.current.userInterfaceIdiom == .phone ? [.allButUpsideDown] : [.all])
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    weak var filePreviewNavDelegate: FilePreviewNavigationControllerDelegate?
    
    var hasChanges: Bool = false
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        
        addCloseButton(toViewController: rootViewController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        super.setViewControllers(viewControllers, animated: animated)
        
        if let vc = viewControllers.first {
            addCloseButton(toViewController: vc)
        }
    }
    
    func addCloseButton(toViewController vc: UIViewController) {
        let leftButtonImage: UIImage!
        if #available(iOS 13.0, *) {
            leftButtonImage = UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(weight: .regular))
        } else {
            leftButtonImage = UIImage(named: "close")
        }
        
//        vc.navigationItem.leftBarButtonItem = UIBarButtonItem(image: leftButtonImage, style: .plain, target: self, action: #selector(closeButtonAction(_:)))
    }
    
    @objc private func closeButtonAction(_ sender: Any) {
        filePreviewNavDelegate?.filePreviewNavigationControllerWillClose(self, hasChanges: hasChanges)
        
        dismiss(animated: true, completion: nil)
    }

}

extension FilePreviewNavigationController: FilePreviewNavigatable {
    func willMoveOffScreen() {
        (topViewController as! FilePreviewNavigatable).willMoveOffScreen()
    }
    
    func willMoveOnScreen() {
        (topViewController as! FilePreviewNavigatable).willMoveOnScreen()
    }
    
    func willClose() {
        (topViewController as! FilePreviewNavigatable).willClose()
    }
}
