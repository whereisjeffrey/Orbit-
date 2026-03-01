//
//  AuthManager.swift
//  TranslateHelper
//

import Foundation
import Combine
import Combine
import FirebaseAuth

@MainActor
class AuthManager: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var handle: AuthStateDidChangeListenerHandle?

    init() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in self?.user = user }
        }
    }

    deinit {
        if let handle { Auth.auth().removeStateDidChangeListener(handle) }
    }

    var isSignedIn: Bool { user != nil }

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
            isLoading = false
            return true
        } catch { errorMessage = friendlyError(error) }
        isLoading = false
        return false
    }

    func signOut() {
        try? Auth.auth().signOut()
        user = nil
    }

    private func friendlyError(_ error: Error) -> String {
        let code = AuthErrorCode(_nsError: error as NSError).code
        switch code {
        case .wrongPassword, .invalidCredential: return "Incorrect email or password."
        case .userNotFound:    return "No account found with that email."
        case .emailAlreadyInUse: return "An account already exists with that email."
        case .weakPassword:    return "Password must be at least 6 characters."
        case .invalidEmail:    return "Please enter a valid email address."
        case .networkError:    return "Network error. Check your connection."
        default:               return error.localizedDescription
        }
    }
}
