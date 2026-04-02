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

        // Validate language is set — log warning if not (user may have abandoned onboarding)
        if !LanguageManager.shared.hasTargetLanguage {
            NSLog("⚠️ LanguageManager: no target language set — user may not have completed onboarding")
        }

        // ── All non-critical work deferred to background ──
        // Nothing here blocks the UI from appearing. The user sees the app instantly.
        let roundLang = LanguageManager.shared.targetLangRequired
        DispatchQueue.global(qos: .utility).async {
            // Pre-warm WhisperKit (downloads model if needed — can take 30-60s)
            DictateViewController.preloadWhisperKit()

            // Process pending TTS cache requests from the keyboard
            TTSCacheProcessor.processPendingRequests()

            // Process queued keyboard corrections into mistake profile
            MistakeIngestion.processKeyboardQueue()

            // Pre-generate Lightning Round so it's instant when user taps it
            LightningRoundEngine.preGenerate(language: roundLang)
        }

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
        // Extract ?lang=xx from deeplink — falls back to user's target language
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let lang = components?.queryItems?.first(where: { $0.name == "lang" })?.value ?? LanguageManager.shared.targetLangRequired
        presentDictate(language: lang)
    }

    private func presentDictate(language: String) {
        guard let root = window?.rootViewController else { return }

        // Wrap DictateViewController inside the VoiceKeyboardBackground blob gradient.
        // A container VC holds the SwiftUI background, with the recording VC on top.
        let container = VoiceDictateContainerViewController()
        container.targetLanguage = language
        container.modalPresentationStyle = .fullScreen

        if let presented = root.presentedViewController {
            presented.dismiss(animated: false) { root.present(container, animated: true) }
        } else {
            root.present(container, animated: true)
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Schedule background tasks for TTS cache + mistake ingestion
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.scheduleTTSCacheTask()
            appDelegate.scheduleMistakeIngestTask()
        }
    }
}
