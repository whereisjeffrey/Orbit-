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

        // Auto-restore profile if data is missing (e.g., after app deletion + reinstall)
        if !LanguageManager.shared.hasTargetLanguage && ProfileBackupManager.shared.hasBackup {
            ProfileBackupManager.shared.restore()
            NSLog("💾 Auto-restored profile from backup after reinstall")
        } else if !LanguageManager.shared.hasTargetLanguage {
            NSLog("⚠️ LanguageManager: no target language set — user may not have completed onboarding")
        }

        // Auto-backup profile on every launch (lightweight — just writes a JSON file)
        ProfileBackupManager.shared.autoBackupIfNeeded()

        // ── All non-critical work deferred to background ──
        // Nothing here blocks the UI from appearing. The user sees the app instantly.
        let roundLang = LanguageManager.shared.targetLangRequired

        // WhisperKit on low priority (big download, not needed immediately)
        DispatchQueue.global(qos: .utility).async {
            DictateViewController.preloadWhisperKit()
        }

        // Lightning Round pre-gen — only if a real language is set.
        // On fresh install, targetLangRequired returns nativeLang ("en") because
        // the user hasn't picked a language yet. Pre-generating for "en" is wasted work
        // and the cards get rejected when the user picks their actual language.
        // For new users, the onboarding pre-gen (step 2) handles this instead.
        // Lightning Round pre-gen — DISABLED for v1 (shelved until database-backed version)
        // if LanguageManager.shared.hasTargetLanguage {
        //     DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 10) {
        //         LightningRoundEngine.preGenerate(language: roundLang)
        //     }
        // }

        // Process pending keyboard corrections separately — enriches mistake profile
        // for FUTURE rounds, but doesn't block the current pre-gen.
        DispatchQueue.global(qos: .utility).async {
            TTSCacheProcessor.processPendingRequests()
            MistakeIngestion.processKeyboardQueue()
        }

        // Pre-seed starter decks on HIGH priority — user sees Library tab first
        DispatchQueue.global(qos: .userInitiated).async {
            let seeder = StarterDeckSeeder.shared
            let langCode = seeder.targetLanguageCode
            let seededKey = "starter_decks_seeded_lang"
            let alreadySeeded = UserDefaults.standard.string(forKey: seededKey)

            // Only generate if language changed or never seeded
            if alreadySeeded != langCode {
                seeder.seed(forceLanguage: langCode) { success in
                    if success {
                        UserDefaults.standard.set(langCode, forKey: seededKey)
                        NSLog("📚 Starter decks pre-seeded for \(langCode)")
                    }
                }
            }
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
        // Schedule background tasks
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.scheduleTTSCacheTask()
            appDelegate.scheduleMistakeIngestTask()
            // appDelegate.scheduleLightningRoundTask()  // Shelved for v1.1
        }
    }
}
