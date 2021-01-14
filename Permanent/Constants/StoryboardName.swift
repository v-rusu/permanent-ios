//
//  StoryboardNames.swift
//  Permanent
//
//  Created by Adrian Creteanu on 23/09/2020.
//

import Foundation

enum StoryboardName: String {
    case main
    case authentication
    case launch
    case onboarding
    case members
    case share
    case settings
    
    var name: String {
        return self.rawValue.capitalized
    }
}

enum ViewControllerId: String {
    case main
    case login
    case signUp
    case onboarding
    case verificationCode
    case termsConditions
    case twoStepVerification
    case biometrics
    case fabActionSheet
    case sideMenu
    case share
    case shares
    case members
    case manageLink
    case accountSettings
    case sharePreview

    var value: String {
        switch self {
        case .signUp:
            return "SignUp"
        case .verificationCode:
            return "VerificationCode"
        case .termsConditions:
            return "TermsConditions"
        case .twoStepVerification:
            return "TwoStepVerification"
        case .fabActionSheet:
            return "FABActionSheet"
        case .sideMenu:
            return "SideMenu"
        case .manageLink:
            return "ManageLink"
        case .accountSettings:
            return "AccountSettings"
        case .sharePreview:
            return "SharePreview"
        
        default:
            return self.rawValue.capitalized
        }
    }
}
