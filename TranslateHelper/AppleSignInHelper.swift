//
//  AppleSignInHelper.swift
//  TranslateHelper
//

import AuthenticationServices
import UIKit

/// Triggers Apple Sign-In from any context without needing SignInWithAppleButton.
class AppleSignInHelper: NSObject,
    ASAuthorizationControllerDelegate,
    ASAuthorizationControllerPresentationContextProviding {

    var onResult: (Result<ASAuthorization, Error>) -> Void = { _ in }
    private weak var anchor: ASPresentationAnchor?

    func signIn(from windowScene: UIWindowScene?,
                request: ASAuthorizationAppleIDRequest,
                completion: @escaping (Result<ASAuthorization, Error>) -> Void) {
        self.anchor = windowScene?.windows.first
        self.onResult = completion
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return anchor ?? UIWindow()
    }

    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
        onResult(.success(authorization))
    }

    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithError error: Error) {
        onResult(.failure(error))
    }
}
