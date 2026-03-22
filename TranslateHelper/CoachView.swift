//
//  CoachView.swift
//  TranslateHelper
//
//  Coach tab — empty state (new user) + populated state (with data).
//  Uses TSGradientBackground, HelveticaNeue, tsCard, tsAccent from DesignSystem.

import SwiftUI

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

    @AppStorage("talkswitch_target_lang") private var targetLang = "es"

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

                // ── Sol avatar placeholder ──────────────────────
                Circle()
                    .fill(Color.tsAccent.opacity(0.12))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Circle()
                            .stroke(Color.tsAccent.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.top, 48)
                    .padding(.bottom, 16)

                // ── Greeting ────────────────────────────────────
                Text("Hey, I'm Sol. 👋")
                    .font(.custom("HelveticaNeue-Bold", size: 24))
                    .foregroundColor(.tsLabel)
                    .padding(.bottom, 8)

                Text("I'm your language coach — and I live inside your keyboard.")
                    .font(.custom("HelveticaNeue", size: 15))
                    .foregroundColor(.tsSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 4)

                Text("Every time you write or send an audio, I listen and give you tips to sound more natural. The more you speak, the smarter I get.")
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

                    howItWorksRow(icon: "pencil.and.outline", color: Color.tsAccent, text: "Write or send audios like you normally do — in WhatsApp, Tinder, Instagram, anywhere")
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
                Text("Open any messaging app, switch to the Orbit keyboard, and tap the mic button. I'll be listening. 😊")
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

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {

                // ── Header ──────────────────────────────────────
                HStack {
                    Text("Coach")
                        .font(.custom("HelveticaNeue-Bold", size: 28))
                        .foregroundColor(.tsLabel)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 24)

                // ── 1. Coach Greeting Card ───────────────────────
                greetingCard
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)

                // ── 2. Score Overview (4 gauges) ─────────────────
                scoreOverview
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)

                // ── 3. Weekly Snapshot ────────────────────────────
                weeklySnapshot
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)

                // ── 4. Recent Tips Feed ───────────────────────────
                recentTips
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)

                // ── 5. Practice Mode Card ────────────────────────
                practiceCard
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)

                // ── 6. Milestones ────────────────────────────────
                milestonesCard
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)

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
    }

    // MARK: - 1. Greeting Card

    private var greetingCard: some View {
        HStack(spacing: 16) {
            // Sol placeholder
            Circle()
                .fill(Color.tsAccent.opacity(0.12))
                .frame(width: 48, height: 48)
                .overlay(
                    Circle()
                        .stroke(Color.tsAccent.opacity(0.2), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text("Your Portuguese is getting sharper every week. Grammar just hit B1 — that's a big jump.")
                    .font(.custom("HelveticaNeue-Medium", size: 14))
                    .foregroundColor(.tsLabel)
                    .lineSpacing(2)

                Text("127 voice messages · 3 months active")
                    .font(.custom("HelveticaNeue", size: 12))
                    .foregroundColor(.tsSecondary)
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color(hex: "#1E1E1E") : Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.tsBorder, lineWidth: 1)
        )
    }

    // MARK: - 2. Score Overview

    private var scoreOverview: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("YOUR LEVEL")
                .font(.custom("HelveticaNeue-Bold", size: 11))
                .foregroundColor(.tsSecondary)
                .kerning(1.2)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                scoreGauge(label: "Pronunciation", level: "B1", progress: 0.65, color: Color(hex: "#34C759"), locked: false)
                scoreGauge(label: "Grammar", level: "B1", progress: 0.55, color: Color.tsAccent, locked: false)
                scoreGauge(label: "Vocabulary", level: "B2", progress: 0.72, color: Color(hex: "#FF9500"), locked: false)
                scoreGauge(label: "Fluency", level: "A2", progress: 0.38, color: Color(hex: "#AF52DE"), locked: false)
            }

            HStack(spacing: 6) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "#34C759"))
                Text("All categories active · Based on 127 voice messages")
                    .font(.custom("HelveticaNeue", size: 12))
                    .foregroundColor(.tsSecondary)
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
                            AngularGradient(
                                gradient: Gradient(colors: [color.opacity(0.4), color]),
                                center: .center,
                                startAngle: .degrees(-90),
                                endAngle: .degrees(-90 + 360 * Double(progress))
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

    @State private var showFullReport = false
    @State private var showPracticeSession = false

    private var weeklySnapshot: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("📅")
                    .font(.system(size: 14))
                Text("THIS WEEK")
                    .font(.custom("HelveticaNeue-Bold", size: 11))
                    .foregroundColor(.tsSecondary)
                    .kerning(1.2)
                Spacer()
                Text("Mar 17–22")
                    .font(.custom("HelveticaNeue", size: 12))
                    .foregroundColor(.tsSecondary)
            }

            // ── Stats row ───────────────────────────────────
            HStack(spacing: 16) {
                statPill(value: "23", label: "messages")
                statPill(value: "12", label: "min audio")
                statPill(value: "74", label: "avg score")
            }

            Divider().opacity(0.3)

            // ── Summary ─────────────────────────────────────
            VStack(alignment: .leading, spacing: 12) {
                weeklyRow(emoji: "✅", text: "Win: Graduated 'ser vs estar'")
                weeklyRow(emoji: "✏️", text: "Work on: Gender agreement (72%)")
                weeklyRow(emoji: "🎯", text: "Challenge: Try ordering food without switching to English")
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
                .fill(Color.tsCard)
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
                .fill(Color.tsGrayCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(UIColor.systemGray5).opacity(colorScheme == .dark ? 0 : 0.25))
                )
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

    // MARK: - 5. Practice Mode Card

    private var practiceCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("💬")
                    .font(.system(size: 16))
                Text("PRACTICE")
                    .font(.custom("HelveticaNeue-Bold", size: 11))
                    .foregroundColor(.tsSecondary)
                    .kerning(1.2)
                Spacer()
            }

            Text("You've been struggling with past subjunctive. Want to work on it?")
                .font(.custom("HelveticaNeue", size: 14))
                .foregroundColor(.tsLabel)
                .lineSpacing(2)

            Button { showPracticeSession = true } label: {
                Text("Start Session")
                    .font(.custom("HelveticaNeue-Bold", size: 15))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient.tsVibrant
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
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
                .fill(Color.tsCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.tsAccent.opacity(0.15), lineWidth: 1)
        )
        .shadow(
            color: Color.tsAccent.opacity(colorScheme == .dark ? 0.06 : 0.08),
            radius: 12, x: 0, y: 4
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
                HStack(spacing: 12) {
                    milestoneBadge(label: "ser/\nestar", status: .graduated, month: "Oct")
                    milestoneBadge(label: "gender\n-ade", status: .graduated, month: "Nov")
                    milestoneBadge(label: "article\nusage", status: .graduated, month: "Dec")
                    milestoneBadge(label: "prep\na/em", status: .inProgress(14, 20), month: nil)
                    milestoneBadge(label: "past\nsubj.", status: .inProgress(6, 20), month: nil)
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
                    VStack(spacing: 2) {
                        Text("\(current)/\(total)")
                            .font(.custom("HelveticaNeue-Bold", size: 13))
                            .foregroundColor(.tsLabel)
                        // Mini progress bar
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
                        .frame(width: 40, height: 4)
                    }
                }
            }

            Text(label)
                .font(.custom("HelveticaNeue-Medium", size: 10))
                .foregroundColor(.tsLabel)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 64)

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
                            Text("March 17 – 22, 2026")
                                .font(.custom("HelveticaNeue", size: 14))
                                .foregroundColor(.tsSecondary)
                        }

                        // ── Wins ────────────────────────────────
                        reportSection(title: "WINS", icon: "🎉") {
                            VStack(alignment: .leading, spacing: 10) {
                                reportRow("Graduated: ser vs estar — 14 days clean")
                                reportRow("Gender accuracy: 72% → 81%")
                                reportRow("New words used: 'saudade', 'madrugada', 'concorrência'")
                            }
                        }

                        // ── Work On ─────────────────────────────
                        reportSection(title: "WORK ON", icon: "📝") {
                            VStack(alignment: .leading, spacing: 10) {
                                reportRow("Gender agreement: 81% — defaulting to masculine with -ade words")
                                reportRow("Prepositions: 'em' vs 'a' for direction (72% accuracy)")
                                reportRow("Past subjunctive: emerging pattern, 3 occurrences this week")
                            }
                        }

                        // ── By the Numbers ──────────────────────
                        reportSection(title: "BY THE NUMBERS", icon: "📊") {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                numberCard(value: "47", label: "Messages sent")
                                numberCard(value: "23", label: "Voice messages")
                                numberCard(value: "12", label: "Minutes of audio")
                                numberCard(value: "74", label: "Avg pronunciation")
                            }
                        }

                        // ── Trends ──────────────────────────────
                        reportSection(title: "TRENDS", icon: "📈") {
                            VStack(alignment: .leading, spacing: 10) {
                                trendRow(category: "Pronunciation", direction: "↑", detail: "improving", color: Color(hex: "#34C759"))
                                trendRow(category: "Grammar", direction: "↑", detail: "big jump to B1", color: Color.tsAccent)
                                trendRow(category: "Vocabulary", direction: "↑", detail: "growing steadily", color: Color(hex: "#FF9500"))
                                trendRow(category: "Fluency", direction: "→", detail: "plateau — try slowing down", color: Color(hex: "#AF52DE"))
                            }
                        }

                        // ── Challenge ────────────────────────────
                        reportSection(title: "THIS WEEK'S CHALLENGE", icon: "🎯") {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Try ordering food at a restaurant without switching to English.")
                                    .font(.custom("HelveticaNeue", size: 14))
                                    .foregroundColor(.tsLabel)
                                    .lineSpacing(2)
                                Text("You have the vocabulary for it — 'eu gostaria de...' is your friend.")
                                    .font(.custom("HelveticaNeue", size: 13))
                                    .foregroundColor(.tsSecondary)
                                    .italic()
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
                .fill(Color.tsCard)
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
                .fill(Color.tsAccent.opacity(0.06))
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

// MARK: - Practice Session (full-screen chat)

struct PracticeSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var userInput = ""
    @State private var messages: [PracticeMessage] = [
        PracticeMessage(role: .sol,
                        text: "Oi! 👋 Então, você mora no Rio, né? Já tentou pedir um cafezinho numa padaria sem trocar pro inglês? Vamos praticar isso. Eu vou ser o cara do balcão. Você entra na padaria...",
                        translation: "Hey! 👋 So, you live in Rio, right? Have you tried ordering a coffee at a bakery without switching to English? Let's practice that. I'll be the guy behind the counter. You walk into the bakery...",
                        translationNotes: "'trocar pro inglês' = 'switch to English' — very natural, casual phrasing"),
        PracticeMessage(role: .coaching,
                        text: "💡 I'll be speaking in Portuguese. Try to respond in Portuguese too — don't worry about mistakes, that's what I'm here for."),
    ]

    @State private var messageCount = 0
    @State private var revealedTranslations: Set<UUID> = []
    @State private var showDoubleTapHint = false
    @AppStorage("practice_doubletap_validated") private var doubleTapValidated = false
    @AppStorage("practice_doubletap_dismiss_count") private var doubleTapDismissCount = 0
    private let maxMessages = 10

    var body: some View {
        ZStack {
            TSGradientBackground().ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Header ──────────────────────────────────
                HStack {
                    Button { dismiss() } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                            Text("End session")
                                .font(.custom("HelveticaNeue-Medium", size: 15))
                        }
                        .foregroundColor(.tsAccent)
                    }

                    Spacer()

                    Text("\(messageCount)/\(maxMessages)")
                        .font(.custom("HelveticaNeue-Bold", size: 13))
                        .foregroundColor(.tsSecondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.tsCard)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)

                Divider().opacity(0.2)

                // ── Double-tap hint card ─────────────────────
                if showDoubleTapHint {
                    HStack(spacing: 12) {
                        Text("👆👆")
                            .font(.system(size: 20))

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Don't understand something?")
                                .font(.custom("HelveticaNeue-Bold", size: 13))
                                .foregroundColor(.tsLabel)
                            Text("Double-tap any message for the English translation. Give it a try!")
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
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }

                // ── Chat messages ────────────────────────────
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            ForEach(messages) { message in
                                chatBubble(message: message)
                                    .id(message.id)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                    .onChange(of: messages.count) { _ in
                        if let last = messages.last {
                            withAnimation {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                }

                // ── Input bar ────────────────────────────────
                VStack(spacing: 0) {
                    Divider().opacity(0.2)

                    HStack(spacing: 12) {
                        TextField("Type in Portuguese...", text: $userInput)
                            .font(.custom("HelveticaNeue", size: 15))
                            .foregroundColor(.tsLabel)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.tsInputBg)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.tsBorder, lineWidth: 1)
                            )

                        Button {
                            sendMessage()
                        } label: {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(userInput.isEmpty ? .tsSecondary.opacity(0.4) : .tsAccent)
                        }
                        .disabled(userInput.isEmpty)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(colorScheme == .dark ? Color.tsCard : Color.white)
                }
            }
        }
        .onAppear {
            if !doubleTapValidated && doubleTapDismissCount < 3 {
                withAnimation(.easeIn(duration: 0.3).delay(0.5)) {
                    showDoubleTapHint = true
                }
            }
        }
    }

    // MARK: - Chat Bubble

    private func chatBubble(message: PracticeMessage) -> some View {
        let isRevealed = revealedTranslations.contains(message.id)

        return HStack(alignment: .top, spacing: 10) {
            if message.role == .sol || message.role == .coaching {
                // Sol avatar
                Circle()
                    .fill(Color.tsAccent.opacity(0.12))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Circle()
                            .stroke(Color.tsAccent.opacity(0.2), lineWidth: 0.5)
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
                    Text("COACHING TIP")
                        .font(.custom("HelveticaNeue-Bold", size: 9))
                        .foregroundColor(Color(hex: "#FF9500"))
                        .kerning(0.8)
                }

                // Main message bubble
                Text(message.text)
                    .font(.custom("HelveticaNeue", size: 14))
                    .foregroundColor(message.role == .user ? .white : .tsLabel)
                    .lineSpacing(3)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(bubbleColor(for: message.role))
                    )
                    .onTapGesture(count: 2) {
                        if message.role == .sol && message.translation != nil {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                if isRevealed {
                                    revealedTranslations.remove(message.id)
                                } else {
                                    revealedTranslations.insert(message.id)
                                    // User proved they know how it works — dismiss hint permanently
                                    if !doubleTapValidated {
                                        doubleTapValidated = true
                                        withAnimation(.easeOut(duration: 0.2)) {
                                            showDoubleTapHint = false
                                        }
                                    }
                                }
                            }
                        }
                    }

                // Translation card (revealed on double-tap)
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

                        if let notes = message.translationNotes {
                            Text("💡 \(notes)")
                                .font(.custom("HelveticaNeue", size: 12))
                                .foregroundColor(.tsSecondary)
                                .italic()
                                .lineSpacing(2)
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
            return Color.tsAccent
        case .coaching:
            return Color(hex: "#FF9500").opacity(0.1)
        }
    }

    // MARK: - Send Message

    private func sendMessage() {
        let text = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        // Add user message
        messages.append(PracticeMessage(role: .user, text: text))
        userInput = ""
        messageCount += 1

        // Simulate Sol's response after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            if messageCount >= maxMessages {
                // Session wrap-up
                messages.append(PracticeMessage(role: .sol,
                    text: "Ótimo trabalho! 🎉 You used 'eu gostaria' naturally — that's a big improvement from last session.",
                    translation: "Great work! 🎉"))
                messages.append(PracticeMessage(role: .coaching,
                    text: "✨ SESSION COMPLETE: You nailed possessives today and used past subjunctive once correctly. Challenge for the week: try ordering food at a real restaurant without switching to English."))
            } else {
                let response = mockResponse(for: max(0, messageCount - 1))
                messages.append(response)
                messageCount += 1
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

    enum Role {
        case sol
        case user
        case coaching
    }
}

#Preview {
    CoachView()
}
