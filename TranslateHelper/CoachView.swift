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

                    howItWorksRow(icon: "pencil.and.outline", text: "Write or send audios like you normally do — in WhatsApp, Tinder, Instagram, anywhere")
                    howItWorksRow(icon: "target", text: "I'll give you 1-2 tips per message — pronunciation, grammar, or both")
                    howItWorksRow(icon: "chart.line.uptrend.xyaxis", text: "Over time, I'll track your patterns and show you exactly where you're improving")
                    howItWorksRow(icon: "brain.head.profile", text: "I know your native language brain will try to trick you — I'll help you untrain those habits")
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
                        .font(.custom("HelveticaNeue", size: 13))
                        .foregroundColor(.tsSecondary)
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

    private func howItWorksRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.tsAccent)
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
                .opacity(unlocked ? 1 : 0.4)

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
                Text("You've been killing it this week, Jeffrey. 3 mistakes graduated.")
                    .font(.custom("HelveticaNeue-Medium", size: 14))
                    .foregroundColor(.tsLabel)
                    .lineSpacing(2)

                Text("Last active: 2 hours ago")
                    .font(.custom("HelveticaNeue", size: 12))
                    .foregroundColor(.tsSecondary)
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.tsCard)
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
                scoreGauge(label: "Grammar", level: "A2", progress: 0.4, color: Color.tsAccent, locked: false)
                scoreGauge(label: "Vocabulary", level: "—", progress: 0, color: .tsSecondary, locked: true)
                scoreGauge(label: "Fluency", level: "—", progress: 0, color: .tsSecondary, locked: true)
            }

            HStack {
                Image(systemName: "sparkles")
                    .font(.system(size: 12))
                    .foregroundColor(.tsAccent)
                Text("2 more unlock with more audio")
                    .font(.custom("HelveticaNeue", size: 13))
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
                        .stroke(color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
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

    private var weeklySnapshot: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("📊")
                    .font(.system(size: 16))
                Text("THIS WEEK")
                    .font(.custom("HelveticaNeue-Bold", size: 11))
                    .foregroundColor(.tsSecondary)
                    .kerning(1.2)
                Spacer()
                Text("Mar 17–22")
                    .font(.custom("HelveticaNeue", size: 12))
                    .foregroundColor(.tsSecondary)
            }

            VStack(alignment: .leading, spacing: 12) {
                weeklyRow(icon: "checkmark.circle.fill", color: Color(hex: "#34C759"), text: "Win: Graduated 'ser vs estar'")
                weeklyRow(icon: "pencil.circle.fill", color: Color.tsAccent, text: "Work on: Gender agreement (72%)")
                weeklyRow(icon: "target", color: Color(hex: "#FF9500"), text: "Challenge: Try ordering food without switching to English")
            }

            Button {} label: {
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
    }

    private func weeklyRow(icon: String, color: Color, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
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

            tipCard(icon: "🗣", date: "Mar 22, 5:23 PM", text: "Watch the nasal 'ão' in 'coração' — tongue further back.", color: Color.tsAccent)
            tipCard(icon: "💡", date: "Mar 22, 4:45 PM", text: "'a casa dele' not 'do ele.' Portuguese flips possession.", color: Color(hex: "#FF9500"))
            tipCard(icon: "🎉", date: "Mar 21", text: "MILESTONE: ser/estar not confused in 14 days!", color: Color(hex: "#FFD700"))

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
                .fill(Color.tsCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.tsBorder, lineWidth: 1)
        )
    }

    private func tipCard(icon: String, date: String, text: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(icon)
                    .font(.system(size: 14))
                Text(date)
                    .font(.custom("HelveticaNeue", size: 11))
                    .foregroundColor(.tsSecondary)
                Spacer()
            }
            Text(text)
                .font(.custom("HelveticaNeue", size: 14))
                .foregroundColor(.tsLabel)
                .lineSpacing(2)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.06))
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

            Button {} label: {
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


#Preview {
    CoachView()
}
