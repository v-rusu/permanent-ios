//
//  AppDelegate.swift
//  Permanent
//
//  Created by Lucian Cerbu on 04/08/2020.
//  Copyright © 2020 Lucian Cerbu. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    window = UIWindow(frame: UIScreen.main.bounds)
    let mainNavicationController = UINavigationController()
    let loginViewController = SignUpViewController.init(nibName: "SignUpViewController", bundle: .main)
    mainNavicationController.viewControllers = [loginViewController]

    window?.rootViewController = mainNavicationController
    window?.makeKeyAndVisible()
    
    initFirebase()

    return true
  }
  
  fileprivate func initFirebase() {
      guard
        let infoDict = Bundle.main.infoDictionary,
        let fileName = infoDict["GOOGLE_PLIST_NAME"] as? String,
        let filePath = Bundle.main.path(forResource: fileName, ofType: "plist"),
        let fileOpts = FirebaseOptions(contentsOfFile: filePath) else {
          assert(false, "Cannot load config file")
      }
    
      FirebaseApp.configure(options: fileOpts)
  }
}

