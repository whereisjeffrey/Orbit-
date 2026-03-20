
//
//  CoachView.swift
//  TranslateHelper
//
//  Coach tab — mistake inventory display + Pronunciation Clinic entry.
//

import SwiftUI

struct CoachView: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject private var mistakeStore = PronunciationMistakeStore.shared

    @State private var showClinic = false
    @State private var showDebugMenu = false

    var body: some View {
        ZStack {
            TSGradientBackground().ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // ── Header ────────────────────────────────────────────
                    HStack {
                        Text("Coach")
                            .font(.custom("HelveticaNeue-Bold", size: 28))
                            .foregroundColor(.tsLabel)
                        Spacer()
                        #if DEBUG
                        Menu {
                            Button("🌱 Seed Spanish test words") {
                                mistakeStore.seedTestData(language: "es")
                            }
                            Button("🌱 Seed French test words") {
                                mistakeStore.seedTestData(language: "fr")
                            }
                            Button(role: .destructive) {
                                mistakeStore.clearAll()
                            } label: {
                                Label("Clear all data", systemImage: "trash")
                            }
                        } label: {
                            Label("Test", systemImage: "wrench.and.screwdriver")
                                .font(.custom("HelveticaNeue", size: 13))
                                .foregroundColor(.tsSecondary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.tsCard)
                                .clipShape(Capsule())
                        }
                        #endif
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 24)

                    // ── Pronunciation Clinic card (shows when words queued) ──
                    if !mistakeStore.clinicQueue.isEmpty {
                        clinicCard
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .move(edge: .top)),
                                removal: .opacity
                            ))
                    }

                    // ── Mastered words strip ───────────────────────────────
                    if !mistakeStore.mastered.isEmpty {
                        masteredSection
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                    }

                    // ── Coach placeholder / coming soon ────────────────────
                    coachPlaceholder
                        .padding(.horizontal, 20)

                    Spacer(minLength: 40)
                }
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: mistakeStore.clinicQueue.isEmpty)
        .sheet(isPresented: $showClinic) {
            PronunciationClinicView()
        }
    }

    // MARK: - Pronunciation Clinic Card

    private var clinicCard: some View {
        Button { showClinic = true } label: {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.tsAccent.opacity(0.12))
                        .frame(width: 56, height: 56)
                    Image(systemName: "mic.badge.plus")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.tsAccent, Color(hex: "#00C7BE")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text("Pronunciation Clinic")
                            .font(.custom("HelveticaNeue-Bold", size: 16))
                            .foregroundColor(.tsLabel)

                        // Badge count
                        Text("\(mistakeStore.clinicQueue.count)")
                            .font(.custom("HelveticaNeue-Bold", size: 11))
                            .foregroundColor(.white)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(Color.tsAccent)
                            .clipShape(Capsule())
                    }

                    Text(clinicSubtitle)
                        .font(.custom("HelveticaNeue", size: 13))
                        .foregroundColor(.tsSecondary)
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.tsAccent)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(colorScheme == .dark ? Color.tsCard : Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.tsAccent.opacity(0.15), lineWidth: 1)
            )
            .shadow(
                color: Color.tsAccent.opacity(colorScheme == .dark ? 0.08 : 0.10),
                radius: 12, x: 0, y: 4
            )
        }
        .buttonStyle(.plain)
    }

    private var clinicSubtitle: String {
        let count = mistakeStore.clinicQueue.count
        let worst = mistakeStore.clinicQueue.first
        if let w = worst {
            return count == 1
                ? "Time to practice \"\(w.word)\" — flagged \(w.missCount) times."
                : "\(count) words need practice. Start with \"\(w.word)\"."
        }
        return "\(count) word\(count == 1 ? "" : "s") ready to practice."
    }

    // MARK: - Mastered Section

    private var masteredSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#34C759"))
                Text("Mastered")
                    .font(.custom("HelveticaNeue-Bold", size: 16))
                    .foregroundColor(.tsLabel)
                Spacer()
                Text("\(mistakeStore.mastered.count)")
                    .font(.custom("HelveticaNeue", size: 14))
                    .foregroundColor(.tsSecondary)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(mistakeStore.mastered) { word in
                        Text(word.word)
                            .font(.custom("HelveticaNeue-Medium", size: 14))
                            .foregroundColor(Color(hex: "#34C759"))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color(hex: "#34C759").opacity(0.10))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule().stroke(Color(hex: "#34C759").opacity(0.20), lineWidth: 1)
                            )
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? Color.tsCard : Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "#34C759").opacity(0.12), lineWidth: 1)
        )
    }

    // MARK: - Coach Placeholder

    private var coachPlaceholder: some View {
        VStack(spacing: 0) {

            // ── Icon ──────────────────────────────────────────────
            ZStack {
                Circle()
                    .fill(Color.tsAccent.opacity(0.10))
                    .frame(width: 120, height: 120)
                Circle()
                    .fill(Color.tsAccent.opacity(0.06))
                    .frame(width: 160, height: 160)

                Image(systemName: "waveform.and.person.filled")
                    .font(.system(size: 52, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.tsAccent, Color(hex: "#00C7BE")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .padding(.bottom, 32)
            .padding(.top, mistakeStore.clinicQueue.isEmpty ? 40 : 0)

            // ── Heading ───────────────────────────────────────────
            Text("Your personal language coach")
                .font(.custom("HelveticaNeue-Bold", size: 22))
                .foregroundColor(.tsLabel)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.bottom, 12)

            Text("Coach listens to every audio you send, catches your mistakes, and quietly builds a working inventory of what to improve — so you get better without even trying.")
                .font(.custom("HelveticaNeue", size: 15))
                .foregroundColor(.tsSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 40)
                .padding(.bottom, 40)

            // ── Feature pills ─────────────────────────────────────
            VStack(spacing: 12) {
                CoachFeaturePill(icon: "waveform",               text: "Real-time audio correction")
                CoachFeaturePill(icon: "chart.line.uptrend.xyaxis", text: "Working mistake inventory")
                CoachFeaturePill(icon: "mic.badge.plus",          text: "Pronunciation clinic")
                CoachFeaturePill(icon: "sparkles",               text: "Pattern recognition across sessions")
                CoachFeaturePill(icon: "checkmark.seal.fill",    text: "Celebrates when you nail it")
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)

            // ── Pricing ───────────────────────────────────────────
            VStack(spacing: 8) {
                Text("Coming soon · Coach plan")
                    .font(.custom("HelveticaNeue-Bold", size: 13))
                    .foregroundColor(.tsAccent)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.tsAccent.opacity(0.10))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.tsAccent.opacity(0.20), lineWidth: 1))

                HStack(spacing: 16) {
                    VStack(spacing: 2) {
                        Text("$14.99")
                            .font(.custom("HelveticaNeue-Bold", size: 22))
                            .foregroundColor(.tsLabel)
                        Text("/ month")
                            .font(.custom("HelveticaNeue", size: 11))
                            .foregroundColor(.tsSecondary)
                    }
                    Rectangle()
                        .fill(Color.tsSecondary.opacity(0.2))
                        .frame(width: 1, height: 32)
                    VStack(spacing: 2) {
                        Text("$149.99")
                            .font(.custom("HelveticaNeue-Bold", size: 22))
                            .foregroundColor(.tsLabel)
                        Text("/ year  ·  2 months free")
                            .font(.custom("HelveticaNeue", size: 11))
                            .foregroundColor(.tsSecondary)
                    }
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 14)
                .background(Color.tsCard)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.tsAccent.opacity(0.12), lineWidth: 1))

                Text("Billed $149.99 after your first 30 days. Cancel anytime before then.")
                    .font(.custom("HelveticaNeue", size: 11))
                    .foregroundColor(.tsSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
    }
}

// MARK: - Feature Pill

private struct CoachFeaturePill: View {
    let icon: String
    let text: String
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.tsAccent.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.tsAccent)
            }

            Text(text)
                .font(.custom("HelveticaNeue-Medium", size: 15))
                .foregroundColor(.tsLabel)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(colorScheme == .dark ? Color.tsCard : Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5)
        )
    }
}
