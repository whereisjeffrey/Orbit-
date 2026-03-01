//
//  SceneDelegate.swift
//  TranslateHelper
//

import UIKit
import SwiftUI
import FirebaseAuth
import GoogleSignIn

@MainActor
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let authManager = AuthManager()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let rootView = RootView().environmentObject(authManager)
        let host = UIHostingController(rootView: rootView)

        let win = UIWindow(windowScene: windowScene)
        win.rootViewController = host
        win.makeKeyAndVisible()
        window = win

        if let ctx = connectionOptions.urlContexts.first {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                self.handle(url: ctx.url)
            }
        }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        
        if GIDSignIn.sharedInstance.handle(url) {
            return
        }
        
        handle(url: url)
    }

    private func handle(url: URL) {
        guard url.scheme == "translatehelper", url.host == "dictate" else { return }
        presentDictate()
    }

    private func presentDictate() {
        guard let root = window?.rootViewController else { return }
        let vc = DictateViewController()
        vc.modalPresentationStyle = .fullScreen
        if let presented = root.presentedViewController {
            presented.dismiss(animated: false) { root.present(vc, animated: true) }
        } else {
            root.present(vc, animated: true)
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
