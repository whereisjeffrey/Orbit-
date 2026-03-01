//
//  AuthManager.swift
//  TranslateHelper
//

import Foundation
import Combine
import FirebaseAuth
import AuthenticationServices
import CryptoKit

@MainActor
class AuthManager: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var handle: AuthStateDidChangeListenerHandle?
    private var currentNonce: String?

    init() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in self?.user = user }
        }
    }

    deinit {
        if let handle { Auth.auth().removeStateDidChangeListener(handle) }
    }

    var isSignedIn: Bool { user != nil }

    // MARK: - Email/Password

    func signIn(email: String, password: String) async {
        isLoading = true; errorMessage = nil
        do {
            let r = try await Auth.auth().signIn(withEmail: email, password: password)
            user = r.user
        } catch { errorMessage = friendlyError(error) }
        isLoading = false
    }

    func createAccount(fullName: String, email: String, password: String) async {
        isLoading = true; errorMessage = nil
        do {
            let r = try await Auth.auth().createUser(withEmail: email, password: password)
            let change = r.user.createProfileChangeRequest()
            change.displayName = fullName
            try await change.commitChanges()
            user = r.user
        } catch { errorMessage = friendlyError(error) }
        isLoading = false
    }

    func resetPassword(email: String) async -> Bool {
        isLoading = true; errorMessage = nil
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            isLoading = false; return true
        } catch { errorMessage = friendlyError(error) }
        isLoading = false; return false
    }

    func signOut() {
        try? Auth.auth().signOut()
        user = nil
    }

    // MARK: - Apple Sign-In

    func appleSignInRequest() -> ASAuthorizationAppleIDRequest {
        let nonce = randomNonceString()
        currentNonce = nonce
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        return request
    }

    func handleAppleSignIn(result: Result<ASAuthorization, Error>) async {
        isLoading = true; errorMessage = nil
        switch result {
        case .success(let auth):
            guard
                let appleCredential = auth.credential as? ASAuthorizationAppleIDCredential,
                let tokenData = appleCredential.identityToken,
                let tokenString = String(data: tokenData, encoding: .utf8),
                let nonce = currentNonce
            else {
                errorMessage = "Apple Sign-In failed. Please try again."
                isLoading = false; return
            }
            let credential = OAuthProvider.appleCredential(
                withIDToken: tokenString,
                rawNonce: nonce,
                fullName: appleCredential.fullName
            )
            do {
                let r = try await Auth.auth().signIn(with: credential)
                user = r.user
            } catch { errorMessage = friendlyError(error) }

        case .failure(let error):
            if (error as NSError).code != ASAuthorizationError.canceled.rawValue {
                errorMessage = friendlyError(error)
            }
        }
        isLoading = false
    }

    // MARK: - Helpers

    private func friendlyError(_ error: Error) -> String {
        let nsError = error as NSError
        if let code = AuthErrorCode(rawValue: nsError.code) {
            switch code {
            case .wrongPassword, .invalidCredential: return "Incorrect email or password."
            case .userNotFound:       return "No account found with that email."
            case .emailAlreadyInUse:  return "An account already exists with that email."
            case .weakPassword:       return "Password must be at least 6 characters."
            case .invalidEmail:       return "Please enter a valid email address."
            case .networkError:       return "Network error. Check your connection."
            default:                  return error.localizedDescription
            }
        }
        return error.localizedDescription
    }

    private func randomNonceString(length: Int = 32) -> String {
        var randomBytes = [UInt8](repeating: 0, count: length)
        _ = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        return randomBytes.map { String(format: "%02x", $0) }.joined()
    }

    private func sha256(_ input: String) -> String {
        let data = Data(input.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}
