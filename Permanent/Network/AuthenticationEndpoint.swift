//
//  LoginEndpoint.swift
//  Permanent
//
//  Created by Adrian Creteanu on 18/09/2020.
//  Copyright © 2020 Lucian Cerbu. All rights reserved.
//

import Foundation

// TODO: See if this type is appropiate.
typealias LoginCredentials = (email: String, password: String)
typealias VerifyCodeCredentials = (email: String, code: String)

enum AuthenticationEndpoint {
    /// Verifies if user is authenticated.
    case verifyAuth
    /// Performs a login with an email & password credentials.
    case login(credentials: LoginCredentials)
    /// Verifies the code received on mail or sms.
    case verify(credentials: VerifyCodeCredentials)
    /// Sends an email in order to change the password.
    case forgotPassword(email: String)
}

extension AuthenticationEndpoint: RequestProtocol {
    var headers: RequestHeaders? {
        return nil
    }

    var parameters: RequestParameters? {
        switch self {
        case .login(let credentials):
            return Payloads.loginPayload(for: credentials)
        case .verify(let credentials):
            return Payloads.verifyPayload(for: credentials)
        case .forgotPassword(let email):
            return Payloads.forgotPasswordPayload(for: email)
        default:
            return nil
        }
    }

    var requestType: RequestType {
        .data
    }

    var responseType: ResponseType {
        .json
    }

    var path: String {
        switch self {
        case .verifyAuth:
            return "/auth/loggedin"
        case .login:
            return "/auth/login"
        case .verify:
            return "/auth/verify"
        case .forgotPassword:
            return "/auth/sendEmailForgotPassword"
        }
    }

    var method: RequestMethod {
        return .post
    }
}
