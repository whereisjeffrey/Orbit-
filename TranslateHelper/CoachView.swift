//
//  CoachView.swift
//  TranslateHelper
//
//  Coach tab — empty state (new user) + populated state (with data).
//  Uses TSGradientBackground, HelveticaNeue, tsCard, tsAccent from DesignSystem.

import SwiftUI
import UIKit
import AVFoundation

struct CoachView: View {
    @Environment(\.colorScheme) private var colorScheme

    // DEV TESTING: toggle between empty and populated states
    @State private var showPopulated = false

    var body: some View {
        ZStack {
            TSGradientBackground().ignoresSafeArea()

            if showPopulated {
                CoachPopulatedView(showPopulated: $showPopulated)
            } else {
                CoachEmptyView(showPopulated: $showPopulated)
            }
        }
    }
}

// MARK: - Part A: Empty State (brand new user)

struct CoachEmptyView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Binding var showPopulated: Bool

    @AppStorage("talkswitch_target_lang",
                store: UserDefaults(suiteName: "group.com.jeff.translatehelper"))
    private var targetLang = LanguageManager.shared.targetLangRequired

    private var targetFlag: String {
        let flags: [String: String] = [
            "en": "🇺🇸", "pt": "🇧🇷", "es": "🇪🇸", "fr": "🇫🇷", "de": "🇩🇪",
            "it": "🇮🇹", "ja": "🇯🇵", "ko": "🇰🇷", "ar": "🇦🇪", "zh": "🇨🇳",
        ]
        return flags[targetLang] ?? "🌐"
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {

                // ── Sol avatar ──────────────────────
                Image("SolAvaatar")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.tsAccent.opacity(0.3), lineWidth: 1.5)
                    )
                    .shadow(color: Color.tsAccent.opacity(0.3), radius: 16, x: 0, y: 0)
                    .shadow(color: Color.tsAccent.opacity(0.15), radius: 32, x: 0, y: 0)
                    .padding(.top, 48)
                    .padding(.bottom, 16)

                // ── Greeting ────────────────────────────────────
                Text("Hey, I'm Sol.")
                    .font(.custom("HelveticaNeue-Bold", size: 24))
                    .foregroundColor(.tsLabel)
                    .padding(.bottom, 8)

                Text("Think of me as a friend who speaks the language. We can have conversations whenever you want to practice, and when you're texting on WhatsApp, I'll be in your keyboard giving you tips as you go.")
                    .font(.custom("HelveticaNeue", size: 15))
                    .foregroundColor(.tsSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 32)

                // ── How it works ────────────────────────────────
                VStack(alignment: .leading, spacing: 20) {
                    Text("HOW IT WORKS")
                        .font(.custom("HelveticaNeue-Bold", size: 11))
                        .foregroundColor(.tsSecondary)
                        .kerning(1.2)

                    howItWorksRow(icon: "keyboard", color: Color.tsAccent, text: "Write or send audios like you normally do in WhatsApp")
                    howItWorksRow(icon: "target", color: Color(hex: "#34C759"), text: "I'll give you 1-2 tips per message — pronunciation, grammar, or both")
                    howItWorksRow(icon: "chart.line.uptrend.xyaxis", color: Color(hex: "#FF9500"), text: "Over time, I'll track your patterns and show you exactly where you're improving")
                    howItWorksRow(icon: "brain.head.profile", color: Color(hex: "#AF52DE"), text: "I know your native language brain will try to trick you — I'll help you untrain those habits")
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.tsCard)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.tsBorder, lineWidth: 1)
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 32)

                // ── What you'll unlock ──────────────────────────
                VStack(alignment: .leading, spacing: 16) {
                    Text("WHAT YOU'LL UNLOCK")
                        .font(.custom("HelveticaNeue-Bold", size: 11))
                        .foregroundColor(.tsSecondary)
                        .kerning(1.2)

                    unlockRow(icon: "🗣", label: "Pronunciation insights", detail: "After 1 message", unlocked: true)
                    unlockRow(icon: "📝", label: "Grammar scoring", detail: "After 3 messages", unlocked: false)
                    unlockRow(icon: "📚", label: "Vocabulary analysis", detail: "After 10 messages", unlocked: false)
                    unlockRow(icon: "💬", label: "Fluency tracking", detail: "After 10 messages", unlocked: false)

                    Text("Weekly reports · Milestones · Practice sessions · and more")
                        .font(.custom("HelveticaNeue-Medium", size: 13))
                        .foregroundColor(.tsLabel)
                        .padding(.top, 4)
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.tsCard)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.tsBorder, lineWidth: 1)
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 32)

                // ── CTA ─────────────────────────────────────────
                Text("Open WhatsApp, switch to Orbit, and send your first message. I'll take it from there.")
                    .font(.custom("HelveticaNeue", size: 14))
                    .foregroundColor(.tsSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 32)

                // ── DEV: Next button ────────────────────────────
                #if DEBUG
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showPopulated = true
                    }
                } label: {
                    Text("Next → (populated state)")
                        .font(.custom("HelveticaNeue-Medium", size: 14))
                        .foregroundColor(.tsAccent)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.tsAccent.opacity(0.1))
                        .clipShape(Capsule())
                }
                .padding(.bottom, 40)
                #endif

                Spacer(minLength: 80)
            }
        }
    }

    private func howItWorksRow(icon: String, color: Color = .tsAccent, text: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(color)
                .frame(width: 32)
            Text(text)
                .font(.custom("HelveticaNeue", size: 14))
                .foregroundColor(.tsLabel)
                .lineSpacing(2)
        }
    }

    private func unlockRow(icon: String, label: String, detail: String, unlocked: Bool) -> some View {
        HStack(spacing: 12) {
            Text(icon)
                .font(.system(size: 20))
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.custom("HelveticaNeue-Medium", size: 14))
                    .foregroundColor(unlocked ? .tsLabel : .tsSecondary)
                Text(detail)
                    .font(.custom("HelveticaNeue", size: 12))
                    .foregroundColor(.tsSecondary)
            }

            Spacer()

            if unlocked {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "#34C759"))
            } else {
                Image(systemName: "lock.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.tsSecondary.opacity(0.5))
            }
        }
    }
}

// MARK: - Part B: Populated State (with mock data)

struct CoachPopulatedView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Binding var showPopulated: Bool
    @State private var showFullReport = false
    @State private var showPracticeSession = false
    @State private var showLevelAssessment = false
    @State private var assessmentDestination: String = "practice" // "practice" or "lightning"
    @State private var showTalkDrill = false
    @State private var showLevelDetail = false
    @State private var showLightningRound = false
    @State private var expandedCategories: Set<MistakeCategory> = []
    @State private var expandedMistakes: Set<UUID> = []  // individual mistake rows
    @State private var revealedAnswers: Set<UUID> = []  // quiz answers revealed

    // Cached data — computed once on appear, not every frame
    @State private var cachedRoundHistory: [LightningRoundResult] = []
    @State private var cachedWeeklyAvgScore: Int = 0
    @State private var cachedMasteredCount: Int = 0
    @State private var cachedWeakestCategory: MistakeCategory?

    /// Profile unlocks after 3 data sources: self-assessment + Sol conversation + corrections
    private var isProfileUnlocked: Bool {
        let hasAssessment = SelfReportedLevel.hasCompleted
        let hasSolSession = PracticeStatsStore.shared.totalSessionCount >= 1
        let hasCorrections = MistakeProfileStore.shared.entries.count >= 5
        let sources = [hasAssessment, hasSolSession, hasCorrections].filter { $0 }.count
        return sources >= 3
    }

    /// Locked profile card — shows while calibrating
    private var lockedProfileCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.tsAccent)
                Text("Your Skill Profile")
                    .font(.custom("HelveticaNeue-Bold", size: 16))
                    .foregroundColor(.tsLabel)
                Spacer()
            }

            Text("Orbit is learning how you learn. After a few sessions, your personalized profile will appear here.")
                .font(.custom("HelveticaNeue", size: 13))
                .foregroundColor(.tsSecondary)
                .lineSpacing(2)

            // Progress indicators
            HStack(spacing: 16) {
                calibrationDot(label: "Assessment", done: SelfReportedLevel.hasCompleted)
                calibrationDot(label: "Sol Conversation", done: PracticeStatsStore.shared.totalSessionCount >= 1)
                calibrationDot(label: "Corrections", done: MistakeProfileStore.shared.entries.count >= 5)
            }
            .padding(.top, 4)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.tsBorder, lineWidth: 1)
        )
    }

    private func calibrationDot(label: String, done: Bool) -> some View {
        VStack(spacing: 6) {
            Image(systemName: done ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 16))
                .foregroundColor(done ? Color(hex: "#34C759") : .tsSecondary.opacity(0.4))
            Text(label)
                .font(.custom("HelveticaNeue", size: 10))
                .foregroundColor(done ? .tsLabel : .tsSecondary)
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {

                // ── 1. Skill Profile (locked until 3 data sources) ──
                if isProfileUnlocked {
                    scoreOverview
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 20)
                        .onTapGesture { showLevelDetail = true }
                } else {
                    lockedProfileCard
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 20)
                }

                // ── 2. Practice Mode Card ────────────────────────
                practiceCard
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)

                // ── 3. Weekly Snapshot ────────────────────────────
                weeklySnapshot
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)

                // ── 4. Target Areas ─────────────────────────────
                targetAreas
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    .onAppear {
                        // Target areas start at zero — they fill organically
                        // from keyboard corrections and Sol conversations.
                        // One-time wipe of old pre-seeded data from dev builds.
                        let wipeKey = "target_areas_wiped_v6"
                        if !UserDefaults.standard.bool(forKey: wipeKey) {
                            MistakeProfileStore.shared.resetToZero()
                            UserDefaults.standard.set(true, forKey: wipeKey)
                            // Force a fresh backup so old backup file no longer has mistake data
                            ProfileBackupManager.shared.backup()
                            NSLog("🎯 [TargetAreas] Wiped + backup refreshed")
                        }
                        refreshWeeklyData()
                    }

                // Milestones removed — lives in weekly/monthly reports now
                // Talk card removed — pronunciation drills covered by Lightning Round

                // ── DEV: Back button ─────────────────────────────
                #if DEBUG
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showPopulated = false
                    }
                } label: {
                    Text("← Back to empty state")
                        .font(.custom("HelveticaNeue-Medium", size: 14))
                        .foregroundColor(.tsAccent)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.tsAccent.opacity(0.1))
                        .clipShape(Capsule())
                }
                .padding(.bottom, 40)
                #endif

                Spacer(minLength: 80)
            }
        }
        .fullScreenCover(isPresented: $showPracticeSession) {
            PracticeSessionView()
        }
        .sheet(isPresented: $showLevelAssessment) {
            LevelAssessmentView(
                isSkippable: false,
                onComplete: {},
                contextMessage: "Just a quick question to help us get started."
            )
            .onDisappear {
                // After assessment completes, open whichever feature they tapped
                if SelfReportedLevel.hasCompleted {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        if assessmentDestination == "lightning" {
                            showLightningRound = true
                        } else {
                            showPracticeSession = true
                        }
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showLightningRound) {
            LightningRoundView()
        }
        .onAppear {
            // Lightning Round pre-gen disabled (shelved for v1.1)
        }
    }

    // No seed data — mistake profile populates organically from real usage.
}

// MARK: - Animated blob gradient (card-sized version of splash / recorder background)
//
// Same 7-blob radial system as SplashFinisherBackground / VoiceKeyboardBackground.
// Frequencies are 2× the VoiceKeyboard values (half the Splash speed) — active enough
// to feel alive inside the card without distracting from the text content.

private struct GreetingCardBackground: View {

    private static let blobColors: [Color] = [
        Color(red: 1.000, green: 0.420, blue: 0.000),   // orange
        Color(red: 0.984, green: 0.000, blue: 0.376),   // pink-red
        Color(red: 0.820, green: 0.000, blue: 0.820),   // magenta
        Color(red: 0.420, green: 0.000, blue: 0.900),   // purple
        Color(red: 0.000, green: 0.780, blue: 0.820),   // teal
        Color(red: 0.050, green: 0.300, blue: 0.980),   // electric blue
        Color(red: 1.000, green: 0.000, blue: 0.290),   // hot pink
    ]

    private struct BlobConfig {
        let baseX, baseY: Double
        let ampX,  ampY:  Double
        let freqX, freqY: Double
        let phase:        Double
        let radius:       Double
    }

    // Slow ambient drift — 20% of previous speed
    private static let configs: [BlobConfig] = [
        BlobConfig(baseX: 0.15, baseY: 0.85, ampX: 0.20, ampY: 0.18, freqX: 0.044, freqY: 0.036, phase: 0.0, radius: 0.90),
        BlobConfig(baseX: 0.80, baseY: 0.85, ampX: 0.18, ampY: 0.20, freqX: 0.036, freqY: 0.048, phase: 1.2, radius: 0.88),
        BlobConfig(baseX: 0.45, baseY: 0.50, ampX: 0.22, ampY: 0.20, freqX: 0.052, freqY: 0.040, phase: 2.4, radius: 0.95),
        BlobConfig(baseX: 0.80, baseY: 0.25, ampX: 0.18, ampY: 0.22, freqX: 0.040, freqY: 0.052, phase: 0.8, radius: 0.88),
        BlobConfig(baseX: 0.20, baseY: 0.22, ampX: 0.20, ampY: 0.18, freqX: 0.048, freqY: 0.044, phase: 3.6, radius: 0.92),
        BlobConfig(baseX: 0.65, baseY: 0.10, ampX: 0.16, ampY: 0.16, freqX: 0.032, freqY: 0.036, phase: 1.8, radius: 0.86),
        BlobConfig(baseX: 0.50, baseY: 0.70, ampX: 0.22, ampY: 0.20, freqX: 0.044, freqY: 0.048, phase: 4.8, radius: 0.90),
    ]

    @State private var startDate = Date()

    var body: some View {
        Color(red: 0.38, green: 0.00, blue: 0.55)
            .overlay(
                TimelineView(.animation) { timeline in
                    Canvas { ctx, size in
                        let t = timeline.date.timeIntervalSince(startDate)
                        for i in Self.configs.indices {
                            let cfg   = Self.configs[i]
                            let color = Self.blobColors[i % Self.blobColors.count]
                            let cx = (cfg.baseX + cfg.ampX * sin(2 * .pi * cfg.freqX * t + cfg.phase)) * size.width
                            let cy = (cfg.baseY + cfg.ampY * cos(2 * .pi * cfg.freqY * t + cfg.phase)) * size.height
                            let r  = cfg.radius * min(size.width, size.height)
                            let gradient = Gradient(stops: [
                                .init(color: color.opacity(0.72), location: 0.0),
                                .init(color: color.opacity(0.0),  location: 1.0),
                            ])
                            let shading = GraphicsContext.Shading.radialGradient(
                                gradient,
                                center: CGPoint(x: cx, y: cy),
                                startRadius: 0,
                                endRadius: r
                            )
                            var innerCtx = ctx
                            innerCtx.blendMode = .lighten
                            innerCtx.fill(
                                Path(ellipseIn: CGRect(x: cx - r, y: cy - r,
                                                       width: r * 2, height: r * 2)),
                                with: shading
                            )
                        }
                    }
                }
            )
            .onAppear { startDate = Date() }
    }
}

// MARK: - CoachPopulatedView (continued)
extension CoachPopulatedView {

    // MARK: - 2. Score Overview

    private var scoreOverview: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("📊")
                    .font(.system(size: 16))
                Text("YOUR LEVEL")
                    .font(.custom("HelveticaNeue-Bold", size: 11))
                    .foregroundColor(.tsSecondary)
                    .kerning(1.2)
                Spacer()
            }
                .kerning(1.2)

            HStack(spacing: 6) {
                let store = UserLevelStore.shared
                let stats = PracticeStatsStore.shared
                let assessed = store.hasBeenAssessed
                Image(systemName: assessed ? "chart.line.uptrend.xyaxis" : "questionmark.circle")
                    .font(.system(size: 12))
                    .foregroundColor(assessed ? Color(hex: "#34C759") : .tsSecondary)
                Text(assessed
                     ? "Overall: \(store.overallLevel.rawValue) · \(stats.totalSessionCount) session\(stats.totalSessionCount == 1 ? "" : "s")"
                     : "Take the level assessment to see your scores")
                    .font(.custom("HelveticaNeue", size: 12))
                    .foregroundColor(.tsSecondary)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                let store = UserLevelStore.shared
                let colorMap: [(SkillCategory, Color)] = [
                    (.pronunciation, Color(hex: "#34C759")),
                    (.grammar, Color.tsAccent),
                    (.vocabulary, Color(hex: "#FF9500")),
                    (.fluency, Color(hex: "#AF52DE")),
                ]
                ForEach(colorMap, id: \.0) { skill, color in
                    let assessment = store.skills[skill]
                    scoreGauge(
                        label: skill.displayName,
                        level: assessment?.level.rawValue ?? "—",
                        progress: CGFloat(assessment?.progress ?? 0),
                        color: color,
                        locked: assessment == nil
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.tsCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.tsBorder, lineWidth: 1)
        )
        .sheet(isPresented: $showLevelDetail) {
            LevelDetailView()
        }
    }

    private func scoreGauge(label: String, level: String, progress: CGFloat, color: Color, locked: Bool) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.12), lineWidth: 6)
                    .frame(width: 64, height: 64)

                if !locked {
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    color.opacity(0.75),   // softer at top
                                    color,                 // full saturation at bottom
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .frame(width: 64, height: 64)
                        .rotationEffect(.degrees(-90))
                }

                if locked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.tsSecondary.opacity(0.4))
                } else {
                    Text(level)
                        .font(.custom("HelveticaNeue-Bold", size: 18))
                        .foregroundColor(color)
                }
            }

            Text(label)
                .font(.custom("HelveticaNeue-Medium", size: 12))
                .foregroundColor(locked ? .tsSecondary.opacity(0.5) : .tsLabel)
        }
    }

    // MARK: - 3. Weekly Snapshot

    /// Refresh cached weekly data — call on appear and after sessions
    private func refreshWeeklyData() {
        DispatchQueue.global(qos: .userInitiated).async {
            let roundHistory = LightningRoundEngine.shared.loadRoundHistory()
            let thisWeekRounds = roundHistory.filter {
                Calendar.current.isDate($0.date, equalTo: Date(), toGranularity: .weekOfYear)
            }
            let avg = thisWeekRounds.isEmpty ? 0 :
                thisWeekRounds.reduce(0) { $0 + $1.scorePercent } / thisWeekRounds.count

            let weekStart = Calendar(identifier: .iso8601).dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
            let profile = MistakeProfileStore.shared
            let masteredCount = profile.entries.filter { $0.masteredAt != nil && $0.masteredAt! >= weekStart }.count
            let breakdown = profile.categoryBreakdown
            let weakest = breakdown.max(by: { $0.count < $1.count })?.category

            DispatchQueue.main.async {
                self.cachedRoundHistory = roundHistory
                self.cachedWeeklyAvgScore = avg
                self.cachedMasteredCount = masteredCount
                self.cachedWeakestCategory = weakest
            }
        }
    }

    private var weeklySnapshot: some View {
        let stats = PracticeStatsStore.shared
        let avgScore = cachedWeeklyAvgScore

        return VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("📅")
                    .font(.system(size: 14))
                Text("THIS WEEK")
                    .font(.custom("HelveticaNeue-Bold", size: 11))
                    .foregroundColor(.tsSecondary)
                    .kerning(1.2)
                Spacer()
                Text(stats.weekRangeString)
                    .font(.custom("HelveticaNeue", size: 12))
                    .foregroundColor(.tsSecondary)
            }

            // ── Stats row (real data) ───────────────────────
            HStack(spacing: 16) {
                statPill(value: "\(stats.weeklySessionCount)", label: "sessions")
                statPill(value: "\(stats.weeklyPracticeMinutes)", label: "min practice")
                statPill(value: "\(stats.weeklyMessageCount)", label: "messages")
            }

            Divider().opacity(0.3)

            // ── Summary (derived from real data) ────────────
            VStack(alignment: .leading, spacing: 12) {
                if cachedMasteredCount > 0 {
                    weeklyRow(emoji: "✅", text: "Win: Graduated \(cachedMasteredCount) pattern\(cachedMasteredCount == 1 ? "" : "s") this week")
                } else if stats.weeklySessionCount > 0 {
                    weeklyRow(emoji: "✅", text: "Win: \(stats.weeklySessionCount) practice session\(stats.weeklySessionCount == 1 ? "" : "s") this week")
                } else {
                    weeklyRow(emoji: "💬", text: "Start a practice session to see your progress here")
                }

                if let weakCat = cachedWeakestCategory {
                    let accuracy = MistakeProfileStore.shared.categoryAccuracy(weakCat)
                    weeklyRow(emoji: "✏️", text: "Work on: \(weakCat.displayName)\(accuracy > 0 ? " (\(accuracy)%)" : "")")
                }

                if stats.currentStreak > 0 {
                    weeklyRow(emoji: "🔥", text: "\(stats.currentStreak)-day streak — keep it going")
                }
            }

            Button { showFullReport = true } label: {
                Text("See full report →")
                    .font(.custom("HelveticaNeue-Medium", size: 13))
                    .foregroundColor(.tsAccent)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.tsBorder, lineWidth: 1)
        )
        .sheet(isPresented: $showFullReport) {
            WeeklyFullReportView()
        }
    }

    private func statPill(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.custom("HelveticaNeue-Bold", size: 18))
                .foregroundColor(.tsLabel)
            Text(label)
                .font(.custom("HelveticaNeue", size: 11))
                .foregroundColor(.tsSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    private func weeklyRow(emoji: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(emoji)
                .font(.system(size: 14))
                .frame(width: 24)
            Text(text)
                .font(.custom("HelveticaNeue", size: 14))
                .foregroundColor(.tsLabel)
                .lineSpacing(2)
        }
    }

    // MARK: - 4. Recent Tips

    private var recentTips: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("RECENT TIPS")
                .font(.custom("HelveticaNeue-Bold", size: 11))
                .foregroundColor(.tsSecondary)
                .kerning(1.2)

            // Today
            tipCard(icon: "🗣", date: "Mar 22, 5:23 PM", text: "Watch the nasal 'ão' in 'coração' — tongue further back.", color: Color.tsAccent, type: .regular)

            tipCard(icon: "📝", date: "Mar 22, 4:45 PM", text: "Remember — 'a casa dele,' possession flips in Portuguese. Getting closer. 👊", color: Color(hex: "#FF9500"), type: .regular)

            // Transfer insight (special styling)
            tipCard(icon: "🧠", date: "Mar 22, 2:10 PM", text: "In English you'd say 'I am 25.' But Portuguese uses 'ter' (to have): 'eu tenho 25 anos.' Your English brain is doing what it's trained to do — this is a normal hurdle.", color: Color(hex: "#AF52DE"), type: .insight)

            // Milestone (special styling)
            tipCard(icon: "🎉", date: "Mar 21", text: "MILESTONE: You haven't mixed up 'ser' and 'estar' in 14 days. That's not luck — that's muscle memory forming. One down.", color: Color(hex: "#FFD700"), type: .milestone)

            // Older tips
            tipCard(icon: "💡", date: "Mar 20", text: "Gender on '-ade' words: 'a cidade,' 'a saudade,' 'a liberdade' — always feminine.", color: Color(hex: "#34C759"), type: .regular)

            tipCard(icon: "🗣", date: "Mar 19", text: "Your speaking pace is fast — try pausing between ideas. Natives will understand you better.", color: Color.tsAccent, type: .regular)

            Button {} label: {
                Text("View all tips →")
                    .font(.custom("HelveticaNeue-Medium", size: 13))
                    .foregroundColor(.tsAccent)
            }
            .padding(.top, 4)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.tsBorder, lineWidth: 1)
        )
    }

    enum TipType { case regular, insight, milestone }

    private func tipCard(icon: String, date: String, text: String, color: Color, type: TipType = .regular) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(icon)
                    .font(.system(size: 14))
                if type == .insight {
                    Text("LANGUAGE INSIGHT")
                        .font(.custom("HelveticaNeue-Bold", size: 9))
                        .foregroundColor(color)
                        .kerning(0.8)
                } else if type == .milestone {
                    Text("MILESTONE")
                        .font(.custom("HelveticaNeue-Bold", size: 9))
                        .foregroundColor(color)
                        .kerning(0.8)
                }
                Spacer()
                Text(date)
                    .font(.custom("HelveticaNeue", size: 11))
                    .foregroundColor(.tsSecondary)
            }
            Text(text)
                .font(.custom("HelveticaNeue", size: 14))
                .foregroundColor(.tsLabel)
                .lineSpacing(2)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(type == .regular ? 0.06 : 0.10))
        )
        .overlay(
            type != .regular ?
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color.opacity(0.2), lineWidth: 0.5)
            : nil
        )
    }

    // MARK: - 4b. Target Areas + Lightning Round

    private var targetAreas: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("🎯")
                    .font(.system(size: 16))
                Text("TARGET AREAS")
                    .font(.custom("HelveticaNeue-Bold", size: 11))
                    .foregroundColor(.tsSecondary)
                    .kerning(1.2)
                Spacer()
            }

            let profile = MistakeProfileStore.shared
            let breakdown = profile.categoryBreakdown

            if breakdown.isEmpty {
                // All 8 categories at zero — shows what will be tracked
                ForEach(MistakeCategory.allCases, id: \.self) { category in
                    HStack(spacing: 10) {
                        Text(category.icon)
                            .font(.system(size: 14))
                        Text(category.displayName)
                            .font(.custom("HelveticaNeue-Medium", size: 14))
                            .foregroundColor(.tsLabel)
                        Spacer()
                        Text("—")
                            .font(.custom("HelveticaNeue", size: 12))
                            .foregroundColor(.tsSecondary.opacity(0.4))
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.tsCard.opacity(0.5))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.tsBorder.opacity(0.15), lineWidth: 0.5)
                    )
                }

                // Guidance card — explains what target areas are
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "target")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.tsAccent)
                        .padding(.top, 2)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("These fill up as you go")
                            .font(.custom("HelveticaNeue-Bold", size: 14))
                            .foregroundColor(.tsLabel)
                        Text("Every time you use the keyboard or practice with your coach, Orbit spots patterns in your mistakes and tracks them here. The more you use it, the sharper this gets.")
                            .font(.custom("HelveticaNeue", size: 13))
                            .foregroundColor(.tsSecondary)
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.tsAccent.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.tsAccent.opacity(0.15), lineWidth: 1)
                        )
                )
            } else {
                // Expandable category sub-cards
                ForEach(breakdown, id: \.category) { item in
                    let color = categoryColor(item.category)
                    let isExpanded = expandedCategories.contains(item.category)
                    let mistakes = profile.active(category: item.category)

                    VStack(alignment: .leading, spacing: 0) {
                        // Header row — tap to expand/collapse
                        Button {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                if isExpanded {
                                    expandedCategories.remove(item.category)
                                } else {
                                    expandedCategories.insert(item.category)
                                }
                            }
                        } label: {
                            HStack(spacing: 10) {
                                Text(item.category.icon)
                                    .font(.system(size: 14))
                                Text(item.category.displayName)
                                    .font(.custom("HelveticaNeue-Medium", size: 14))
                                    .foregroundColor(.tsLabel)
                                Spacer()
                                Text("\(item.count) active")
                                    .font(.custom("HelveticaNeue", size: 12))
                                    .foregroundColor(.tsSecondary)
                                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.tsSecondary)
                            }
                            .padding(14)
                        }

                        // Expanded content — rule description + expandable quiz rows
                        if isExpanded {
                            VStack(alignment: .leading, spacing: 12) {
                                // Category rule/insight
                                Text(categoryInsight(item.category, mistakes: mistakes))
                                    .font(.custom("HelveticaNeue", size: 13))
                                    .foregroundColor(.tsSecondary)
                                    .lineSpacing(3)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding(.horizontal, 14)
                                    .padding(.top, 2)

                                Divider().opacity(0.15).padding(.horizontal, 14)

                                // Individual mistake rows — mini quiz
                                ForEach(mistakes.prefix(5)) { mistake in
                                    mistakeQuizRow(mistake: mistake, color: color)
                                }


                                if mistakes.count > 5 {
                                    Text("+ \(mistakes.count - 5) more")
                                        .font(.custom("HelveticaNeue", size: 11))
                                        .foregroundColor(color)
                                        .padding(.horizontal, 14)
                                }
                            }
                            .padding(.bottom, 14)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(color.opacity(0.05))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(color.opacity(0.12), lineWidth: 0.5)
                    )
                }

                // Recently graduated — celebration
                let recentlyMastered = profile.entries.filter {
                    guard let mastered = $0.masteredAt else { return false }
                    return Date().timeIntervalSince(mastered) < 7 * 86400  // last 7 days
                }
                if !recentlyMastered.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Text("🎓")
                                .font(.system(size: 16))
                            Text("GRADUATED")
                                .font(.custom("HelveticaNeue-Bold", size: 11))
                                .foregroundColor(Color(hex: "#34C759"))
                                .kerning(1.2)
                        }
                        ForEach(recentlyMastered.prefix(3)) { item in
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(hex: "#34C759"))
                                Text("\(truncatePhrase(item.userSaid)) → \(truncatePhrase(item.correctForm))")
                                    .font(.custom("HelveticaNeue", size: 12))
                                    .foregroundColor(.tsLabel)
                                    .strikethrough(true, color: .tsSecondary.opacity(0.4))
                            }
                        }
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "#34C759").opacity(0.06))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: "#34C759").opacity(0.15), lineWidth: 0.5)
                    )
                }

                // Progress summary
                let summary = profile.progressSummary
                if summary.total > 0 {
                    HStack {
                        Text("\(summary.mastered) mastered")
                            .font(.custom("HelveticaNeue-Medium", size: 12))
                            .foregroundColor(Color(hex: "#34C759"))
                        Text("·")
                            .foregroundColor(.tsSecondary)
                        Text("\(summary.total - summary.mastered) active")
                            .font(.custom("HelveticaNeue-Medium", size: 12))
                            .foregroundColor(.tsSecondary)
                        Spacer()
                        Text("\(profile.dueForReview.count) due")
                            .font(.custom("HelveticaNeue", size: 12))
                            .foregroundColor(.tsAccent)
                    }
                }
            }

            // Lightning Round — shelved for v1.1 (database-backed version)
            // Button and fullScreenCover kept in code but hidden from UI.
            // To re-enable: uncomment this block.
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color.tsCard : Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.tsBorder, lineWidth: 1)
        )
    }

    private func targetAreaRow(category: MistakeCategory, count: Int, color: Color) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(category.displayName)
                .font(.custom("HelveticaNeue-Medium", size: 14))
                .foregroundColor(.tsLabel)
            Spacer()
            Text("\(count) active")
                .font(.custom("HelveticaNeue", size: 12))
                .foregroundColor(.tsSecondary)
        }
        .padding(.vertical, 4)
    }

    // MARK: - Mistake Quiz Row

    @ViewBuilder
    private func mistakeQuizRow(mistake: MistakeEntry, color: Color) -> some View {
        let isMistakeExpanded = expandedMistakes.contains(mistake.id)

        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    if isMistakeExpanded {
                        expandedMistakes.remove(mistake.id)
                    } else {
                        expandedMistakes.insert(mistake.id)
                    }
                }
            } label: {
                HStack(spacing: 10) {
                    Circle()
                        .fill(color)
                        .frame(width: 6, height: 6)
                    Text(truncatePhrase(mistake.userSaid))
                        .font(.custom("HelveticaNeue-Medium", size: 13))
                        .foregroundColor(.tsLabel)
                        .lineLimit(1)
                    Spacer()
                    if mistake.seenCount > 1 {
                        Text("×\(mistake.seenCount)")
                            .font(.custom("HelveticaNeue-Bold", size: 10))
                            .foregroundColor(color.opacity(0.7))
                    }
                    Image(systemName: isMistakeExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.tsSecondary.opacity(0.5))
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 14)
            }

            if isMistakeExpanded {
                mistakeQuizContent(mistake: mistake, color: color)
            }
        }
    }

    @ViewBuilder
    private func mistakeQuizContent(mistake: MistakeEntry, color: Color) -> some View {
        let isRevealed = revealedAnswers.contains(mistake.id)

        VStack(alignment: .leading, spacing: 10) {
            if !isRevealed {
                Text("What's the correction?")
                    .font(.custom("HelveticaNeue", size: 12))
                    .foregroundColor(.tsSecondary)
                    .italic()

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        _ = revealedAnswers.insert(mistake.id)
                    }
                } label: {
                    Text("Show Answer")
                        .font(.custom("HelveticaNeue-Medium", size: 13))
                        .foregroundColor(.tsAccent)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .stroke(Color.tsAccent.opacity(0.3), lineWidth: 1)
                        )
                }
            } else {
                HStack(spacing: 6) {
                    Text(truncatePhrase(mistake.userSaid))
                        .font(.custom("HelveticaNeue", size: 13))
                        .foregroundColor(Color(hex: "#FF3B30").opacity(0.7))
                        .strikethrough()
                    Text("→")
                        .font(.custom("HelveticaNeue", size: 13))
                        .foregroundColor(.tsSecondary)
                    Text(truncatePhrase(mistake.correctForm))
                        .font(.custom("HelveticaNeue-Bold", size: 13))
                        .foregroundColor(Color(hex: "#34C759"))
                }

                Text(truncateExplanation(mistake.explanation))
                    .font(.custom("HelveticaNeue", size: 12))
                    .foregroundColor(.tsSecondary)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 12) {
                    Button {
                        MistakeProfileStore.shared.markCorrect(id: mistake.id)
                        withAnimation { expandedMistakes.remove(mistake.id) }
                    } label: {
                        Text("Got it ✓")
                            .font(.custom("HelveticaNeue-Medium", size: 12))
                            .foregroundColor(Color(hex: "#34C759"))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 5)
                            .background(Capsule().fill(Color(hex: "#34C759").opacity(0.1)))
                    }
                    Button {
                        MistakeProfileStore.shared.markIncorrect(id: mistake.id)
                        withAnimation { expandedMistakes.remove(mistake.id) }
                    } label: {
                        Text("Still learning")
                            .font(.custom("HelveticaNeue-Medium", size: 12))
                            .foregroundColor(Color(hex: "#FF9500"))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 5)
                            .background(Capsule().fill(Color(hex: "#FF9500").opacity(0.1)))
                    }
                }
                .padding(.top, 4)

                if mistake.seenCount >= 3 {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 10))
                            .foregroundColor(Color(hex: "#FF9500"))
                        Text("You've made this mistake \(mistake.seenCount) times.")
                            .font(.custom("HelveticaNeue-Medium", size: 11))
                            .foregroundColor(Color(hex: "#FF9500"))
                    }
                }
            }
        }
        .padding(.horizontal, 30)
        .padding(.bottom, 10)
        .transition(.opacity)
    }

    /// Truncates long phrases to keep cards readable — shows just the key part.
    private func truncatePhrase(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.count <= 25 { return trimmed }
        let words = trimmed.split(separator: " ")
        var result = ""
        for word in words {
            if result.count + word.count + 1 > 25 { break }
            result += (result.isEmpty ? "" : " ") + word
        }
        return result + "…"
    }

    private func truncateExplanation(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.count <= 100 { return trimmed }
        // Take first sentence or first ~100 chars
        if let dotRange = trimmed.range(of: ".", range: trimmed.startIndex..<trimmed.index(trimmed.startIndex, offsetBy: min(120, trimmed.count))) {
            return String(trimmed[...dotRange.lowerBound]) + "."
        }
        let words = trimmed.split(separator: " ")
        var result = ""
        for word in words {
            if result.count + word.count + 1 > 100 { break }
            result += (result.isEmpty ? "" : " ") + word
        }
        return result + "…"
    }

    /// Generates a short insight for each category.
    private func categoryInsight(_ category: MistakeCategory, mistakes: [MistakeEntry]) -> String {
        let langName = LanguageManager.shared.targetLangName ?? "the target language"

        switch category {
        case .grammar:
            return "Structural patterns your English brain defaults to incorrectly."

        case .pronunciation:
            return "Sounds that don't exist in English — practice slowly."

        case .vocabulary:
            return "False friends — words that look like English but mean something different."

        case .gender:
            return "English has no grammatical gender, so your brain guesses. Learn the patterns."

        case .conjugation:
            return "Verb forms your brain keeps defaulting to the wrong way."

        case .wordOrder:
            return "Word order that works in English but not in \(langName)."

        case .preposition:
            return "Each verb has its own preposition — they never match English."

        case .idiom:
            return "Expressions that don't translate literally. Use them to sound local."
        }
    }

    private func shortenExplanation(_ text: String) -> String {
        var cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        // Strip common verbose patterns
        let patterns = [
            "In Portuguese, ", "In Spanish, ", "In French, ", "In German, ",
            "In the target language, ", "Native speakers ", "A native speaker would ",
        ]
        for pattern in patterns {
            if cleaned.hasPrefix(pattern) {
                cleaned = String(cleaned.dropFirst(pattern.count))
                cleaned = cleaned.prefix(1).uppercased() + cleaned.dropFirst()
            }
        }
        return cleaned
    }

    /// Trims explanation to one sentence for the condensed view.
    private func capToOneSentence(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if let dotRange = trimmed.range(of: ". ", range: trimmed.startIndex..<trimmed.endIndex) {
            return String(trimmed[trimmed.startIndex...dotRange.lowerBound])
        }
        if let dotEnd = trimmed.range(of: ".", options: .backwards) {
            // If there's only one sentence ending with a period, return it
            let firstSentence = String(trimmed[trimmed.startIndex...dotEnd.lowerBound])
            if firstSentence.count <= 80 { return firstSentence }
        }
        // Truncate if too long
        if trimmed.count > 70 {
            let idx = trimmed.index(trimmed.startIndex, offsetBy: 67)
            return String(trimmed[trimmed.startIndex..<idx]) + "..."
        }
        return trimmed
    }

    private func categoryColor(_ category: MistakeCategory) -> Color {
        switch category {
        case .grammar:       return Color.tsAccent
        case .pronunciation: return Color(hex: "#34C759")
        case .vocabulary:    return Color(hex: "#FF9500")
        case .gender:        return Color(hex: "#AF52DE")
        case .conjugation:   return Color(hex: "#FF2D55")
        case .wordOrder:     return Color(hex: "#5AC8FA")
        case .preposition:   return Color(hex: "#FF9500")
        case .idiom:         return Color(hex: "#FFD60A")
        }
    }

    // MARK: - 5. Talk (Pronunciation Drill) Card

    private var talkCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("💬")
                    .font(.system(size: 16))
                Text("TALK")
                    .font(.custom("HelveticaNeue-Bold", size: 11))
                    .foregroundColor(.tsSecondary)
                    .kerning(1.2)
                Spacer()
            }

            Text("Your R sound needs work. Try saying this:")
                .font(.custom("HelveticaNeue", size: 14))
                .foregroundColor(.tsLabel)
                .lineSpacing(2)

            // Word to practice
            VStack(spacing: 12) {
                Text("porta")
                    .font(.custom("HelveticaNeue-Bold", size: 28))
                    .foregroundColor(.tsLabel)
                    .padding(.top, 12)

                Text("(door)")
                    .font(.custom("HelveticaNeue", size: 13))
                    .foregroundColor(.tsSecondary)

                HStack(spacing: 16) {
                    Button { showTalkDrill = true } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.system(size: 14))
                            Text("Hear it")
                                .font(.custom("HelveticaNeue-Medium", size: 14))
                        }
                        .foregroundColor(.tsAccent)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.tsAccent.opacity(0.1))
                        .clipShape(Capsule())
                    }

                    Button { showTalkDrill = true } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "mic.fill")
                                .font(.system(size: 14))
                            Text("Try it")
                                .font(.custom("HelveticaNeue-Medium", size: 14))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(LinearGradient.tsVibrant)
                        .clipShape(Capsule())
                    }
                }
                .padding(.bottom, 12)
            }
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(colorScheme == .dark ? Color.tsCard.opacity(0.5) : Color.white.opacity(0.6))
            )

            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Image(systemName: "flame")
                        .font(.system(size: 11))
                    Text("3 sounds to work on")
                        .font(.custom("HelveticaNeue", size: 11))
                }
                Spacer()
                Text("Attempt 1/3")
                    .font(.custom("HelveticaNeue-Medium", size: 11))
            }
            .foregroundColor(.tsSecondary)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.tsCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.tsBorder, lineWidth: 1)
        )
        .sheet(isPresented: $showTalkDrill) {
            TalkDrillView()
        }
    }

    // MARK: - 6. Practice Mode Card

    private var practiceCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image("SolAvaatar")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 24, height: 24)
                    .clipShape(Circle())
                Text("CONVERSATION")
                    .font(.custom("HelveticaNeue-Bold", size: 11))
                    .foregroundColor(.tsSecondary)
                    .kerning(1.2)
                Spacer()
            }

            Text("You've been struggling with past subjunctive. Want to work on it?")
                .font(.custom("HelveticaNeue", size: 14))
                .foregroundColor(.tsLabel)
                .lineSpacing(2)

            Button {
                if SelfReportedLevel.hasCompleted {
                    showPracticeSession = true
                } else {
                    assessmentDestination = "practice"
                    showLevelAssessment = true
                }
            } label: {
                Text("Start Session")
                    .font(.custom("HelveticaNeue-Medium", size: 16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Capsule().fill(Color.tsAccent))
            }

            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 11))
                    Text("Last session: 2 days ago")
                        .font(.custom("HelveticaNeue", size: 11))
                }
                HStack(spacing: 4) {
                    Image(systemName: "flame")
                        .font(.system(size: 11))
                    Text("Sessions this week: 3")
                        .font(.custom("HelveticaNeue", size: 11))
                }
            }
            .foregroundColor(.tsSecondary)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color.tsCard : Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.tsBorder, lineWidth: 1)
        )
    }

    // MARK: - 6. Milestones

    private var milestonesCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("🏆")
                    .font(.system(size: 16))
                Text("MILESTONES")
                    .font(.custom("HelveticaNeue-Bold", size: 11))
                    .foregroundColor(.tsSecondary)
                    .kerning(1.2)
                Spacer()
                Text("3 graduated · 2 in progress")
                    .font(.custom("HelveticaNeue", size: 11))
                    .foregroundColor(.tsSecondary)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 12) {
                    milestoneBadge(label: "Ser vs\nEstar", status: .graduated, month: "Oct")
                    milestoneBadge(label: "Gender\nAgreement", status: .graduated, month: "Nov")
                    milestoneBadge(label: "Article\nUsage", status: .graduated, month: "Dec")
                    milestoneBadge(label: "Preposition\nA vs Em", status: .inProgress(14, 20), month: nil)
                    milestoneBadge(label: "Past\nSubjunctive", status: .inProgress(6, 20), month: nil)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.tsCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.tsBorder, lineWidth: 1)
        )
    }

    enum MilestoneStatus {
        case graduated
        case inProgress(Int, Int)

        var isGraduated: Bool {
            if case .graduated = self { return true }
            return false
        }
    }

    private func milestoneBadge(label: String, status: MilestoneStatus, month: String?) -> some View {
        VStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(status.isGraduated ? Color(hex: "#34C759").opacity(0.12) : Color.tsSecondary.opacity(0.08))
                    .frame(width: 64, height: 64)

                if status.isGraduated {
                    Image(systemName: "checkmark")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(hex: "#34C759"))
                } else if case .inProgress(let current, let total) = status {
                    VStack(spacing: 6) {
                        // Progress bar only — no numbers
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.tsSecondary.opacity(0.2))
                                    .frame(height: 4)
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.tsAccent)
                                    .frame(width: geo.size.width * CGFloat(current) / CGFloat(total), height: 4)
                            }
                        }
                        .frame(width: 44, height: 4)

                        // Human-readable status
                        let pct = Double(current) / Double(total)
                        Text(pct >= 0.75 ? "Almost there" : pct >= 0.4 ? "Getting closer" : "Just started")
                            .font(.custom("HelveticaNeue", size: 9))
                            .foregroundColor(.tsAccent)
                    }
                }
            }

            Text(label)
                .font(.custom("HelveticaNeue-Medium", size: 10))
                .foregroundColor(.tsLabel)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 72)

            if let m = month {
                Text(m)
                    .font(.custom("HelveticaNeue", size: 10))
                    .foregroundColor(.tsSecondary)
            }
        }
    }
}


// MARK: - Weekly Full Report (sheet)

struct WeeklyFullReportView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationView {
            ZStack {
                TSGradientBackground().ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {

                        // ── Header ──────────────────────────────
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Weekly Report")
                                .font(.custom("HelveticaNeue-Bold", size: 24))
                                .foregroundColor(.tsLabel)
                            Text(PracticeStatsStore.shared.weekRangeString + ", 2026")
                                .font(.custom("HelveticaNeue", size: 14))
                                .foregroundColor(.tsSecondary)
                        }

                        // ── Wins ────────────────────────────────
                        reportSection(title: "WINS", icon: "🎉") {
                            let profile = MistakeProfileStore.shared
                            let weekStart = Calendar(identifier: .iso8601).dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
                            let mastered = profile.entries.filter { $0.masteredAt != nil && $0.masteredAt! >= weekStart }
                            let stats = PracticeStatsStore.shared

                            VStack(alignment: .leading, spacing: 10) {
                                if !mastered.isEmpty {
                                    ForEach(mastered.prefix(3), id: \.id) { item in
                                        reportRow("Graduated: '\(item.correctForm)'")
                                    }
                                }
                                if stats.weeklySessionCount > 0 {
                                    reportRow("\(stats.weeklySessionCount) practice session\(stats.weeklySessionCount == 1 ? "" : "s") completed")
                                }
                                if stats.currentStreak > 1 {
                                    reportRow("\(stats.currentStreak)-day practice streak")
                                }
                                if mastered.isEmpty && stats.weeklySessionCount == 0 {
                                    reportRow("Get started this week — every session counts")
                                }
                            }
                        }

                        // ── Work On ─────────────────────────────
                        reportSection(title: "WORK ON", icon: "📝") {
                            let breakdown = MistakeProfileStore.shared.categoryBreakdown

                            VStack(alignment: .leading, spacing: 10) {
                                if breakdown.isEmpty {
                                    reportRow("No patterns flagged yet — keep using the keyboard and practicing")
                                } else {
                                    ForEach(breakdown.prefix(3), id: \.category) { item in
                                        let accuracy = MistakeProfileStore.shared.categoryAccuracy(item.category)
                                        reportRow("\(item.category.displayName): \(item.count) active\(accuracy > 0 ? " (\(accuracy)% accuracy)" : "")")
                                    }
                                }
                            }
                        }

                        // ── By the Numbers ──────────────────────
                        reportSection(title: "BY THE NUMBERS", icon: "📊") {
                            let stats = PracticeStatsStore.shared
                            let rounds = LightningRoundEngine.shared.loadRoundHistory()
                            let weekRounds = rounds.filter {
                                Calendar.current.isDate($0.date, equalTo: Date(), toGranularity: .weekOfYear)
                            }
                            let avgScore = weekRounds.isEmpty ? 0 :
                                weekRounds.reduce(0) { $0 + $1.scorePercent } / weekRounds.count

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                numberCard(value: "\(stats.weeklyMessageCount)", label: "Messages")
                                numberCard(value: "\(stats.weeklySessionCount)", label: "Sessions")
                                numberCard(value: "\(stats.weeklyPracticeMinutes)", label: "Min practice")
                                numberCard(value: avgScore > 0 ? "\(avgScore)%" : "—", label: "Avg score")
                            }
                        }

                        // ── Trends ──────────────────────────────
                        reportSection(title: "TRENDS", icon: "📈") {
                            let store = UserLevelStore.shared
                            let colorMap: [SkillCategory: Color] = [
                                .pronunciation: Color(hex: "#34C759"),
                                .grammar: Color(hex: "#007AFF"),
                                .vocabulary: Color(hex: "#FF9500"),
                                .fluency: Color(hex: "#AF52DE"),
                            ]

                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(SkillCategory.allCases, id: \.self) { skill in
                                    if let assessment = store.skills[skill] {
                                        let dir = assessment.progress > 0.5 ? "↑" : assessment.progress > 0.3 ? "→" : "↓"
                                        let detail = assessment.progress > 0.5 ? "improving" :
                                            assessment.progress > 0.3 ? "steady" : "needs focus"
                                        trendRow(
                                            category: skill.displayName,
                                            direction: dir,
                                            detail: "\(assessment.level.rawValue) — \(detail)",
                                            color: colorMap[skill] ?? .tsAccent
                                        )
                                    }
                                }
                                if store.skills.isEmpty {
                                    reportRow("Complete your level assessment to see trends")
                                }
                            }
                        }

                        // ── Focus ────────────────────────────────
                        reportSection(title: "FOCUS THIS WEEK", icon: "🎯") {
                            let weakest = MistakeProfileStore.shared.categoryBreakdown.max(by: { $0.count < $1.count })

                            VStack(alignment: .leading, spacing: 8) {
                                if let weak = weakest {
                                    Text("Focus on \(weak.category.displayName.lowercased()) — \(weak.count) active patterns to work through.")
                                        .font(.custom("HelveticaNeue", size: 14))
                                        .foregroundColor(.tsLabel)
                                        .lineSpacing(2)
                                    Text("Practice with Sol to work through these patterns.")
                                        .font(.custom("HelveticaNeue", size: 13))
                                        .foregroundColor(.tsSecondary)
                                        .italic()
                                } else {
                                    Text("Keep practicing with Sol — mistakes become your personalized curriculum.")
                                        .font(.custom("HelveticaNeue", size: 14))
                                        .foregroundColor(.tsLabel)
                                        .lineSpacing(2)
                                }
                            }
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.custom("HelveticaNeue-Medium", size: 16))
                        .foregroundColor(.tsAccent)
                }
            }
        }
    }

    private func reportSection<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Text(icon)
                    .font(.system(size: 14))
                Text(title)
                    .font(.custom("HelveticaNeue-Bold", size: 11))
                    .foregroundColor(.tsSecondary)
                    .kerning(1.2)
            }
            content()
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.tsBorder, lineWidth: 1)
        )
    }

    private func reportRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(Color.tsAccent.opacity(0.4))
                .frame(width: 6, height: 6)
                .padding(.top, 6)
            Text(text)
                .font(.custom("HelveticaNeue", size: 14))
                .foregroundColor(.tsLabel)
                .lineSpacing(2)
        }
    }

    private func numberCard(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.custom("HelveticaNeue-Bold", size: 24))
                .foregroundColor(.tsLabel)
            Text(label)
                .font(.custom("HelveticaNeue", size: 12))
                .foregroundColor(.tsSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.tsBorder, lineWidth: 1)
        )
    }

    private func trendRow(category: String, direction: String, detail: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(category)
                .font(.custom("HelveticaNeue-Medium", size: 14))
                .foregroundColor(.tsLabel)
                .frame(width: 100, alignment: .leading)
            Text(direction)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(direction == "↑" ? Color(hex: "#34C759") : .tsSecondary)
            Text(detail)
                .font(.custom("HelveticaNeue", size: 13))
                .foregroundColor(.tsSecondary)
            Spacer()
        }
    }
}

// MARK: - Level Detail View

struct LevelDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    private struct SkillLevel {
        let label: String
        let level: String
        let progress: CGFloat
        let color: Color
    }

    private var skills: [SkillLevel] {
        let store = UserLevelStore.shared
        let colorMap: [SkillCategory: Color] = [
            .pronunciation: Color(hex: "#34C759"),
            .grammar: Color(hex: "#007AFF"),
            .vocabulary: Color(hex: "#FF9500"),
            .fluency: Color(hex: "#AF52DE"),
        ]
        return SkillCategory.allCases.map { cat in
            let assessment = store.skills[cat]
            return SkillLevel(
                label: cat.displayName,
                level: assessment?.level.rawValue ?? "A1",
                progress: CGFloat(assessment?.progress ?? 0.1),
                color: colorMap[cat] ?? .tsAccent
            )
        }
    }

    private let cefrDescriptions: [String: (title: String, meaning: String)] = [
        "A1": ("Beginner", "You can understand and use basic phrases — greetings, introductions, simple questions. Enough to survive, not enough to connect."),
        "A2": ("Elementary", "You can handle short, routine exchanges — ordering food, asking directions, basic small talk. You get the gist but miss the nuance."),
        "B1": ("Intermediate", "You can deal with most situations while traveling or living abroad. You can describe experiences, give opinions, and follow the main point of conversations."),
        "B2": ("Upper Intermediate", "You can interact with native speakers fluently enough that it's not a strain for either side. You understand complex texts and can argue a viewpoint."),
        "C1": ("Advanced", "You can express yourself fluently and spontaneously. You use language flexibly for social, academic, and professional purposes."),
        "C2": ("Mastery", "You can understand virtually everything heard or read. You can summarize, reconstruct, and express yourself spontaneously with precision."),
    ]

    private func bridgingTips(for skill: SkillLevel) -> [String] {
        guard skill.progress > 0.5 else { return [] }

        switch skill.label {
        case "Pronunciation":
            if skill.level == "B1" {
                return [
                    "Focus on word stress patterns — misplaced stress is the #1 giveaway",
                    "Practice connected speech: how words blend together naturally",
                    "Record yourself and compare with native audio from your practice sessions",
                ]
            } else {
                return [
                    "Work on intonation patterns for questions vs. statements",
                    "Practice minimal pairs — sounds that are similar but change meaning",
                ]
            }
        case "Grammar":
            if skill.level == "B1" {
                return [
                    "Subjunctive mood — it's the bridge between sounding competent and sounding natural",
                    "Practice complex sentence structures: relative clauses, conditionals",
                    "Pay attention to preposition choices — they rarely translate 1:1",
                ]
            } else {
                return [
                    "Master verb conjugations for the tenses you use most",
                    "Focus on gender/number agreement in longer sentences",
                ]
            }
        case "Vocabulary":
            if skill.level == "B2" {
                return [
                    "You're close to C1 — start incorporating idiomatic expressions",
                    "Learn synonyms to avoid repeating the same words",
                    "Pick up register awareness: when to use formal vs. casual alternatives",
                ]
            } else {
                return [
                    "Build topic-specific vocabulary for your daily life",
                    "Learn collocations — words that naturally go together",
                ]
            }
        case "Fluency":
            if skill.level == "A2" {
                return [
                    "Increase your response speed — practice thinking in the target language",
                    "Use filler words and discourse markers that native speakers use",
                    "Don't translate in your head first — try to form thoughts directly",
                ]
            } else {
                return [
                    "Practice longer stretches of speech without pausing",
                    "Work on transitioning between topics smoothly",
                ]
            }
        default:
            return []
        }
    }

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {

                    // ── Overall level ──────────────────────────
                    VStack(spacing: 8) {
                        let overall = UserLevelStore.shared.overallLevel
                        Text(overall.rawValue)
                            .font(.custom("HelveticaNeue-Bold", size: 48))
                            .foregroundColor(.tsAccent)
                        Text(overall.title)
                            .font(.custom("HelveticaNeue-Medium", size: 16))
                            .foregroundColor(.tsLabel)
                        Text("Your overall level across all categories")
                            .font(.custom("HelveticaNeue", size: 13))
                            .foregroundColor(.tsSecondary)
                    }
                    .padding(.top, 8)

                    // ── What this means ────────────────────────
                    VStack(alignment: .leading, spacing: 12) {
                        let overall = UserLevelStore.shared.overallLevel
                        Text("WHAT \(overall.rawValue) MEANS")
                            .font(.custom("HelveticaNeue-Bold", size: 11))
                            .foregroundColor(.tsSecondary)
                            .kerning(1.2)

                        Text(cefrDescriptions[overall.rawValue]?.meaning ?? overall.description)
                            .font(.custom("HelveticaNeue", size: 14))
                            .foregroundColor(.tsLabel)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.tsCard)
                    )

                    // ── Category breakdown ─────────────────────
                    ForEach(skills, id: \.label) { skill in
                        let desc = cefrDescriptions[skill.level]
                        let tips = bridgingTips(for: skill)

                        VStack(alignment: .leading, spacing: 12) {
                            // Header row
                            HStack {
                                Circle()
                                    .fill(skill.color)
                                    .frame(width: 10, height: 10)
                                Text(skill.label)
                                    .font(.custom("HelveticaNeue-Bold", size: 16))
                                    .foregroundColor(.tsLabel)
                                Spacer()
                                Text(skill.level)
                                    .font(.custom("HelveticaNeue-Bold", size: 20))
                                    .foregroundColor(skill.color)
                            }

                            // Progress bar
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(skill.color.opacity(0.12))
                                        .frame(height: 8)
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(
                                            LinearGradient(
                                                colors: [skill.color.opacity(0.7), skill.color],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: geo.size.width * skill.progress, height: 8)
                                }
                            }
                            .frame(height: 8)

                            // Level description
                            HStack(spacing: 4) {
                                Text(skill.level)
                                    .font(.custom("HelveticaNeue-Bold", size: 12))
                                    .foregroundColor(skill.color)
                                Text("— \(desc?.title ?? "")")
                                    .font(.custom("HelveticaNeue-Medium", size: 12))
                                    .foregroundColor(.tsSecondary)
                                Spacer()
                                Text("\(Int(skill.progress * 100))% to next level")
                                    .font(.custom("HelveticaNeue", size: 11))
                                    .foregroundColor(.tsSecondary)
                            }

                            // Bridging tips (only if >50% progress)
                            if !tips.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("TO REACH THE NEXT LEVEL")
                                        .font(.custom("HelveticaNeue-Bold", size: 10))
                                        .foregroundColor(skill.color)
                                        .kerning(0.8)

                                    ForEach(tips, id: \.self) { tip in
                                        HStack(alignment: .top, spacing: 8) {
                                            Image(systemName: "arrow.right.circle.fill")
                                                .font(.system(size: 11))
                                                .foregroundColor(skill.color.opacity(0.6))
                                                .padding(.top, 2)
                                            Text(tip)
                                                .font(.custom("HelveticaNeue", size: 13))
                                                .foregroundColor(.tsLabel)
                                                .lineSpacing(2)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                    }
                                }
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(skill.color.opacity(0.04))
                                )
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.tsCard)
                        )
                    }

                    // ── CEFR scale reference ──────────────────
                    VStack(alignment: .leading, spacing: 12) {
                        Text("CEFR SCALE")
                            .font(.custom("HelveticaNeue-Bold", size: 11))
                            .foregroundColor(.tsSecondary)
                            .kerning(1.2)

                        ForEach(["A1", "A2", "B1", "B2", "C1", "C2"], id: \.self) { level in
                            let desc = cefrDescriptions[level]
                            HStack(alignment: .top, spacing: 12) {
                                Text(level)
                                    .font(.custom("HelveticaNeue-Bold", size: 14))
                                    .foregroundColor(level == "B1" ? .tsAccent : .tsSecondary)
                                    .frame(width: 28, alignment: .leading)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(desc?.title ?? "")
                                        .font(.custom("HelveticaNeue-Medium", size: 13))
                                        .foregroundColor(level == "B1" ? .tsLabel : .tsSecondary)
                                    Text(desc?.meaning ?? "")
                                        .font(.custom("HelveticaNeue", size: 12))
                                        .foregroundColor(.tsSecondary)
                                        .lineSpacing(2)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            .padding(.vertical, 4)
                            if level != "C2" {
                                Divider()
                            }
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.tsCard)
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
            .background(TSGradientBackground().ignoresSafeArea())
            .navigationTitle("Your Level")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.tsSecondary)
                    }
                }
            }
        }
    }
}

// MARK: - Practice Session (full-screen chat)

struct PracticeSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("talkswitch_target_lang",
                store: UserDefaults(suiteName: "group.com.jeff.translatehelper"))
    private var targetLang = LanguageManager.shared.targetLangRequired

    // Flag + accent color derived from target language
    private var langFlag: String {
        let flags: [String: String] = [
            "es": "🇪🇸", "pt": "🇧🇷", "fr": "🇫🇷", "de": "🇩🇪", "it": "🇮🇹",
            "ja": "🇯🇵", "ko": "🇰🇷", "zh": "🇨🇳", "ar": "🇦🇪", "en": "🇺🇸",
            "nl": "🇳🇱", "ru": "🇷🇺", "pl": "🇵🇱", "tr": "🇹🇷", "sv": "🇸🇪",
            "da": "🇩🇰", "fi": "🇫🇮", "el": "🇬🇷", "cs": "🇨🇿", "ro": "🇷🇴",
            "hu": "🇭🇺", "uk": "🇺🇦", "id": "🇮🇩", "ms": "🇲🇾", "th": "🇹🇭",
            "vi": "🇻🇳", "hi": "🇮🇳", "bn": "🇧🇩", "ta": "🇱🇰", "he": "🇮🇱",
            "no": "🇳🇴", "sk": "🇸🇰", "bg": "🇧🇬", "hr": "🇭🇷", "lt": "🇱🇹",
            "lv": "🇱🇻", "et": "🇪🇪", "sl": "🇸🇮", "sw": "🇰🇪",
        ]
        return flags[targetLang] ?? "🌐"
    }

    /// Accent color inspired by the target language's flag
    private var langAccentColor: Color {
        let colors: [String: String] = [
            "es": "#C60B1E",  // Spanish red
            "pt": "#009739",  // Brazilian green
            "fr": "#002395",  // French blue
            "de": "#DD0000",  // German red
            "it": "#008C45",  // Italian green
            "ja": "#BC002D",  // Japanese red
            "ko": "#003478",  // Korean blue
            "zh": "#DE2910",  // Chinese red
            "ar": "#007A3D",  // UAE/Arabic green
            "nl": "#FF4F00",  // Dutch orange
            "ru": "#0039A6",  // Russian blue
            "pl": "#DC143C",  // Polish red
            "tr": "#E30A17",  // Turkish red
            "sv": "#006AA7",  // Swedish blue
        ]
        return Color(hex: colors[targetLang] ?? "#34C759")
    }

    private var langName: String {
        let map: [String: String] = [
            "es": "Spanish", "pt": "Portuguese", "fr": "French", "de": "German",
            "it": "Italian", "ja": "Japanese", "ko": "Korean", "zh": "Chinese",
            "ar": "Arabic", "nl": "Dutch", "ru": "Russian", "pl": "Polish",
            "tr": "Turkish", "sv": "Swedish", "da": "Danish", "fi": "Finnish",
            "el": "Greek", "cs": "Czech", "ro": "Romanian", "hu": "Hungarian",
            "uk": "Ukrainian", "id": "Indonesian", "ms": "Malay", "th": "Thai",
            "vi": "Vietnamese", "hi": "Hindi", "bn": "Bengali", "ta": "Tamil",
            "he": "Hebrew", "no": "Norwegian", "en": "English",
        ]
        return map[targetLang] ?? "Spanish"
    }

    @State private var userInput = ""
    @State private var currentTopicIndex = 0
    @State private var swipeOffset: CGFloat = 0

    // Topic prompts sent to GPT — Sol generates the actual message
    // in the right language, dialect, and city context automatically.
    // These are just topic DIRECTIONS, not hardcoded messages.
    @State private var recentTopicTags: [String] = []  // last 5 topic tags — prevents repeats
    @State private var isLoadingTopic = false
    @State private var preloadedSolMessage: PracticeMessage?  // next topic pre-generated in background
    @State private var preloadedSlangNotes: [PracticeConversationService.SlangNote] = []
    @State private var isPreloading = false

    @State private var messages: [PracticeMessage] = []

    @State private var messageCount = 0
    @State private var revealedTranslations: Set<UUID> = []
    @State private var showDoubleTapHint = false
    @State private var showPlaybackHint = false
    @AppStorage("practice_playback_validated") private var playbackValidated = false
    @State private var showSwipeRightHint = true   // shows first, dismissed after first right swipe
    @State private var showSwipeLeftHint = false    // shows after first right swipe, dismissed after first left swipe
    @AppStorage("practice_swipe_right_done") private var swipeRightDone = false
    @AppStorage("practice_swipe_left_done") private var swipeLeftDone = false
    @State private var isRecording = false
    @State private var recordingSeconds = 0
    @State private var recordingTimer: Timer?
    @State private var revealedText: Set<UUID> = []      // messages whose text has faded in
    @State private var hasInitialized = false             // prevents onAppear from double-firing
    @State private var isPlayingSolAudio = false          // global lock — only one Sol audio at a time
    @State private var playingAudio: UUID?                // message currently playing audio
    @State private var isSendingRecording2 = false        // guard for stopAndSendRecording
    @State private var isFetchingSolResponse2 = false     // guard for fetchSolResponse
    private let ttsService = PracticeTTSService()
    @AppStorage("practice_doubletap_validated") private var doubleTapValidated = false
    @AppStorage("practice_doubletap_dismiss_count") private var doubleTapDismissCount = 0
    @State private var showNativeHint = false
    @State private var nativeHintShownForMessage: UUID?  // show hint after this specific message
    @State private var revealedNative: Set<UUID> = []
    @AppStorage("practice_native_validated") private var nativeDoubleTapValidated = false
    @AppStorage("practice_native_dismiss_count") private var nativeDismissCount = 0
    private var hasShownFirstUserMessage = false
    @State private var savedPhrases: Set<String> = []       // phrases already saved this session
    @State private var savedMessageIds: Set<UUID> = []     // message IDs saved (for visual feedback)
    @State private var showSaveHint = false
    @State private var saveHintShownForMessage: UUID?
    @AppStorage("practice_save_validated") private var saveValidated = false
    @State private var showSettingsHint = false
    @AppStorage("practice_settings_hint_shown") private var settingsHintShown = false
    @State private var showWordSaveHint = false
    @AppStorage("practice_word_save_hint_shown") private var wordSaveHintShown = false
    @State private var wordSaveMessage: PracticeMessage? = nil  // triggers the zoomed overlay
    @State private var totalMessagesThisSession = 0
    @State private var sessionSeconds = 0
    @State private var sessionTimer: Timer?

    // Session settings
    @AppStorage("practice_tone") private var practiceTone = "casual"
    @AppStorage("practice_who_starts") private var solStarts = true
    @State private var showSettings = false

    var body: some View {
        ZStack {
            TSGradientBackground().ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Header ──────────────────────────────────
                HStack {
                    Button { endAndDismiss() } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                            Text("End session")
                                .font(.custom("HelveticaNeue-Medium", size: 15))
                        }
                        .foregroundColor(.tsAccent)
                    }

                    Spacer()

                    // Settings gear
                    Button {
                        showSettings = true
                        // Dismiss the coaching hint — they found settings
                        if showSettingsHint {
                            showSettingsHint = false
                            settingsHintShown = true
                        }
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 15))
                            .foregroundColor(.tsAccent)
                            .padding(6)
                            .background(Color.tsCard)
                            .clipShape(Circle())
                    }

                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color(hex: "#34C759"))
                            .frame(width: 6, height: 6)
                        Text(formatSessionTime(sessionSeconds))
                            .font(.custom("HelveticaNeue-Medium", size: 13))
                            .foregroundColor(.tsSecondary)
                            .monospacedDigit()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.tsCard)
                    .clipShape(Capsule())
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)

                Divider().opacity(0.2)

                // ── Chat messages ────────────────────────────
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            ForEach(Array(messages.enumerated()), id: \.element.id) { index, message in
                                // No implicit animation on message insertion
                                chatBubble(message: message)
                                    // Swipe gesture on Sol's first message — right = new topic (matches keyboard)
                                    .offset(x: (index == 0 && message.role == .sol && !isLoadingTopic) ? swipeOffset : 0)
                                    .rotationEffect(
                                        (index == 0 && message.role == .sol && !isLoadingTopic)
                                        ? .degrees(Double(swipeOffset) / 25.0)
                                        : .degrees(0)
                                    )
                                    .opacity((index == 0 && message.role == .sol && messageCount == 0 && abs(swipeOffset) > 200) ? 0 : 1)
                                    .gesture(
                                        (index == 0 && message.role == .sol && !isLoadingTopic) ?
                                        DragGesture()
                                            .onChanged { gesture in
                                                let tx = gesture.translation.width
                                                swipeOffset = tx
                                            }
                                            .onEnded { gesture in
                                                if gesture.translation.width > 90 {
                                                    // Right swipe — fly off right with rotation (new topic)
                                                    withAnimation(.easeOut(duration: 0.22)) {
                                                        swipeOffset = 500
                                                    }
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                                        swipeOffset = -400
                                                        swipeToNextTopic()
                                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                                            swipeOffset = 0
                                                        }
                                                    }
                                                } else if gesture.translation.width < -90 {
                                                    // Left swipe — fly off left (go back if possible)
                                                    if currentTopicIndex > 0 {
                                                        // First left swipe — dismiss left hint, all hints done
                                                        if !swipeLeftDone {
                                                            swipeLeftDone = true
                                                            withAnimation { showSwipeLeftHint = false }
                                                            // Now show double-tap hint
                                                            if !doubleTapValidated {
                                                                withAnimation(.easeIn(duration: 0.3).delay(0.5)) {
                                                                    showDoubleTapHint = true
                                                                }
                                                            }
                                                        }

                                                        withAnimation(.easeOut(duration: 0.22)) {
                                                            swipeOffset = -500
                                                        }
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                                            swipeOffset = 400
                                                            currentTopicIndex -= 1
                                                            loadTopic(index: currentTopicIndex)
                                                            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                                                swipeOffset = 0
                                                            }
                                                        }
                                                    } else {
                                                        withAnimation(.spring()) { swipeOffset = 0 }
                                                    }
                                                } else {
                                                    // Snap back
                                                    withAnimation(.spring()) {
                                                        swipeOffset = 0
                                                    }
                                                }
                                            }
                                        : nil
                                    )
                                    .id(message.id)

                                // Show Sol double-tap hint after Sol's first message
                                if index == 0 && showDoubleTapHint {
                                    doubleTapHintCard
                                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                                }

                                // Show playback hint (after double-tap is validated)
                                if index == 0 && showPlaybackHint {
                                    playbackHintCard
                                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                                }

                                // Show native hint after the first user message
                                if message.id == nativeHintShownForMessage && showNativeHint {
                                    nativeHintCard
                                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                                }

                                // Show save hint after first coaching tip (once 5+ messages in)
                                if message.id == saveHintShownForMessage && showSaveHint {
                                    saveHintCard
                                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                                }

                                // Show word save hint after Sol's 2nd message
                                if index == 0 && showWordSaveHint {
                                    wordSaveHintCard
                                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                                }

                                // Show settings hint after 8+ messages (once per user)
                                if index == 0 && showSettingsHint {
                                    settingsHintCard
                                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                    .onChange(of: messages.count) {
                        if let last = messages.last {
                            withAnimation {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                    .onChange(of: revealedTranslations.count) {
                        if let last = messages.last {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                withAnimation {
                                    proxy.scrollTo(last.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                    .onChange(of: revealedNative.count) {
                        if let last = messages.last {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                withAnimation {
                                    proxy.scrollTo(last.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                }

                // ── Input bar ────────────────────────────────
                VStack(spacing: 0) {
                    Divider().opacity(0.2)

                    if isRecording {
                        // ── Recording mode ──────────────────────
                        HStack(spacing: 16) {
                            // Trash (cancel)
                            Button { cancelRecording() } label: {
                                Image(systemName: "trash.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.red.opacity(0.7))
                                    .frame(width: 36, height: 36)
                            }

                            // Recording indicator
                            HStack(spacing: 10) {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 8, height: 8)
                                    .opacity(recordingSeconds % 2 == 0 ? 1 : 0.3)

                                // Waveform placeholder
                                HStack(spacing: 2) {
                                    ForEach(0..<12, id: \.self) { i in
                                        RoundedRectangle(cornerRadius: 1)
                                            .fill(Color.tsAccent.opacity(0.5))
                                            .frame(width: 2, height: CGFloat.random(in: 6...20))
                                    }
                                }

                                Text(formatTime(recordingSeconds))
                                    .font(.custom("HelveticaNeue-Medium", size: 14))
                                    .foregroundColor(.tsLabel)
                                    .monospacedDigit()
                            }
                            .frame(maxWidth: .infinity)

                            // Send recording
                            Button { stopAndSendRecording() } label: {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.tsAccent)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color(red: 0.02, green: 0.48, blue: 1.0).opacity(colorScheme == .dark ? 0.08 : 0.05))
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    } else {
                        // ── Text input mode ─────────────────────
                        HStack(spacing: 12) {
                            TextField("Type in Portuguese...", text: $userInput)
                                .font(.custom("HelveticaNeue", size: 15))
                                .foregroundColor(.tsLabel)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(colorScheme == .dark ? Color.tsCard : Color.white)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.tsSecondary.opacity(0.15), lineWidth: 0.5)
                                )

                            // Mic button
                            Button { startRecording() } label: {
                                Image(systemName: "mic.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.tsAccent)
                                    .frame(width: 36, height: 36)
                                    .background(Color.tsAccent.opacity(0.12))
                                    .clipShape(Circle())
                            }

                            // Send button
                            Button { sendMessage() } label: {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(userInput.isEmpty ? .tsSecondary.opacity(0.4) : .tsAccent)
                            }
                            .disabled(userInput.isEmpty)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(colorScheme == .dark ? Color.tsCard : Color.white)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: isRecording)
            }
        }
        .onAppear {
            // CRITICAL: only initialize once — SwiftUI can call onAppear multiple times
            guard !hasInitialized else { return }
            hasInitialized = true

            ttsService.speakingRate = 1.05  // C-level: native speed

            if solStarts {
                loadTopic(index: 0)
            } else {
                // User starts — show empty chat with a hint
                messages = [
                    PracticeMessage(role: .coaching, text: "💡 You're up first — say whatever you want. Sol will respond naturally."),
                ]
                for msg in messages { revealedText.insert(msg.id) }
            }

            sessionTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                sessionSeconds += 1
            }

            // Pause timer when app goes to background, resume on foreground
            NotificationCenter.default.addObserver(
                forName: UIApplication.willResignActiveNotification,
                object: nil, queue: .main
            ) { _ in
                sessionTimer?.invalidate()
                sessionTimer = nil
            }
            NotificationCenter.default.addObserver(
                forName: UIApplication.didBecomeActiveNotification,
                object: nil, queue: .main
            ) { _ in
                if sessionTimer == nil {
                    sessionTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                        sessionSeconds += 1
                    }
                }
            }

            // TODO: Remove reset lines before shipping — forces hints to show during dev
            doubleTapValidated = false
            doubleTapDismissCount = 0
            nativeDoubleTapValidated = false
            nativeDismissCount = 0
            swipeRightDone = false
            swipeLeftDone = false

            // Show swipe right hint if not yet done
            showSwipeRightHint = !swipeRightDone
            showSwipeLeftHint = false

            if swipeRightDone && swipeLeftDone {
                // Both swipes done — show double-tap hint
                if !doubleTapValidated && doubleTapDismissCount < 3 {
                    withAnimation(.easeIn(duration: 0.3).delay(0.5)) {
                        showDoubleTapHint = true
                    }
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            practiceSettingsSheet
        }
        .overlay {
            if let msg = wordSaveMessage {
                WordSaveOverlay(
                    messageText: msg.text,
                    onSave: { phrase, meaning, notes in
                        saveWordToLibrary(phrase: phrase, meaning: meaning, notes: notes)
                    },
                    onDismiss: { wordSaveMessage = nil }
                )
                .transition(.opacity)
            }
        }
    }

    // MARK: - Practice Settings Sheet

    private var practiceSettingsSheet: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Tone picker
                VStack(alignment: .leading, spacing: 12) {
                    Text("CONVERSATION STYLE")
                        .font(.custom("HelveticaNeue-Bold", size: 11))
                        .foregroundColor(.tsSecondary)
                        .kerning(1.2)

                    let tones: [(id: String, label: String, icon: String, desc: String)] = [
                        ("casual",  "Casual",  "😊", "Friends hanging out — relaxed and natural"),
                        ("slang",   "Slang",   "🗣️", "Heavy street talk — local expressions only"),
                        ("flirty",  "Flirty",  "🔥", "Playful and teasing — bar vibes"),
                        ("work",    "Work",    "💼", "Professional — meetings, interviews, emails"),
                    ]

                    ForEach(tones, id: \.id) { tone in
                        Button {
                            practiceTone = tone.id
                        } label: {
                            HStack(spacing: 12) {
                                Text(tone.icon)
                                    .font(.system(size: 20))
                                    .frame(width: 32)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(tone.label)
                                        .font(.custom("HelveticaNeue-Medium", size: 15))
                                        .foregroundColor(.tsLabel)
                                    Text(tone.desc)
                                        .font(.custom("HelveticaNeue", size: 12))
                                        .foregroundColor(.tsSecondary)
                                }

                                Spacer()

                                if practiceTone == tone.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.tsAccent)
                                } else {
                                    Circle()
                                        .stroke(Color.tsSecondary.opacity(0.3), lineWidth: 1.5)
                                        .frame(width: 20, height: 20)
                                }
                            }
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(practiceTone == tone.id ? Color.tsAccent.opacity(0.06) : Color.tsCard)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(practiceTone == tone.id ? Color.tsAccent.opacity(0.2) : Color.clear, lineWidth: 1)
                            )
                        }
                    }
                }

                // Who starts
                VStack(alignment: .leading, spacing: 12) {
                    Text("WHO STARTS")
                        .font(.custom("HelveticaNeue-Bold", size: 11))
                        .foregroundColor(.tsSecondary)
                        .kerning(1.2)

                    HStack(spacing: 8) {
                        Button {
                            solStarts = true
                        } label: {
                            HStack(spacing: 6) {
                                Text("Sol starts")
                                    .font(.custom("HelveticaNeue-Medium", size: 14))
                            }
                            .foregroundColor(solStarts ? .white : .tsLabel)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(solStarts ? Color.tsAccent : Color.tsCard)
                            )
                        }

                        Button {
                            solStarts = false
                        } label: {
                            HStack(spacing: 6) {
                                Text("I'll start")
                                    .font(.custom("HelveticaNeue-Medium", size: 14))
                            }
                            .foregroundColor(!solStarts ? .white : .tsLabel)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(!solStarts ? Color.tsAccent : Color.tsCard)
                            )
                        }
                    }

                    Text(solStarts
                         ? "Sol picks a topic and opens the conversation."
                         : "You start — say whatever you want and Sol responds naturally.")
                        .font(.custom("HelveticaNeue", size: 12))
                        .foregroundColor(.tsSecondary)
                        .lineSpacing(2)
                }

                Spacer()

                Text("Changes take effect on the next topic.")
                    .font(.custom("HelveticaNeue", size: 12))
                    .foregroundColor(.tsSecondary)
            }
            .padding(20)
            .background(TSGradientBackground().ignoresSafeArea())
            .navigationTitle("Session Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showSettings = false } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.tsSecondary)
                    }
                }
            }
        }
    }

    // MARK: - Double-tap Hint Card

    private var doubleTapHintCard: some View {
        HStack(spacing: 12) {
            Text("👆")
                .font(.system(size: 20))

            VStack(alignment: .leading, spacing: 2) {
                Text("Don't understand something?")
                    .font(.custom("HelveticaNeue-Bold", size: 13))
                    .foregroundColor(.tsLabel)
                Text("Double-tap any message from Sol for the English translation. Give it a try!")
                    .font(.custom("HelveticaNeue", size: 12))
                    .foregroundColor(.tsSecondary)
                    .lineSpacing(1)
            }

            Spacer()

            Button {
                withAnimation(.easeOut(duration: 0.2)) {
                    showDoubleTapHint = false
                    doubleTapDismissCount += 1
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.tsSecondary)
                    .padding(6)
                    .background(Circle().fill(Color.tsSecondary.opacity(0.1)))
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.tsAccent.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.tsAccent.opacity(0.15), lineWidth: 0.5)
        )
    }

    // MARK: - Playback Hint Card

    private var playbackHintCard: some View {
        HStack(spacing: 12) {
            Text("🔊")
                .font(.system(size: 20))

            VStack(alignment: .leading, spacing: 2) {
                Text("Want to hear it again?")
                    .font(.custom("HelveticaNeue-Bold", size: 13))
                    .foregroundColor(.tsLabel)
                Text("Tap once on any message from Sol to replay the audio.")
                    .font(.custom("HelveticaNeue", size: 12))
                    .foregroundColor(.tsSecondary)
                    .lineSpacing(1)
            }

            Spacer()

            Button {
                withAnimation(.easeOut(duration: 0.2)) {
                    showPlaybackHint = false
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.tsSecondary)
                    .padding(6)
                    .background(Circle().fill(Color.tsSecondary.opacity(0.1)))
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "#FF9500").opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "#FF9500").opacity(0.15), lineWidth: 0.5)
        )
    }

    // MARK: - Native Hint Card

    private var nativeHintCard: some View {
        HStack(spacing: 12) {
            Text("👆")
                .font(.system(size: 20))

            VStack(alignment: .leading, spacing: 2) {
                Text("Want to sound more natural?")
                    .font(.custom("HelveticaNeue-Bold", size: 13))
                    .foregroundColor(.tsLabel)
                Text("Double-tap your own message to see how a native speaker would say it.")
                    .font(.custom("HelveticaNeue", size: 12))
                    .foregroundColor(.tsSecondary)
                    .lineSpacing(1)
            }

            Spacer()

            Button {
                withAnimation(.easeOut(duration: 0.2)) {
                    showNativeHint = false
                    nativeDismissCount += 1
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.tsSecondary)
                    .padding(6)
                    .background(Circle().fill(Color.tsSecondary.opacity(0.1)))
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "#34C759").opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "#34C759").opacity(0.15), lineWidth: 0.5)
        )
    }

    // MARK: - Save Hint Card

    private var saveHintCard: some View {
        HStack(spacing: 12) {
            Text("💾")
                .font(.system(size: 20))

            VStack(alignment: .leading, spacing: 2) {
                Text("Want to remember this?")
                    .font(.custom("HelveticaNeue-Bold", size: 13))
                    .foregroundColor(.tsLabel)
                Text("Double-tap any coaching tip to save it to your notes for later study.")
                    .font(.custom("HelveticaNeue", size: 12))
                    .foregroundColor(.tsSecondary)
                    .lineSpacing(1)
            }

            Spacer()

            Button {
                withAnimation(.easeOut(duration: 0.2)) {
                    showSaveHint = false
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.tsSecondary)
                    .padding(6)
                    .background(Circle().fill(Color.tsSecondary.opacity(0.1)))
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "#FF9500").opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "#FF9500").opacity(0.15), lineWidth: 0.5)
        )
    }

    // MARK: - Settings Hint Card

    private var wordSaveHintCard: some View {
        HStack(spacing: 12) {
            Text("📖")
                .font(.system(size: 20))

            VStack(alignment: .leading, spacing: 2) {
                Text("See a word you don't know?")
                    .font(.custom("HelveticaNeue-Bold", size: 13))
                    .foregroundColor(.tsLabel)
                Text("Hold down on any word in Sol's messages and slide to select it. We'll look it up and you can save it to your Library.")
                    .font(.custom("HelveticaNeue", size: 12))
                    .foregroundColor(.tsSecondary)
                    .lineSpacing(1)
            }

            Spacer()

            Button {
                withAnimation(.easeOut(duration: 0.2)) {
                    showWordSaveHint = false
                    wordSaveHintShown = true
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.tsSecondary)
                    .padding(6)
                    .background(Circle().fill(Color.tsSecondary.opacity(0.1)))
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.tsAccent.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.tsAccent.opacity(0.15), lineWidth: 0.5)
        )
    }

    private var settingsHintCard: some View {
        HStack(spacing: 12) {
            Text("⚙️")
                .font(.system(size: 20))

            VStack(alignment: .leading, spacing: 2) {
                Text("Customize your coaching")
                    .font(.custom("HelveticaNeue-Bold", size: 13))
                    .foregroundColor(.tsLabel)
                Text("Want more slang? Less grammar? Adjust your coaching style in Settings.")
                    .font(.custom("HelveticaNeue", size: 12))
                    .foregroundColor(.tsSecondary)
                    .lineSpacing(1)
            }

            Spacer()

            Button {
                withAnimation(.easeOut(duration: 0.2)) {
                    showSettingsHint = false
                    settingsHintShown = true
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.tsSecondary)
                    .padding(6)
                    .background(Circle().fill(Color.tsSecondary.opacity(0.1)))
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "#AF52DE").opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "#AF52DE").opacity(0.15), lineWidth: 0.5)
        )
    }

    // MARK: - Chat Bubble

    private func chatBubble(message: PracticeMessage) -> some View {
        let isRevealed = revealedTranslations.contains(message.id)
        let isNativeRevealed = revealedNative.contains(message.id)

        return HStack(alignment: .top, spacing: 10) {
            if message.role == .sol {
                // Sol avatar
                Image("SolAvaatar")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
            } else if message.role == .coaching {
                // Coaching tip icon — lightbulb in orange circle
                Circle()
                    .fill(Color(hex: "#FF9500").opacity(0.15))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text("💡")
                            .font(.system(size: 16))
                    )
            }

            if message.role == .user {
                Spacer(minLength: 60)
            }

            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                if message.role == .sol {
                    Text("Sol")
                        .font(.custom("HelveticaNeue-Bold", size: 11))
                        .foregroundColor(.tsSecondary)
                } else if message.role == .coaching {
                    HStack(spacing: 6) {
                        Text("COACHING TIP")
                            .font(.custom("HelveticaNeue-Bold", size: 9))
                            .foregroundColor(Color(hex: "#FF9500"))
                            .kerning(0.8)

                        if savedMessageIds.contains(message.id) {
                            HStack(spacing: 3) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 10))
                                Text("SAVED")
                                    .font(.custom("HelveticaNeue-Bold", size: 9))
                                    .kerning(0.8)
                            }
                            .foregroundColor(Color(hex: "#34C759"))
                            .transition(.opacity.combined(with: .scale(scale: 0.8)))
                        }
                    }
                }

                // Main message bubble
                let textVisible = message.role != .sol || revealedText.contains(message.id)
                let isSolPlaying = message.role == .sol && playingAudio == message.id

                HStack(alignment: .bottom, spacing: 6) {
                    if message.text == "..." {
                        // Typing indicator
                        HStack(spacing: 4) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "#FFD60A"))
                            Text("Thinking...")
                                .font(.custom("HelveticaNeue", size: 13))
                                .foregroundColor(.tsSecondary)
                        }
                    } else {
                        ZStack(alignment: .leading) {
                            // Text — always laid out at full size so the bubble never resizes.
                            // .drawingGroup() rasterizes it as a single bitmap so the entire
                            // block fades in uniformly — no per-line stagger.
                            Text(message.text)
                                .font(.custom("HelveticaNeue", size: 14))
                                .foregroundColor(.tsLabel)
                                .lineSpacing(3)
                                .drawingGroup()
                                .opacity(textVisible ? 1 : 0)

                            // Waveform — ALWAYS in the tree (no if/else), just opacity-swapped.
                            // This prevents layout recalc that causes the staggered text reveal.
                            if message.role == .sol {
                                PulsatingWaveformView(isAnimating: !textVisible)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .opacity(textVisible ? 0 : 1)
                                    .allowsHitTesting(false)
                            }
                        }

                        // Speaker icon — fades in after text appears
                        if message.role == .sol {
                            Image(systemName: isSolPlaying ? "speaker.wave.3.fill" : "speaker.wave.2")
                                .font(.system(size: 10))
                                .foregroundColor(Color.tsAccent.opacity(isSolPlaying ? 0.6 : 0.2))
                                .opacity(textVisible ? 1 : 0)
                                .padding(.bottom, 2)
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(bubbleColor(for: message.role))
                )
                .onAppear {
                    // Audio is triggered explicitly from loadTopic and fetchSolResponse
                    // NOT from onAppear — onAppear caused infinite loops from re-renders
                }
                .onTapGesture(count: 2) {
                        if message.role == .sol && message.translation != nil {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                if isRevealed {
                                    revealedTranslations.remove(message.id)
                                } else {
                                    revealedTranslations.insert(message.id)
                                    if !doubleTapValidated {
                                        doubleTapValidated = true
                                        withAnimation(.easeOut(duration: 0.2)) {
                                            showDoubleTapHint = false
                                        }
                                        // Show playback hint after they learn double-tap
                                        if !playbackValidated {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                                withAnimation(.easeIn(duration: 0.3)) {
                                                    showPlaybackHint = true
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        } else if message.role == .coaching && message.saveablePhrase != nil {
                            // Save coaching tip phrase to library
                            saveCoachingPhrase(message: message)
                        } else if message.role == .user && message.nativeVersion != nil {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                if isNativeRevealed {
                                    revealedNative.remove(message.id)
                                } else {
                                    revealedNative.insert(message.id)
                                    if !nativeDoubleTapValidated {
                                        nativeDoubleTapValidated = true
                                        withAnimation(.easeOut(duration: 0.2)) {
                                            showNativeHint = false
                                        }
                                    }
                                }
                            }
                        }
                    }
                .onTapGesture(count: 1) {
                    // Single tap on Sol's message → replay audio
                    if message.role == .sol && textVisible && message.text != "..." {
                        playSolAudio(message: message)
                        // Validate playback hint
                        if !playbackValidated {
                            playbackValidated = true
                            withAnimation(.easeOut(duration: 0.2)) {
                                showPlaybackHint = false
                            }
                        }
                    }
                }
                .onLongPressGesture(minimumDuration: 0.5) {
                    // Long press on Sol's message → open word save overlay
                    if message.role == .sol && textVisible && message.text != "..." {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        wordSaveMessage = message

                        // Dismiss word save hint if showing
                        if showWordSaveHint {
                            showWordSaveHint = false
                            wordSaveHintShown = true
                        }
                    }
                }

                // Translation card — Sol's messages (English)
                if isRevealed, let translation = message.translation {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 4) {
                            Text("🇺🇸")
                                .font(.system(size: 12))
                            Text("ENGLISH")
                                .font(.custom("HelveticaNeue-Bold", size: 9))
                                .foregroundColor(.tsSecondary)
                                .kerning(0.8)
                        }

                        Text(translation)
                            .font(.custom("HelveticaNeue", size: 13))
                            .foregroundColor(.tsLabel)
                            .lineSpacing(2)
                            .fixedSize(horizontal: false, vertical: true)

                        if let notes = message.translationNotes {
                            Text("💡 \(notes)")
                                .font(.custom("HelveticaNeue", size: 12))
                                .foregroundColor(.tsSecondary)
                                .italic()
                                .lineSpacing(3)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.top, 2)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(colorScheme == .dark ? Color.tsCard : Color.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.tsAccent.opacity(0.1), lineWidth: 0.5)
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }

                // Native version card — User's messages (how a native would say it)
                // Uses the target language's flag color as card accent
                if isNativeRevealed, let native = message.nativeVersion {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 4) {
                            Text(langFlag)
                                .font(.system(size: 12))
                            Text("CORRECTION")
                                .font(.custom("HelveticaNeue-Bold", size: 9))
                                .foregroundColor(langAccentColor)
                                .kerning(0.8)
                        }

                        Text(native)
                            .font(.custom("HelveticaNeue", size: 13))
                            .foregroundColor(.tsLabel)
                            .lineSpacing(2)
                            .fixedSize(horizontal: false, vertical: true)

                        if let notes = message.nativeNotes {
                            Text("💡 \(notes)")
                                .font(.custom("HelveticaNeue", size: 12))
                                .foregroundColor(.tsSecondary)
                                .italic()
                                .lineSpacing(3)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.top, 2)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(langAccentColor.opacity(0.06))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(langAccentColor.opacity(0.12), lineWidth: 0.5)
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }
            }

            if message.role == .sol || message.role == .coaching {
                Spacer(minLength: 40)
            }
        }
    }

    private func bubbleColor(for role: PracticeMessage.Role) -> Color {
        switch role {
        case .sol:
            return colorScheme == .dark ? Color.tsCard : Color.tsCard
        case .user:
            return colorScheme == .dark
                ? Color.tsAccent.opacity(0.15)
                : Color(hex: "#E8F0FE")  // soft muted blue — understated, elegant
        case .coaching:
            return Color(hex: "#FF9500").opacity(0.1)
        }
    }

    // MARK: - Topic Loading & Swiping

    private func loadTopic(index: Int) {
        guard !isLoadingTopic else {
            NSLog("🔊 [Practice] BLOCKED loadTopic — already loading")
            return
        }
        isLoadingTopic = true

        // Read user's city — prefer UserLocationsStore (free-text), fall back to selected_city_id
        let defaults = UserDefaults(suiteName: "group.com.jeff.translatehelper")
        let userCity: String = {
            if let loc = UserLocationsStore.shared.locations.first {
                return loc.displayName
            }
            let cityId = defaults?.string(forKey: "selected_city_id") ?? ""
            return Self.resolveCityName(cityId)
        }()

        // Load interest profile for personalization
        let appGroup = "group.com.jeff.translatehelper"
        var interestContext = ""
        if let dir = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) {
            let file = dir.appendingPathComponent("interest_profile.json")
            if let data = try? Data(contentsOf: file),
               let entries = try? JSONSerialization.jsonObject(with: data) as? [[String: String]] {
                let engaged = entries.filter { $0["action"] == "engaged" }.compactMap { $0["topic"] }
                let swiped = entries.filter { $0["action"] == "swiped" }.compactMap { $0["topic"] }
                if !engaged.isEmpty { interestContext += "User enjoys talking about: \(Set(engaged).joined(separator: ", ")). " }
                if !swiped.isEmpty { interestContext += "User has swiped past: \(Set(swiped).joined(separator: ", ")). " }
            }
        }

        let recentBuffer = recentTopicTags.isEmpty ? "" : "Do NOT generate a topic related to these recent tags (avoid repeats): \(recentTopicTags.joined(separator: ", ")). "

        // Load persistent topic history — never repeat a past conversation
        let topicHistory = loadTopicHistory()
        let historyContext = topicHistory.isEmpty ? "" : "These topics have ALREADY been discussed in past sessions — do NOT repeat any of them:\n\(topicHistory.suffix(20).joined(separator: "\n"))\n"

        let hintText = showSwipeRightHint
            ? "💡 Sol speaks like a local — casual, full of slang. Respond naturally. Swipe right → for a different topic."
            : showSwipeLeftHint
            ? "💡 Swipe ← left to go back to any previous topic."
            : "💡 Sol speaks like a local — casual, full of slang. Respond naturally."

        // Reset audio state for new topic
        ttsService.audioPlayer?.stop()
        isPlayingSolAudio = false
        playingAudio = nil
        revealedText.removeAll()

        messages = [
            PracticeMessage(role: .coaching, text: hintText),
        ]

        // First session ever — let them know they can respond in English
        let englishHintKey = "practice_english_hint_shown"
        if !UserDefaults.standard.bool(forKey: englishHintKey) {
            UserDefaults.standard.set(true, forKey: englishHintKey)
            let langName = LanguageManager.shared.targetLangName ?? "the target language"
            let englishHint = PracticeMessage(
                role: .coaching,
                text: "💬 Not sure what to say? You can respond in English anytime — your answers will be tracked in \(langName), and the conversation keeps going."
            )
            messages.append(englishHint)
        }

        for msg in messages { revealedText.insert(msg.id) }
        messageCount = 0

        // Script-driven opener — picks from the user's status/interests/city context.
        // Falls back to fully generative if all scripts are exhausted.
        let scriptBlock = ConversationScriptEngine.shared.buildScriptBlock()
        let hasScript = !scriptBlock.isEmpty

        let sessionCount = PracticeStatsStore.shared.totalSessionCount
        let isEarlyUser = sessionCount < 10

        let earlyUserBoost = (isEarlyUser && !hasScript) ? """
        IMPORTANT — THIS IS AN EARLY SESSION. Make a STRONG first impression:
        - Reference a SPECIFIC real place, restaurant, landmark, neighbourhood, or local experience in \(userCity).
          Not generic — use actual names. "Have you tried the tacos al pastor at El Huequito?" not "Do you like tacos?"
        - Use a local expression or slang that would surprise them — something they won't find in textbooks.
        - Make them feel like they're talking to someone who LIVES there and knows the hidden gems.
        """ : ""

        let openingPrompt = """
        Generate a casual, warm opening message for a practice conversation.
        \(scriptBlock)

        \(hasScript ? "Use the CONVERSATION OPENER direction above as your starting point." : """
        Be CREATIVE and SPECIFIC — never generic. Think about:
        - Real places, restaurants, bars, markets, landmarks in \(userCity)
        - Local cultural events, traditions, or seasonal things happening
        - Neighbourhood-specific references (not just the city name)
        - Local slang, expressions, or inside jokes that residents would know
        - Food, music, nightlife, dating culture specific to \(userCity)
        - Funny observations about daily life that only someone living there would notice
        - Hypothetical questions, unpopular opinions, childhood memories, travel stories
        """)

        \(earlyUserBoost)
        \(interestContext)
        \(recentBuffer)
        \(historyContext)

        The user lives in \(userCity). \
        LOCATION ACCURACY — CRITICAL: \
        - ONLY reference places, landmarks, parks, restaurants, and neighbourhoods that are \
          ACTUALLY in \(userCity). Do NOT reference places from other cities in the same country. \
        - If you are not 100% sure a place is in \(userCity), do NOT mention it. \
          It is BETTER to reference something generic about the city than to name a place \
          that's actually in a different city. Getting this wrong destroys trust. \
        - For example: Ibirapuera Park is in São Paulo, NOT Rio. Chapultepec is in Mexico City, \
          NOT Guadalajara. If the user is in Rio, talk about Copacabana, Lapa, Santa Teresa, \
          Lagoa — not landmarks from São Paulo. \
        - When in doubt, reference: local food, neighbourhood vibes, weather, daily life, \
          or cultural habits specific to that city — things you CAN'T get wrong. \
        \
        Speak naturally in the target language. Use local slang and contractions. \
        Use slang from \(userCity) and its region + nationwide slang that everyone understands. \
        Do NOT teach slang specific to OTHER cities or regions — only slang someone in \(userCity) would use. \
        2-3 sentences max. Ask a question they can easily answer.

        Also provide:
        - A 1-word topic tag (e.g. "food", "music", "dating", "work", "culture")
        - A brief 1-line summary of what you asked (in English, for our records)

        All notes must be in English, with target-language words kept inline for context
        (e.g. "'dale' is casual slang for 'go ahead' or 'let's do it'").

        Respond ONLY with JSON:
        {"message": "your opening in target language", "translation": "English translation", "notes": "brief English note with target-language words inline", "topic_tag": "one_word_tag", "summary": "brief English summary of the topic"}
        """

        // Check if we have a preloaded topic ready (instant!)
        if let preloaded = preloadedSolMessage {
            isLoadingTopic = false
            messages.insert(preloaded, at: 0)
            preloadedSolMessage = nil
            playSolAudioThenReveal(message: preloaded)

            // Add preloaded slang notes (skip already-known phrases)
            let notes = preloadedSlangNotes
            preloadedSlangNotes = []
            if !notes.isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    for note in notes {
                        guard !isPhraseAlreadyKnown(note.phrase) else { continue }
                        messages.append(PracticeMessage(
                            role: .coaching,
                            text: "📖 \"\(note.phrase)\" — \(note.meaning). \(note.context)",
                            saveablePhrase: note.phrase,
                            saveableMeaning: note.meaning
                        ))
                    }
                }
            }

            // Pre-generate the NEXT topic in background
            preGenerateNextTopic()
            return
        }

        // No preloaded topic — generate now (first load)
        // Show "..." placeholder but do NOT add to revealedText — it stays as the
        // "Thinking..." indicator naturally (line 2284 checks text == "...").
        let loadingMsg = PracticeMessage(role: .sol, text: "...")
        messages.insert(loadingMsg, at: 0)

        conversationService.getSolResponse(
            conversationHistory: [(role: "user", text: openingPrompt)],
            userCity: userCity,
            targetLanguage: targetLang,
            tone: practiceTone
        ) { [self] response in
            isLoadingTopic = false

            let solMsg = buildSolMessage(from: response)

            // Swap the placeholder's text in-place so SwiftUI sees ONE message change,
            // not a remove + insert. Keep the same array slot — no layout thrash.
            if let idx = messages.firstIndex(where: { $0.id == loadingMsg.id }) {
                messages[idx] = solMsg
            } else {
                messages.insert(solMsg, at: 0)
            }

            // Text is NOT in revealedText yet, so it starts hidden (waveform shows).
            // playSolAudioThenReveal handles the single reveal after audio.
            playSolAudioThenReveal(message: solMsg)

            // Add slang notes after a delay (skip already-known phrases)
            if let sol = response, !sol.slangNotes.isEmpty {
                let notes = sol.slangNotes
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    for note in notes {
                        guard !isPhraseAlreadyKnown(note.phrase) else { continue }
                        messages.append(PracticeMessage(
                            role: .coaching,
                            text: "📖 \"\(note.phrase)\" — \(note.meaning). \(note.context)",
                            saveablePhrase: note.phrase,
                            saveableMeaning: note.meaning
                        ))
                    }
                }
            }

            // Pre-generate the next topic in background
            preGenerateNextTopic()
        }
    }

    private func buildSolMessage(from response: PracticeConversationService.SolResponse?) -> PracticeMessage {
        if let sol = response {
            let tag = sol.translationNotes?.split(separator: " ").first.map(String.init) ?? "general"
            recentTopicTags.append(tag)
            if recentTopicTags.count > 5 { recentTopicTags.removeFirst() }
            let summary = sol.translation ?? sol.text
            logTopicHistory(String(summary.prefix(100)))

            return PracticeMessage(
                role: .sol,
                text: sol.text,
                translation: sol.translation,
                translationNotes: sol.translationNotes
            )
        } else {
            return PracticeMessage(
                role: .sol,
                text: "E aí! Tudo bem? Me conta — como tá sendo o dia hoje?",
                translation: "Hey! Everything good? Tell me — how's your day going?",
                translationNotes: "'tudo bem' = 'everything good?' · 'como tá sendo' = 'how's it going' (casual)"
            )
        }
    }

    /// Pre-generate the next topic in the background so swiping feels instant
    private func preGenerateNextTopic() {
        guard !isPreloading else { return }
        isPreloading = true

        let defaults = UserDefaults(suiteName: "group.com.jeff.translatehelper")
        let cityId = defaults?.string(forKey: "selected_city_id") ?? ""
        // targetLang comes from @AppStorage — single source of truth
        let userCity = Self.resolveCityName(cityId)

        let prompt = """
        Generate a casual, warm opening message for a practice conversation.
        Be CREATIVE — invent a unique topic. The user lives in \(userCity).
        Speak naturally in the target language. Use local slang. 2-3 sentences max.
        Respond ONLY with JSON:
        {"message": "opening in target language", "translation": "English", "notes": "slang notes", "topic_tag": "tag", "summary": "English summary"}
        """

        conversationService.getSolResponse(
            conversationHistory: [(role: "user", text: prompt)],
            userCity: userCity,
            targetLanguage: targetLang,
            tone: practiceTone
        ) { [self] response in
            isPreloading = false
            if let sol = response {
                preloadedSolMessage = PracticeMessage(
                    role: .sol,
                    text: sol.text,
                    translation: sol.translation,
                    translationNotes: sol.translationNotes
                )
                preloadedSlangNotes = sol.slangNotes
                NSLog("🎯 [Practice] next topic pre-generated: \(sol.text.prefix(40))")
            }
        }
    }

    private func swipeToNextTopic() {
        let swipedTag = recentTopicTags.last ?? "unknown"
        logInterest(topic: swipedTag, action: "swiped")

        // First right swipe — dismiss right hint, show left hint
        if !swipeRightDone {
            swipeRightDone = true
            withAnimation { showSwipeRightHint = false }
            showSwipeLeftHint = true
        }

        currentTopicIndex += 1
        withAnimation(.easeInOut(duration: 0.3)) {
            loadTopic(index: currentTopicIndex)
        }
    }

    /// Saves a one-line topic summary to persistent history — GPT uses this to never repeat topics
    private func logTopicHistory(_ summary: String) {
        let appGroup = "group.com.jeff.translatehelper"
        guard let dir = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else { return }

        let file = dir.appendingPathComponent("topic_history.json")
        var history: [String] = []
        if let data = try? Data(contentsOf: file),
           let existing = try? JSONSerialization.jsonObject(with: data) as? [String] {
            history = existing
        }
        history.append(summary)
        if history.count > 50 { history = Array(history.suffix(50)) } // keep last 50
        if let data = try? JSONSerialization.data(withJSONObject: history) {
            try? data.write(to: file)
        }
    }

    /// Loads topic history for the "don't repeat" prompt context
    private func loadTopicHistory() -> [String] {
        let appGroup = "group.com.jeff.translatehelper"
        guard let dir = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else { return [] }
        let file = dir.appendingPathComponent("topic_history.json")
        guard let data = try? Data(contentsOf: file),
              let history = try? JSONSerialization.jsonObject(with: data) as? [String] else { return [] }
        return history
    }

    private func logInterest(topic: String, action: String) {
        let appGroup = "group.com.jeff.translatehelper"
        guard let dir = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else { return }

        let file = dir.appendingPathComponent("interest_profile.json")
        var profile: [[String: String]] = []

        if let data = try? Data(contentsOf: file),
           let existing = try? JSONSerialization.jsonObject(with: data) as? [[String: String]] {
            profile = existing
        }

        profile.append([
            "topic": topic,
            "action": action,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ])

        // Keep last 100 entries
        if profile.count > 100 { profile = Array(profile.suffix(100)) }

        if let data = try? JSONSerialization.data(withJSONObject: profile) {
            try? data.write(to: file)
        }
        NSLog("🎯 [Practice] interest logged: \(action) → \(topic)")
    }

    // MARK: - Save Coaching Phrase

    private func saveCoachingPhrase(message: PracticeMessage) {
        guard let phrase = message.saveablePhrase,
              let meaning = message.saveableMeaning else { return }

        // Check if already saved this session
        guard !savedPhrases.contains(phrase.lowercased()) else { return }

        let appGroup = "group.com.jeff.translatehelper"
        guard let defaults = UserDefaults(suiteName: appGroup) else { return }

        // Use self.targetLang from @AppStorage
        let key = "talkswitch_saved_phrases"

        // Check for duplicates in existing saved phrases
        let existing = defaults.array(forKey: key) as? [[String: String]] ?? []
        let isDuplicate = existing.contains { entry in
            entry["sourceText"]?.lowercased() == phrase.lowercased() ||
            entry["translation"]?.lowercased() == phrase.lowercased()
        }
        guard !isDuplicate else {
            NSLog("🎯 [Practice] phrase already saved, skipping: \(phrase)")
            return
        }

        // Save to App Group (same format as keyboard save)
        let newEntry: [String: String] = [
            "id":          UUID().uuidString,
            "sourceText":  phrase,
            "translation": meaning,
            "sourceLang":  targetLang,
            "targetLang":  "en",
            "savedAt":     ISO8601DateFormatter().string(from: Date()),
            "notes":       "Learned from Sol in practice session"
        ]

        var allPhrases = existing
        allPhrases.append(newEntry)
        defaults.set(allPhrases, forKey: key)
        defaults.synchronize()

        savedPhrases.insert(phrase.lowercased())
        withAnimation(.easeInOut(duration: 0.25)) {
            savedMessageIds.insert(message.id)
        }

        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        // Validate the save hint
        if !saveValidated {
            saveValidated = true
            withAnimation { showSaveHint = false }
        }

        NSLog("🎯 [Practice] saved phrase: \(phrase) → \(meaning)")
    }

    /// Save a word/phrase selected from Sol's message via tap-hold-slide
    private func saveWordToLibrary(phrase: String, meaning: String, notes: String) {
        let appGroup = "group.com.jeff.translatehelper"
        guard let defaults = UserDefaults(suiteName: appGroup) else { return }

        let key = "talkswitch_saved_phrases"
        let existing = defaults.array(forKey: key) as? [[String: String]] ?? []

        // Check duplicate
        let isDuplicate = existing.contains { entry in
            entry["sourceText"]?.lowercased() == phrase.lowercased()
        }
        guard !isDuplicate else { return }

        let newEntry: [String: String] = [
            "id":          UUID().uuidString,
            "sourceText":  phrase,
            "translation": meaning,
            "sourceLang":  targetLang,
            "targetLang":  "en",
            "savedAt":     ISO8601DateFormatter().string(from: Date()),
            "notes":       notes
        ]

        var allPhrases = existing
        allPhrases.append(newEntry)
        defaults.set(allPhrases, forKey: key)
        defaults.synchronize()

        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        NSLog("📖 [WordSave] saved: \(phrase) → \(meaning)")
    }

    /// Checks if a phrase is already in the user's library (saved or graduated)
    private func isPhraseAlreadyKnown(_ phrase: String) -> Bool {
        let appGroup = "group.com.jeff.translatehelper"
        guard let defaults = UserDefaults(suiteName: appGroup) else { return false }
        let existing = defaults.array(forKey: "talkswitch_saved_phrases") as? [[String: String]] ?? []
        return existing.contains { entry in
            entry["sourceText"]?.lowercased() == phrase.lowercased() ||
            entry["translation"]?.lowercased() == phrase.lowercased()
        }
    }

    // MARK: - Sol Audio Playback

    /// Play audio first, then fade text in ~1.5s before audio ends.
    /// Guarded — will not fire if already playing. Each message gets ONE reveal.
    private func playSolAudioThenReveal(message: PracticeMessage) {
        let msgId = message.id

        guard !isPlayingSolAudio else {
            NSLog("🔊 [Practice] BLOCKED — already playing audio, queuing reveal for: \(message.text.prefix(30))")
            // Queue: reveal text after current audio finishes — but only if
            // nothing else revealed it first.
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [self] in
                if !revealedText.contains(msgId) {
                    withAnimation(.easeIn(duration: 1.0)) {
                        _ = revealedText.insert(msgId)
                    }
                }
            }
            return
        }
        isPlayingSolAudio = true
        playingAudio = msgId
        NSLog("🔊 [Practice] playing audio for: \(message.text.prefix(40))")

        ttsService.speak(
            text: message.text,
            language: targetLang,
            nearlyDone: { [self] in
                // Guard: only reveal once. If the safety timer already did it, skip.
                guard !revealedText.contains(msgId) else { return }
                withAnimation(.easeIn(duration: 1.5)) {
                    _ = revealedText.insert(msgId)
                }
            },
            completion: { [self] in
                // Audio finished — ensure text is visible (safety net for very short clips)
                if !revealedText.contains(msgId) {
                    withAnimation(.easeIn(duration: 0.5)) {
                        _ = revealedText.insert(msgId)
                    }
                }
                playingAudio = nil
                isPlayingSolAudio = false
            }
        )
    }

    /// Replay audio for a Sol message (text already visible)
    private func playSolAudio(message: PracticeMessage) {
        guard !isPlayingSolAudio else { return }
        isPlayingSolAudio = true
        playingAudio = message.id
        ttsService.speak(text: message.text, language: targetLang) {
            DispatchQueue.main.async {
                self.playingAudio = nil
                self.isPlayingSolAudio = false
            }
        }
    }

    // MARK: - Recording

    private let conversationService = PracticeConversationService.shared

    private func startRecording() {
        withAnimation { isRecording = true }
        recordingSeconds = 0
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            recordingSeconds += 1
        }
        conversationService.startRecording()
    }

    private func cancelRecording() {
        recordingTimer?.invalidate()
        recordingTimer = nil
        recordingSeconds = 0
        withAnimation { isRecording = false }
        conversationService.stopRecording()
    }

    /// Saves session stats and dismisses the practice view.
    private func endAndDismiss() {
        // Persist session stats for weekly reports
        if sessionSeconds > 5 {  // Only save meaningful sessions
            PracticeStatsStore.shared.recordSession(
                durationSeconds: sessionSeconds,
                messageCount: totalMessagesThisSession,
                tone: practiceTone
            )
            NSLog("🎯 [Practice] session saved: \(sessionSeconds)s, \(totalMessagesThisSession) msgs")

            // Check if it's time for a Gemini conversation pool refresh
            let shouldRefresh = ConversationPoolManager.shared.incrementSessionCount()
            if shouldRefresh {
                let cityName = UserLocationsStore.shared.locations.first?.displayName ?? "their city"
                let interestsRaw = UserDefaults.standard.string(forKey: "user_interests") ?? ""
                let interests = interestsRaw.split(separator: ",").map(String.init)

                // Build a brief summary of this session for Gemini
                let summary = messages
                    .prefix(20)
                    .map { "\($0.role == .sol ? "Sol" : "User"): \($0.text)" }
                    .joined(separator: "\n")

                DispatchQueue.global(qos: .utility).async {
                    ConversationPoolManager.shared.refreshPool(
                        city: cityName,
                        interests: interests,
                        recentConversationSummary: summary
                    ) { success in
                        NSLog("🌐 [ConvPool] Post-session refresh: \(success ? "success" : "skipped")")
                    }
                }
            }
        }
        dismiss()
    }

    private func stopAndSendRecording() {
        guard !isSendingRecording2 else { return }
        isSendingRecording2 = true
        recordingTimer?.invalidate()
        recordingTimer = nil
        recordingSeconds = 0
        withAnimation { isRecording = false }
        conversationService.stopRecording()

        // Transcribe the actual recording
        conversationService.transcribe(language: targetLang) { [self] transcription in
            defer { isSendingRecording2 = false }  // Always reset, even on failure

            guard let text = transcription, !text.isEmpty else {
                NSLog("🎤 [Practice] transcription failed or empty")
                return
            }

            let msg = PracticeMessage(role: .user, text: text)
            messages.append(msg)
            messageCount += 1
            totalMessagesThisSession += 1

            // Show native hint after first user message
            if !nativeDoubleTapValidated && nativeDismissCount < 3 && messageCount == 1 {
                nativeHintShownForMessage = msg.id
                withAnimation(.easeIn(duration: 0.3).delay(0.3)) {
                    showNativeHint = true
                }
            }

            // Get Sol's real response
            fetchSolResponse(userMessageId: msg.id)
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }

    private func formatSessionTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }

    // MARK: - City Resolution

    /// Resolves a city ID, display name, or country name into context for Sol's prompts.
    /// Handles: "mx_cdmx" → "Mexico City", "br_belo_horizonte" → "Belo Horizonte",
    /// "Brazil" → "Brazil" (country-wide), or raw display names passed through unchanged.
    static func resolveCityName(_ cityId: String) -> String {
        let trimmed = cityId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "their city" }

        // Known city ID mappings
        let knownCities: [String: String] = [
            "mx_cdmx": "Mexico City",
            "mx_guadalajara": "Guadalajara",
            "mx_monterrey": "Monterrey",
            "mx_oaxaca": "Oaxaca",
            "mx_cancun": "Cancún",
            "mx_tulum": "Tulum",
            "mx_playa": "Playa del Carmen",
            "mx_merida": "Mérida",
            "br_sao_paulo": "São Paulo",
            "br_rio": "Rio de Janeiro",
            "br_belo_horizonte": "Belo Horizonte",
            "br_brasilia": "Brasília",
            "br_curitiba": "Curitiba",
            "br_florianopolis": "Florianópolis",
            "br_salvador": "Salvador",
            "br_recife": "Recife",
            "br_porto_alegre": "Porto Alegre",
            "br_fortaleza": "Fortaleza",
        ]

        // Known countries → use country-wide context (no specific city)
        let knownCountries: [String: String] = [
            "brazil": "Brazil", "brasil": "Brazil",
            "mexico": "Mexico", "méxico": "Mexico",
            "spain": "Spain", "españa": "Spain",
            "france": "France", "deutschland": "Germany", "germany": "Germany",
            "italy": "Italy", "italia": "Italy",
            "japan": "Japan", "korea": "South Korea",
            "china": "China", "portugal": "Portugal",
            "colombia": "Colombia", "argentina": "Argentina",
            "chile": "Chile", "peru": "Peru", "perú": "Peru",
        ]

        let lower = trimmed.lowercased()

        // Direct match on city ID
        if let name = knownCities[lower] {
            return name
        }

        // Country match — return as-is, Sol will use country-wide slang
        if let country = knownCountries[lower] {
            return country
        }

        // If it looks like an ID with underscores and a country prefix, clean it up
        if trimmed.contains("_") {
            let parts = trimmed.split(separator: "_")
            if parts.count >= 2 {
                let cityParts = parts.dropFirst()
                return cityParts.map { $0.capitalized }.joined(separator: " ")
            }
        }

        // Already a display name (city or country) — return as-is
        return trimmed
    }

    // MARK: - Send Message

    private func sendMessage() {
        let text = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        let msg = PracticeMessage(role: .user, text: text)
        messages.append(msg)
        userInput = ""
        messageCount += 1
        totalMessagesThisSession += 1

        // Log engagement on first message for this topic
        if messageCount == 1 {
            let engagedTag = recentTopicTags.last ?? "unknown"
            logInterest(topic: engagedTag, action: "engaged")
        }

        // Show native hint after first user message
        if !nativeDoubleTapValidated && nativeDismissCount < 3 && messageCount == 1 {
            nativeHintShownForMessage = msg.id
            withAnimation(.easeIn(duration: 0.3).delay(0.3)) {
                showNativeHint = true
            }
        }

        // Get Sol's real response
        fetchSolResponse(userMessageId: msg.id)
    }

    // MARK: - Fetch Sol's Response (GPT-4o-mini)

    private func fetchSolResponse(userMessageId: UUID) {
        guard !isFetchingSolResponse2 else {
            NSLog("🔊 [Practice] BLOCKED fetchSolResponse — already fetching")
            return
        }
        isFetchingSolResponse2 = true
        // Build conversation history for GPT
        var history: [(role: String, text: String)] = []
        for msg in messages {
            switch msg.role {
            case .sol:
                history.append((role: "assistant", text: msg.text))
            case .user:
                let cleanText = msg.text
                history.append((role: "user", text: cleanText))
            case .coaching:
                break // don't send coaching tips to GPT
            }
        }

        // Resolve city — prefer UserLocationsStore (free-text), fall back to selected_city_id
        let fetchCity: String = {
            if let loc = UserLocationsStore.shared.locations.first {
                return loc.displayName
            }
            let cityId = UserDefaults(suiteName: "group.com.jeff.translatehelper")?.string(forKey: "selected_city_id") ?? ""
            return Self.resolveCityName(cityId)
        }()

        conversationService.getSolResponse(conversationHistory: history, userCity: fetchCity, targetLanguage: targetLang, tone: practiceTone) { [self] response in
            isFetchingSolResponse2 = false
            guard let sol = response else {
                NSLog("🎤 [Practice] Sol response failed")
                return
            }

            // Build Sol's response message
            let solMsg = PracticeMessage(
                role: .sol,
                text: sol.text,
                translation: sol.translation,
                translationNotes: sol.translationNotes
            )

            // Batch all array mutations into one pass to avoid mid-render flashes.
            // Native correction on user's message + Sol's new message = single SwiftUI update.
            var userText = ""
            if let nativeVersion = sol.nativeCorrectionForUser,
               let idx = messages.firstIndex(where: { $0.id == userMessageId }) {
                userText = messages[idx].text
                messages[idx].nativeVersion = nativeVersion
                messages[idx].nativeNotes = sol.nativeCorrectionNotes
            }
            messages.append(solMsg)
            messageCount += 1
            totalMessagesThisSession += 1

            // Show word save hint after Sol's 2nd message (first session only)
            if totalMessagesThisSession == 2 && !wordSaveHintShown && !showWordSaveHint {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation(.easeIn(duration: 0.3)) {
                        showWordSaveHint = true
                    }
                }
            }

            // Show settings hint after 8+ messages (once per user, ever)
            if totalMessagesThisSession >= 8 && !settingsHintShown && !showSettingsHint {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeIn(duration: 0.3)) {
                        showSettingsHint = true
                    }
                }
            }

            // Ingest correction into mistake profile (outside the array mutation)
            if let nativeVersion = sol.nativeCorrectionForUser, !userText.isEmpty {
                // Use structured mistake_log if available (clean short fragments)
                // Otherwise fall back to raw correction text
                if let log = sol.mistakeLog,
                   !log.userFragment.isEmpty,
                   !log.correctFragment.isEmpty,
                   log.correctFragment.lowercased() != "null",
                   log.userFragment.count <= 30,
                   log.correctFragment.count <= 30,
                   !log.userFragment.contains("→") {
                    MistakeIngestion.ingestFromSol(
                        userSaid: log.userFragment,
                        nativeCorrection: log.correctFragment,
                        notes: log.rule,
                        language: targetLang
                    )
                }
                // Skip raw fallback — only ingest clean structured data
            }

            // Fire background Gemini enrichment for the NEXT turn.
            // Sol already responded — this just pre-loads deeper knowledge.
            let enrichHistory = history.suffix(4)
            let enrichCity = fetchCity
            DispatchQueue.global(qos: .utility).async {
                ConversationPoolManager.shared.enrichFromConversation(
                    city: enrichCity,
                    recentMessages: enrichHistory.map { ($0.role, $0.text) }
                )
            }

            // Play audio explicitly for Sol's response
            playSolAudioThenReveal(message: solMsg)

            // Add slang note cards after audio finishes (skip already-known phrases)
            let slangNotes = sol.slangNotes
            if !slangNotes.isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    for note in slangNotes {
                        guard !isPhraseAlreadyKnown(note.phrase) else { continue }

                        let noteMsg = PracticeMessage(
                            role: .coaching,
                            text: "📖 \"\(note.phrase)\" — \(note.meaning). \(note.context)",
                            saveablePhrase: note.phrase,
                            saveableMeaning: note.meaning
                        )
                        messages.append(noteMsg)

                        // Show save hint on first coaching tip (slang note)
                        if !saveValidated && saveHintShownForMessage == nil {
                            saveHintShownForMessage = noteMsg.id
                            withAnimation(.easeIn(duration: 0.3).delay(0.3)) {
                                showSaveHint = true
                            }
                        }
                    }
                }
            }
        }
    }

    private func mockResponse(for index: Int) -> PracticeMessage {
        let responses: [PracticeMessage] = [
            PracticeMessage(role: .sol,
                           text: "Bom dia! Bem-vindo à padaria. O que você gostaria de pedir?",
                           translation: "Good morning! Welcome to the bakery. What would you like to order?",
                           translationNotes: "'gostaria' = polite conditional — very natural for ordering"),
            PracticeMessage(role: .sol,
                           text: "Claro! Um cafezinho e um pão de queijo. Mais alguma coisa?",
                           translation: "Sure! A little coffee and a cheese bread. Anything else?",
                           translationNotes: "'cafezinho' — the diminutive '-inho' makes it warm and casual"),
            PracticeMessage(role: .coaching,
                           text: "💡 Nice! You used 'gostaria' — that's the polite conditional form. Very natural."),
            PracticeMessage(role: .sol,
                           text: "São quatro e cinquenta. Vai pagar com cartão ou dinheiro?",
                           translation: "That's four fifty. Are you paying with card or cash?",
                           translationNotes: "'vai pagar' — using 'ir + infinitive' for near future is very common in spoken Portuguese"),
            PracticeMessage(role: .sol,
                           text: "Pronto! Aqui está o seu cafezinho. Bom apetite! 😊",
                           translation: "Done! Here's your coffee. Enjoy! 😊",
                           translationNotes: "'pronto' = 'ready/done' — Brazilians use this constantly"),
            PracticeMessage(role: .coaching,
                           text: "🧠 You said 'eu quero pagar com cartão' — that works! But a native might say 'vou pagar no cartão' — the preposition changes."),
            PracticeMessage(role: .sol,
                           text: "Então, o que mais você costuma pedir quando vai na padaria?",
                           translation: "So, what else do you usually order when you go to the bakery?",
                           translationNotes: "'costuma' = 'usually do' — great word for habitual actions"),
            PracticeMessage(role: .sol,
                           text: "Que legal! Eu adoro coxinha também. Aqui no Rio tem as melhores!",
                           translation: "How cool! I love coxinha too. Here in Rio they have the best ones!",
                           translationNotes: "'que legal' — the most common casual way to say 'cool/awesome' in Brazil"),
        ]
        return responses[min(index, responses.count - 1)]
    }
}

struct PracticeMessage: Identifiable {
    let id = UUID()
    let role: Role
    let text: String
    /// English translation for Sol's Portuguese messages (revealed on double-tap)
    var translation: String?
    /// Optional notes about slang, idioms, etc.
    var translationNotes: String?
    /// How a native speaker would say the user's message (revealed on double-tap)
    var nativeVersion: String?
    /// Notes about what was improved in the native version
    var nativeNotes: String?
    /// For coaching tips: the isolated phrase to save (e.g. "tá ligado")
    var saveablePhrase: String?
    /// For coaching tips: the meaning of the phrase
    var saveableMeaning: String?

    enum Role {
        case sol
        case user
        case coaching
    }
}

// MARK: - Practice TTS Service (Google WaveNet for Sol's voice)

class PracticeTTSService: NSObject, AVAudioPlayerDelegate {
    var audioPlayer: AVAudioPlayer?
    private var onComplete: (() -> Void)?
    private var onNearlyDone: (() -> Void)?
    private var nearlyDoneTimer: Timer?
    private var audioSessionReady = false

    override init() {
        super.init()
        // Set up audio session once so playback doesn't clip the beginning
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            audioSessionReady = true
        } catch {
            NSLog("PracticeTTS: audio session setup failed: \(error)")
        }
    }

    private func googleLocale(for language: String) -> String {
        LanguageManager.ttsLocale(for: String(language.prefix(2)))
    }

    /// Speaking rate based on user level
    var speakingRate: Double = 0.95  // default B1-B2

    /// Thread-safe nearlyDone firing — guarantees it only fires ONCE per speak() call.
    private func fireNearlyDoneOnce() {
        guard let cb = onNearlyDone else { return }
        onNearlyDone = nil  // Clear BEFORE calling to prevent re-entry
        nearlyDoneTimer?.invalidate()
        nearlyDoneTimer = nil
        cb()
    }

    func speak(text: String, language: String, nearlyDone: (() -> Void)? = nil, completion: @escaping () -> Void) {
        // Cancel any in-progress audio before starting new one
        audioPlayer?.stop()
        audioPlayer = nil
        nearlyDoneTimer?.invalidate()
        nearlyDoneTimer = nil
        // Don't call old onComplete — it's stale
        onComplete = completion
        onNearlyDone = nearlyDone

        let apiKey = APIConfig.googleTTSAPIKey
        guard let url = URL(string: "\(APIConfig.googleTTSBaseURL)/text:synthesize?key=\(apiKey)") else {
            fireNearlyDoneOnce()
            completion()
            return
        }

        let locale = googleLocale(for: language)

        let body: [String: Any] = [
            "input": ["text": text],
            "voice": [
                "languageCode": locale,
                "name": "\(locale)-Neural2-A",
                "ssmlGender": "FEMALE"
            ],
            "audioConfig": [
                "audioEncoding": "MP3",
                "speakingRate": speakingRate,
                "pitch": 0.0
            ]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        request.timeoutInterval = 15

        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let self = self else { return }

            if error != nil {
                DispatchQueue.main.async {
                    self.fireNearlyDoneOnce()
                    completion()
                }
                return
            }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let audioContent = json["audioContent"] as? String,
                  let audioData = Data(base64Encoded: audioContent) else {
                DispatchQueue.main.async {
                    self.fireNearlyDoneOnce()
                    completion()
                }
                return
            }

            DispatchQueue.main.async {
                do {
                    if !self.audioSessionReady {
                        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                        try AVAudioSession.sharedInstance().setActive(true)
                        self.audioSessionReady = true
                    }

                    self.audioPlayer = try AVAudioPlayer(data: audioData)
                    self.audioPlayer?.delegate = self
                    self.audioPlayer?.prepareToPlay()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        self.audioPlayer?.play()

                        // Schedule nearlyDone 1.5s before audio ends
                        if let duration = self.audioPlayer?.duration, self.onNearlyDone != nil {
                            let fadeDelay = max(0, duration - 1.5)
                            self.nearlyDoneTimer = Timer.scheduledTimer(withTimeInterval: fadeDelay, repeats: false) { [weak self] _ in
                                DispatchQueue.main.async {
                                    self?.fireNearlyDoneOnce()
                                }
                            }
                        } else {
                            // Audio too short or no callback — reveal immediately
                            self.fireNearlyDoneOnce()
                        }
                    }
                } catch {
                    self.fireNearlyDoneOnce()
                    completion()
                }
            }
        }.resume()
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // Fire nearlyDone if it hasn't fired yet (very short clips where timer didn't get scheduled)
        fireNearlyDoneOnce()
        onComplete?()
        onComplete = nil
    }

    // MARK: - Fetch audio data without playing (for pre-caching)

    func fetchAudio(text: String, language: String, completion: @escaping (Data?) -> Void) {
        let apiKey = APIConfig.googleTTSAPIKey
        guard let url = URL(string: "\(APIConfig.googleTTSBaseURL)/text:synthesize?key=\(apiKey)") else {
            completion(nil)
            return
        }

        let locale = googleLocale(for: language)
        let body: [String: Any] = [
            "input": ["text": text],
            "voice": ["languageCode": locale, "name": "\(locale)-Neural2-A", "ssmlGender": "FEMALE"],
            "audioConfig": ["audioEncoding": "MP3", "speakingRate": speakingRate, "pitch": 0.0]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        request.timeoutInterval = 15

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let audioContent = json["audioContent"] as? String,
                  let audioData = Data(base64Encoded: audioContent) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            DispatchQueue.main.async { completion(audioData) }
        }.resume()
    }

    // MARK: - Play from cached data (instant, no network)

    func playData(_ data: Data) {
        do {
            // Always re-set session — recording may have switched it to .record
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            audioSessionReady = true

            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                self.audioPlayer?.play()
            }
        } catch {
            NSLog("PracticeTTS: playData error: \(error)")
        }
    }
}

// MARK: - Talk Drill View (Pronunciation Practice)

struct TalkDrillView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var currentAttempt = 0
    @State private var scores: [Int] = []
    @State private var isRecording = false
    @State private var showResult = false
    @State private var currentWordIndex = 0
    @State private var cachedAudio: [String: Data] = [:]  // word → MP3 data
    @State private var lastHeard = ""
    private let ttsService = PracticeTTSService()
    private let scorer = PronunciationScorer()

    private let drillWords = [
        (word: "porta", meaning: "door", tip: "Soften the R — think of a gentle 'h' sound at the back of your throat"),
        (word: "carro", meaning: "car", tip: "The double R is stronger — like a soft gargle, not the English R"),
        (word: "correr", meaning: "to run", tip: "Both Rs here — the middle one is soft, the final one fades out"),
    ]

    private var currentDrill: (word: String, meaning: String, tip: String) {
        drillWords[currentWordIndex % drillWords.count]
    }

    var body: some View {
        NavigationView {
            ZStack {
                TSGradientBackground().ignoresSafeArea()

                if currentAttempt >= 3 {
                    completedView
                } else if showResult {
                    resultView
                } else {
                    drillView
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Done")
                                .font(.custom("HelveticaNeue-Medium", size: 15))
                        }
                        .foregroundColor(.tsAccent)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Text("Attempt \(min(currentAttempt + 1, 3))/3")
                        .font(.custom("HelveticaNeue-Bold", size: 13))
                        .foregroundColor(.tsSecondary)
                }
            }
            .onAppear { prefetchAllAudio() }
        }
    }

    // MARK: - Pre-fetch Audio

    private func prefetchAllAudio() {
        for drill in drillWords {
            ttsService.fetchAudio(text: drill.word, language: "pt-BR") { data in
                if let data = data {
                    cachedAudio[drill.word] = data
                    NSLog("🔊 [Drill] pre-cached: \(drill.word) (\(data.count) bytes)")
                }
            }
        }
    }

    private func playWord(_ word: String) {
        if let cached = cachedAudio[word] {
            ttsService.playData(cached)
        } else {
            ttsService.speak(text: word, language: LanguageManager.ttsLocale(for: LanguageManager.shared.targetLangRequired)) {}
        }
    }

    private var drillView: some View {
        VStack(spacing: 32) {
            Spacer()

            Text("YOUR R SOUND")
                .font(.custom("HelveticaNeue-Bold", size: 11))
                .foregroundColor(.tsSecondary)
                .kerning(1.2)

            VStack(spacing: 8) {
                Text(currentDrill.word)
                    .font(.custom("HelveticaNeue-Bold", size: 44))
                    .foregroundColor(.tsLabel)
                Text("(\(currentDrill.meaning))")
                    .font(.custom("HelveticaNeue", size: 16))
                    .foregroundColor(.tsSecondary)
            }

            Text("💡 \(currentDrill.tip)")
                .font(.custom("HelveticaNeue", size: 14))
                .foregroundColor(.tsSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .lineSpacing(2)

            Spacer()

            VStack(spacing: 16) {
                Button {
                    playWord(currentDrill.word)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 16))
                        Text("Hear native")
                            .font(.custom("HelveticaNeue-Medium", size: 16))
                    }
                    .foregroundColor(.tsAccent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.tsAccent.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Button {
                    isRecording = true
                    scorer.scorePronounciation(
                        targetWord: currentDrill.word,
                        language: "pt-BR",
                        duration: 3.0
                    ) { score, heard, feedback in
                        isRecording = false
                        lastHeard = heard
                        scores.append(score)
                        showResult = true
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: isRecording ? "stop.circle.fill" : "mic.fill")
                            .font(.system(size: 16))
                        Text(isRecording ? "Recording..." : "Record yourself")
                            .font(.custom("HelveticaNeue-Bold", size: 16))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(isRecording ? Color.red.opacity(0.8) : Color.tsAccent)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(isRecording)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }

    private var resultView: some View {
        VStack(spacing: 24) {
            Spacer()

            let score = scores.last ?? 0
            ZStack {
                Circle()
                    .stroke(Color.tsSecondary.opacity(0.12), lineWidth: 8)
                    .frame(width: 120, height: 120)
                Circle()
                    .trim(from: 0, to: CGFloat(score) / 100.0)
                    .stroke(
                        score >= 80 ? Color(hex: "#34C759") : (score >= 60 ? Color(hex: "#FF9500") : Color.red),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 2) {
                    Text("\(score)")
                        .font(.custom("HelveticaNeue-Bold", size: 36))
                        .foregroundColor(.tsLabel)
                    Text("/ 100")
                        .font(.custom("HelveticaNeue", size: 13))
                        .foregroundColor(.tsSecondary)
                }
            }

            Text("\"\(currentDrill.word)\"")
                .font(.custom("HelveticaNeue-Bold", size: 24))
                .foregroundColor(.tsLabel)

            // Show what was heard vs target
            if !lastHeard.isEmpty && lastHeard.lowercased() != currentDrill.word.lowercased() {
                Text("I heard: \"\(lastHeard)\"")
                    .font(.custom("HelveticaNeue", size: 14))
                    .foregroundColor(.tsSecondary)
                    .italic()
            }

            Text(score >= 90
                 ? "Excellent! That sounded very natural. 👏"
                 : score >= 75
                 ? "Good! The sounds are coming together. Keep refining."
                 : score >= 50
                 ? "Almost — listen to the native version again and match each sound."
                 : "Try listening to the native version and focus on the R sound.")
                .font(.custom("HelveticaNeue", size: 15))
                .foregroundColor(.tsSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .lineSpacing(2)

            // Replay native for comparison
            Button {
                playWord(currentDrill.word)
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.system(size: 13))
                    Text("Hear native again")
                        .font(.custom("HelveticaNeue-Medium", size: 14))
                }
                .foregroundColor(.tsAccent)
            }

            Spacer()

            Button {
                showResult = false
                currentAttempt += 1
                if currentAttempt < 3 {
                    currentWordIndex += 1
                }
            } label: {
                Text(currentAttempt < 2 ? "Try next word →" : "See results")
                    .font(.custom("HelveticaNeue-Bold", size: 16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(LinearGradient.tsVibrant)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }

    private var completedView: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("💪")
                .font(.system(size: 56))

            Text("Nice work!")
                .font(.custom("HelveticaNeue-Bold", size: 24))
                .foregroundColor(.tsLabel)

            HStack(spacing: 20) {
                ForEach(0..<scores.count, id: \.self) { i in
                    VStack(spacing: 4) {
                        Text("\(scores[i])")
                            .font(.custom("HelveticaNeue-Bold", size: 22))
                            .foregroundColor(scores[i] >= 80 ? Color(hex: "#34C759") : Color(hex: "#FF9500"))
                        Text(drillWords[i % drillWords.count].word)
                            .font(.custom("HelveticaNeue", size: 12))
                            .foregroundColor(.tsSecondary)
                    }
                    if i < scores.count - 1 {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12))
                            .foregroundColor(.tsSecondary)
                    }
                }
            }

            let improving = scores.count >= 2 && scores.last! > scores.first!
            Text(improving
                 ? "You're improving! Each word got a little better."
                 : "Keep at it — the R sound takes time. You'll get there.")
                .font(.custom("HelveticaNeue", size: 15))
                .foregroundColor(.tsSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .lineSpacing(2)

            Text("Next time we'll try different words — same R sound, fresh start.")
                .font(.custom("HelveticaNeue", size: 13))
                .foregroundColor(.tsSecondary)
                .italic()
                .padding(.horizontal, 40)

            Spacer()

            Button { dismiss() } label: {
                Text("Done")
                    .font(.custom("HelveticaNeue-Bold", size: 16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(LinearGradient.tsVibrant)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
}

// MARK: - Pulsating Waveform

struct PulsatingWaveformView: View {
    var isAnimating: Bool
    var color: Color = .tsAccent
    var barCount: Int = 5

    // Each bar gets a phase offset so they animate out-of-sync
    private let phases: [Double] = [0.0, 0.15, 0.3, 0.15, 0.0]
    private let minHeight: CGFloat = 3
    private let maxHeight: CGFloat = 18

    @State private var heights: [CGFloat] = [3, 3, 3, 3, 3]

    var body: some View {
        HStack(alignment: .center, spacing: 3) {
            ForEach(0..<barCount, id: \.self) { i in
                RoundedRectangle(cornerRadius: 2)
                    .fill(color)
                    .frame(width: 3, height: heights[i])
                    .animation(
                        isAnimating
                            ? Animation
                                .easeInOut(duration: 0.55)
                                .repeatForever(autoreverses: true)
                                .delay(phases[i])
                            : .easeOut(duration: 0.25),
                        value: heights[i]
                    )
            }
        }
        .frame(height: maxHeight)
        .onChange(of: isAnimating) {
            updateHeights(animating: isAnimating)
        }
        .onAppear {
            updateHeights(animating: isAnimating)
        }
    }

    private func updateHeights(animating: Bool) {
        if animating {
            // Kick off staggered animations by setting different target heights
            for i in 0..<barCount {
                let delay = phases[i]
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    heights[i] = CGFloat.random(in: 10...maxHeight)
                    // Keep re-randomizing to maintain organic feel
                    scheduleRandomHeight(for: i)
                }
            }
        } else {
            for i in 0..<barCount {
                heights[i] = minHeight
            }
        }
    }

    private func scheduleRandomHeight(for index: Int) {
        guard isAnimating else { return }
        let interval = Double.random(in: 0.4...0.7)
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            guard isAnimating else {
                heights[index] = minHeight
                return
            }
            withAnimation(.easeInOut(duration: interval)) {
                heights[index] = CGFloat.random(in: minHeight...maxHeight)
            }
            scheduleRandomHeight(for: index)
        }
    }
}

#Preview {
    CoachView()
}
