//
//  AppDelegate.swift
//  Permanent
//
//  Created by Lucian Cerbu on 04/08/2020.
//

import Firebase
import FirebaseMessaging
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = RootViewController()
        window?.makeKeyAndVisible()

        initFirebase()
        initNotifications()

        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        guard
            userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let url = userActivity.webpageURL else {
            return false
        }
        
        if rootViewController.isDrawerRootActive {
            return navigateFromUniversalLink(url: url)
        } else {
            saveUnivesalLinkToken(url.lastPathComponent)
            return false
        }
        
    }

    fileprivate func initFirebase() {
        let firebaseOpts = FirebaseOptions(googleAppID: googleServiceInfo.googleAppId, gcmSenderID: googleServiceInfo.gcmSenderId)
        firebaseOpts.clientID = googleServiceInfo.clientId
        firebaseOpts.apiKey = googleServiceInfo.apiKey
        firebaseOpts.projectID = googleServiceInfo.projectId
        firebaseOpts.storageBucket = googleServiceInfo.storageBucket

        FirebaseApp.configure(options: firebaseOpts)
    }
    
    fileprivate func initNotifications() {
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        
        Messaging.messaging().delegate = self
        
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    fileprivate func navigateFromUniversalLink(url: URL) -> Bool {
        guard let sharePreviewVC = UIViewController.create(
                withIdentifier: .sharePreview,
                from: .share
        ) as? SharePreviewViewController else { return false }
        
        let viewModel = SharePreviewViewModel()
        viewModel.urlToken = url.lastPathComponent
        sharePreviewVC.viewModel = viewModel
        
        rootViewController.navigateTo(viewController: sharePreviewVC)
        return true
    }
    
    fileprivate func saveUnivesalLinkToken(_ token: String) {
        PreferencesManager.shared.set(token, forKey: Constants.Keys.StorageKeys.shareURLToken)
    }
    
}

extension AppDelegate {
    static var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    // TODO: Maybe make these optional?
    var rootViewController: RootViewController {
        return window!.rootViewController as! RootViewController
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("\n\npush token:" + fcmToken + "\n\n")
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    // Called when app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if #available(iOS 14.0, *) {
            completionHandler([.list, .banner])
        } else {
            completionHandler(.alert)
        }
    }

    // Called after the user interacts with the notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        guard response.actionIdentifier == UNNotificationDefaultActionIdentifier else { return }
        
        let userInfo = response.notification.request.content.userInfo
        if let notificationType = userInfo["notificationType"] as? String {
            switch notificationType {
            case "share-notification":
                guard let name: String = userInfo["sharedItemName"] as? String,
                      let recordId: Int = Int(userInfo["recordId"] as? String ?? ""),
                      let folderLinkId: Int = Int(userInfo["folder_linkId"] as? String ?? ""),
                      let archiveNbr: String = userInfo["archiveNbr"] as? String,
                      let type: String = userInfo["type"] as? String,
                      let csrf: String = PreferencesManager.shared.getValue(forKey: Constants.Keys.StorageKeys.csrfStorageKey) else {
                    break
                }
                DispatchQueue.main.async {
                    if self.rootViewController.isDrawerRootActive {
                        let newRootVC = UIViewController.create(withIdentifier: .shares, from: .share) as! SharesViewController
                        self.rootViewController.changeDrawerRoot(viewController: newRootVC)
                        
                        let fileVM = FileViewModel(name: name, recordId: recordId, folderLinkId: folderLinkId, archiveNbr: archiveNbr, type: type, csrf: csrf)
                        let filePreviewVC = UIViewController.create(withIdentifier: .filePreview, from: .main) as! FilePreviewViewController
                        filePreviewVC.file = fileVM
                        
                        let fileDetailsNavigationController = FilePreviewNavigationController(rootViewController: filePreviewVC)
                        fileDetailsNavigationController.filePreviewNavDelegate = newRootVC
                        fileDetailsNavigationController.modalPresentationStyle = .fullScreen
                        newRootVC.present(fileDetailsNavigationController, animated: true)
                    } else {
                        let shareNotifPayload = ShareNotificationPayload(name: name, recordId: recordId, folderLinkId: folderLinkId, archiveNbr: archiveNbr, type: type)
                        try? PreferencesManager.shared.setNonPlistObject(shareNotifPayload, forKey: Constants.Keys.StorageKeys.sharedFileKey)
                    }
                }
            default:
                break
            }
        }
    }
}
