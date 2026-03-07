//  WeeklyLibraryWidgets.swift

import SwiftUI

private extension Calendar {
    func isThisWeek(_ date: Date) -> Bool {
        isDate(date, equalTo: Date(), toGranularity: .weekOfYear)
    }
}

// MARK: - Weekly Clipboard Widget

struct WeeklyClipboardWidget: View {
    @ObservedObject var store: SharedPhraseStore
    let onStudy: () -> Void

    private static let scrollThreshold = 7

    private var allPhrases: [SavedPhrase] {
        store.phrases.sorted { $0.savedAt > $1.savedAt }
    }

    private var addedThisWeek: [SavedPhrase] {
        store.phrases
            .filter { Calendar.current.isThisWeek($0.savedAt) }
            .sorted { $0.savedAt < $1.savedAt }
    }

    private var masteredThisWeek: Int {
        store.phrases.filter {
            $0.isConquered &&
            ($0.conqueredAt.map { Calendar.current.isThisWeek($0) } ?? false)
        }.count
    }

    private var isCatchingUp: Bool {
        let added = addedThisWeek.count
        return added > 4 && masteredThisWeek < added / 2
    }

    // Week date range e.g. "Mar 1 – Mar 7"
    private var weekRangeLabel: String {
        let cal = Calendar.current
        let now = Date()
        guard let start = cal.dateInterval(of: .weekOfYear, for: now)?.start else { return "This week" }
        let end = cal.date(byAdding: .day, value: 6, to: start) ?? now
        let fmt = DateFormatter(); fmt.dateFormat = "MMM d"
        return "\(fmt.string(from: start)) – \(fmt.string(from: end))"
    }

    // The list to show: this week's phrases (or all if week is empty)
    private var displayPhrases: [SavedPhrase] {
        addedThisWeek.isEmpty ? allPhrases : addedThisWeek
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Header ──────────────────────────────────────
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text("My Clipboard")
                            .font(.custom("HelveticaNeue-Bold", size: 18))
                            .foregroundColor(.tsLabel)
                        // Count pill — small, gray
                        Text("\(store.phrases.count)")
                            .font(.custom("HelveticaNeue-Bold", size: 12))
                            .foregroundColor(.tsSecondary)
                            .padding(.horizontal, 8).padding(.vertical, 3)
                            .background(Color(UIColor.systemGray5))
                            .clipShape(Capsule())
                    }
                    Text(weekRangeLabel)
                        .font(.custom("HelveticaNeue", size: 12))
                        .foregroundColor(.tsSecondary)
                }
                Spacer()
                if !store.activePhrases.isEmpty {
                    Button(action: onStudy) {
                        HStack(spacing: 4) {
                            Image(systemName: "graduationcap.fill").font(.system(size: 10))
                            Text("Study").font(.custom("HelveticaNeue-Medium", size: 12))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(Color.tsAccent)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 10)

            Divider().background(Color.tsBorder.opacity(0.5))

            // ── Lined paper word list ────────────────────────
            ZStack(alignment: .topLeading) {
                // Red margin line
                Rectangle()
                    .fill(Color(hex: "#FF6B6B").opacity(0.35))
                    .frame(width: 1.5)
                    .padding(.leading, 36)

                if displayPhrases.isEmpty {
                    HStack {
                        Spacer()
                        VStack(spacing: 6) {
                            Text("📋").font(.system(size: 28))
                            Text("No phrases added yet")
                                .font(.custom("HelveticaNeue", size: 13))
                                .foregroundColor(.tsSecondary)
                            Text("Translate something to get started")
                                .font(.custom("HelveticaNeue", size: 12))
                                .foregroundColor(.tsSecondary.opacity(0.6))
                        }
                        .padding(.vertical, 24)
                        Spacer()
                    }
                } else if displayPhrases.count > Self.scrollThreshold {
                    // Scrollable when > 7 words
                    ScrollView(.vertical, showsIndicators: false) {
                        phraseList(displayPhrases)
                    }
                    .frame(height: CGFloat(Self.scrollThreshold) * 44)
                } else {
                    phraseList(displayPhrases)
                }
            }
            .background(Color(UIColor.systemGray6).opacity(0.45))

            Divider().background(Color.tsBorder.opacity(0.5))

            // ── Footer stats ─────────────────────────────────
            HStack(spacing: 16) {
                ClipStatPill(icon: "arrow.down.circle.fill", color: .tsAccent,
                             value: "\(addedThisWeek.count)", label: "this week")
                ClipStatPill(icon: "checkmark.circle.fill",  color: Color(hex: "#30D158"),
                             value: "\(masteredThisWeek)",   label: "mastered")
                Spacer()
                if isCatchingUp {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.circle.fill").font(.system(size: 11))
                        Text("Catching up…").font(.custom("HelveticaNeue-Medium", size: 12))
                    }
                    .foregroundColor(Color(hex: "#FF9500"))
                }
            }
            .padding(.horizontal, 16).padding(.vertical, 10)
        }
        .background(Color.tsCard)
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))
    }

    @ViewBuilder
    private func phraseList(_ phrases: [SavedPhrase]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(phrases.enumerated()), id: \.offset) { idx, phrase in
                HStack(alignment: .center, spacing: 8) {
                    Text("\(idx + 1).")
                        .font(.custom("HelveticaNeue", size: 12))
                        .foregroundColor(.tsSecondary.opacity(0.45))
                        .frame(width: 24, alignment: .trailing)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(phrase.translatedText)
                            .font(.custom("HelveticaNeue-Medium", size: 14))
                            .foregroundColor(.tsLabel)
                            .lineLimit(1)
                        Text(phrase.sourceText)
                            .font(.custom("HelveticaNeue", size: 11))
                            .foregroundColor(.tsSecondary)
                            .lineLimit(1)
                    }
                    Spacer()
                }
                .frame(height: 44)
                .padding(.horizontal, 12)
                if idx < phrases.count - 1 {
                    Divider()
                        .background(Color.tsBorder.opacity(0.3))
                        .padding(.leading, 44)
                }
            }
        }
    }
}

private struct ClipStatPill: View {
    let icon: String; let color: Color; let value: String; let label: String
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon).font(.system(size: 13)).foregroundColor(color)
            Text(value).font(.custom("HelveticaNeue-Bold", size: 14)).foregroundColor(.tsLabel)
            Text(label).font(.custom("HelveticaNeue", size: 13)).foregroundColor(.tsSecondary)
        }
    }
}

// MARK: - Weekly Streak Card — dark gradient

struct WeeklyStreakCard: View {
    @AppStorage("study_week_id")        private var weekId    = ""
    @AppStorage("study_days_this_week") private var daysStr   = ""
    @AppStorage("completed_weeks")      private var completed = 0

    private static let goal = 5

    private var currentWeekId: String {
        let cal = Calendar.current
        let y = cal.component(.yearForWeekOfYear, from: Date())
        let w = cal.component(.weekOfYear, from: Date())
        return "\(y)-\(w)"
    }

    private var todayWeekday: Int {
        var cal = Calendar.current; cal.firstWeekday = 2
        return cal.component(.weekday, from: Date())
    }

    private var studiedDays: Set<Int> {
        guard weekId == currentWeekId else { return [] }
        return Set(daysStr.split(separator: ",").compactMap { Int($0) })
    }

    private var daysHit: Int       { studiedDays.count }
    private var weekComplete: Bool { daysHit >= Self.goal }

    private let dayLabels  = ["M","T","W","T","F","S","S"]
    private let dayNumbers = [2,3,4,5,6,7,8]

    private let grad = LinearGradient(
        colors: [Color(hex: "#0A1628"), Color(hex: "#0E2C77"), Color(hex: "#1A52C8")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("This Week")
                        .font(.custom("HelveticaNeue-Bold", size: 16))
                        .foregroundColor(.white)
                    Text(weekComplete
                         ? "Week complete 🏆"
                         : "\(daysHit) of \(Self.goal) days — keep going")
                        .font(.custom("HelveticaNeue", size: 12))
                        .foregroundColor(weekComplete ? Color(hex: "#30D158") : Color.white.opacity(0.65))
                }
                Spacer()
                if completed > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill").font(.system(size: 11)).foregroundColor(Color(hex: "#FF9500"))
                        Text("\(completed)w").font(.custom("HelveticaNeue-Bold", size: 12)).foregroundColor(.white)
                    }
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(Color.white.opacity(0.12))
                    .clipShape(Capsule())
                }
            }

            HStack(spacing: 0) {
                ForEach(Array(zip(dayLabels, dayNumbers)), id: \.1) { label, dayNum in
                    let studied = studiedDays.contains(dayNum)
                    let isToday = dayNum == todayWeekday
                    VStack(spacing: 5) {
                        Text(label)
                            .font(.custom("HelveticaNeue-Medium", size: 11))
                            .foregroundColor(Color.white.opacity(0.6))
                        ZStack {
                            Circle()
                                .fill(studied ? Color.tsAccent : Color.white.opacity(0.12))
                                .frame(width: 30, height: 30)
                            if studied {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        Circle()
                            .fill(isToday ? Color.white.opacity(0.8) : Color.clear)
                            .frame(width: 4, height: 4)
                    }
                    .frame(maxWidth: .infinity)
                }
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.15)).frame(height: 5)
                    Capsule()
                        .fill(weekComplete ? Color(hex: "#30D158") : Color.tsAccent)
                        .frame(width: geo.size.width * min(Double(daysHit) / Double(Self.goal), 1.0), height: 5)
                        .animation(.spring(response: 0.4), value: daysHit)
                }
            }
            .frame(height: 5)
        }
        .padding(16)
        .background(grad)
        .cornerRadius(20)
        .onAppear {
#if DEBUG
            if daysStr.isEmpty {
                weekId  = currentWeekId
                daysStr = "2,4,6,7"
            }
#endif
            checkWeekRollover()
        }
    }

    private func checkWeekRollover() {
        let cid = currentWeekId
        guard weekId != cid else { return }
        if daysHit >= Self.goal { completed += 1 }
        weekId = cid; daysStr = ""
    }

    func markToday() {
        checkWeekRollover()
        var days = studiedDays
        days.insert(todayWeekday)
        daysStr = days.map { "\($0)" }.joined(separator: ",")
    }
}
