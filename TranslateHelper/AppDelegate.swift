//
//  AppDelegate.swift
//  TranslateHelper
//

import UIKit
import FirebaseCore
import GoogleSignIn
import BackgroundTasks

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    static let ttsCacheTaskId = "com.jeffrey.TranslateHelper.tts-cache"
    static let mistakeIngestTaskId = "com.jeffrey.TranslateHelper.mistake-ingest"
    static let lightningRoundTaskId = "com.jeffrey.TranslateHelper.lightning-round"

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        registerBackgroundTasks()
        return true
    }

    // MARK: - Background Tasks

    private func registerBackgroundTasks() {
        // TTS cache processing — generates Neural2 audio for keyboard translations
        BGTaskScheduler.shared.register(forTaskWithIdentifier: Self.ttsCacheTaskId, using: nil) { task in
            self.handleTTSCacheTask(task as! BGProcessingTask)
        }

        // Mistake queue ingestion — processes keyboard corrections into mistake profile
        BGTaskScheduler.shared.register(forTaskWithIdentifier: Self.mistakeIngestTaskId, using: nil) { task in
            self.handleMistakeIngestTask(task as! BGProcessingTask)
        }

        // Lightning Round pre-generation — builds cards in background so they're instant
        BGTaskScheduler.shared.register(forTaskWithIdentifier: Self.lightningRoundTaskId, using: nil) { task in
            self.handleLightningRoundTask(task as! BGProcessingTask)
        }
    }

    private func handleTTSCacheTask(_ task: BGProcessingTask) {
        task.expirationHandler = { task.setTaskCompleted(success: false) }
        TTSCacheProcessor.processPendingRequests()
        // Give it a few seconds to fire off the API calls
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            task.setTaskCompleted(success: true)
            self.scheduleTTSCacheTask()
        }
    }

    private func handleMistakeIngestTask(_ task: BGProcessingTask) {
        task.expirationHandler = { task.setTaskCompleted(success: false) }
        MistakeIngestion.processKeyboardQueue()
        task.setTaskCompleted(success: true)
        self.scheduleMistakeIngestTask()
    }

    /// Schedule TTS cache processing for later (when app is backgrounded)
    func scheduleTTSCacheTask() {
        let request = BGProcessingTaskRequest(identifier: Self.ttsCacheTaskId)
        request.requiresNetworkConnectivity = true
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)  // 15 min
        try? BGTaskScheduler.shared.submit(request)
    }

    func scheduleMistakeIngestTask() {
        let request = BGProcessingTaskRequest(identifier: Self.mistakeIngestTaskId)
        request.requiresNetworkConnectivity = false
        request.earliestBeginDate = Date(timeIntervalSinceNow: 30 * 60)  // 30 min
        try? BGTaskScheduler.shared.submit(request)
    }

    // MARK: - Lightning Round Background Pre-Generation

    private func handleLightningRoundTask(_ task: BGProcessingTask) {
        task.expirationHandler = { task.setTaskCompleted(success: false) }

        let lang = LanguageManager.shared.targetLangRequired

        // Lightning Round shelved for v1.1 — skip pre-gen
        // LightningRoundEngine.preGenerate(language: lang)

        // Give the API call time to complete (up to 30s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
            task.setTaskCompleted(success: true)
            self.scheduleLightningRoundTask()
            NSLog("⚡ [BG] Lightning Round background task completed")
        }
    }

    func scheduleLightningRoundTask() {
        let request = BGProcessingTaskRequest(identifier: Self.lightningRoundTaskId)
        request.requiresNetworkConnectivity = true  // needs GPT API
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)  // every 15 min
        try? BGTaskScheduler.shared.submit(request)
    }

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication,
                     didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}

}
