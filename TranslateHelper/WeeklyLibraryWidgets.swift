//  WeeklyLibraryWidgets.swift
//  Clipboard widget (lined paper, weekly words) + 5/7 streak tracker

import SwiftUI

// MARK: - Helpers

private extension Calendar {
    func isThisWeek(_ date: Date) -> Bool {
        isDate(date, equalTo: Date(), toGranularity: .weekOfYear)
    }
}

// MARK: - Weekly Clipboard Widget

struct WeeklyClipboardWidget: View {
    @ObservedObject var store: SharedPhraseStore
    let onStudy: () -> Void

    private var addedThisWeek: [SavedPhrase] {
        store.phrases.filter { Calendar.current.isThisWeek($0.savedAt) }
            .sorted { $0.savedAt < $1.savedAt }
    }

    private var masteredThisWeek: Int {
        store.phrases.filter {
            $0.isConquered && $0.conqueredAt.map { Calendar.current.isThisWeek($0) } ?? false
        }.count
    }

    private var isCatchingUp: Bool {
        let added = addedThisWeek.count
        let mastered = masteredThisWeek
        return added > 4 && mastered < added / 2
    }

    // Week date range label e.g. "Jul 7 – Jul 13"
    private var weekRangeLabel: String {
        let cal = Calendar.current
        let now = Date()
        guard let weekStart = cal.dateInterval(of: .weekOfYear, for: now)?.start else { return "This week" }
        let weekEnd = cal.date(byAdding: .day, value: 6, to: weekStart) ?? now
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM d"
        return "\(fmt.string(from: weekStart)) – \(fmt.string(from: weekEnd))"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header row
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("My Clipboard")
                        .font(.custom("HelveticaNeue-Bold", size: 18))
                        .foregroundColor(.tsLabel)
                    Text(weekRangeLabel)
                        .font(.custom("HelveticaNeue", size: 12))
                        .foregroundColor(.tsSecondary)
                }
                Spacer()
                // Study button
                if !store.activePhrases.isEmpty {
                    Button(action: onStudy) {
                        HStack(spacing: 4) {
                            Image(systemName: "graduationcap.fill")
                                .font(.system(size: 10))
                            Text("Study")
                                .font(.custom("HelveticaNeue-Medium", size: 12))
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

            // Lined paper body
            HStack(alignment: .top, spacing: 0) {
                // Left margin line (notebook red line)
                Rectangle()
                    .fill(Color(hex: "#FF6B6B").opacity(0.35))
                    .frame(width: 1.5)
                    .padding(.leading, 36)

                // Words list
                VStack(alignment: .leading, spacing: 0) {
                    if addedThisWeek.isEmpty {
                        HStack {
                            Spacer()
                            VStack(spacing: 6) {
                                Text("📋")
                                    .font(.system(size: 28))
                                Text("No phrases added yet this week")
                                    .font(.custom("HelveticaNeue", size: 13))
                                    .foregroundColor(.tsSecondary)
                                    .multilineTextAlignment(.center)
                                Text("Translate something to start your list")
                                    .font(.custom("HelveticaNeue", size: 12))
                                    .foregroundColor(.tsSecondary.opacity(0.6))
                            }
                            .padding(.vertical, 24)
                            Spacer()
                        }
                    } else {
                        ForEach(Array(addedThisWeek.prefix(8).enumerated()), id: \.offset) { idx, phrase in
                            HStack(alignment: .center, spacing: 8) {
                                Text("\(idx + 1).")
                                    .font(.custom("HelveticaNeue", size: 12))
                                    .foregroundColor(.tsSecondary.opacity(0.5))
                                    .frame(width: 20, alignment: .trailing)
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
                            .background(Color.clear)
                            if idx < min(addedThisWeek.count, 8) - 1 {
                                Divider()
                                    .background(Color.tsBorder.opacity(0.35))
                                    .padding(.leading, 40)
                            }
                        }
                        if addedThisWeek.count > 8 {
                            Text("+ \(addedThisWeek.count - 8) more this week")
                                .font(.custom("HelveticaNeue", size: 12))
                                .foregroundColor(.tsSecondary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                        }
                    }
                }
            }
            .background(Color(UIColor.systemBackground).opacity(0.5))

            Divider().background(Color.tsBorder.opacity(0.5))

            // Footer stats
            HStack(spacing: 16) {
                StatPill(
                    icon: "arrow.down.circle.fill",
                    color: .tsAccent,
                    value: "\(addedThisWeek.count)",
                    label: "added"
                )
                StatPill(
                    icon: "checkmark.circle.fill",
                    color: Color(hex: "#30D158"),
                    value: "\(masteredThisWeek)",
                    label: "mastered"
                )
                Spacer()
                if isCatchingUp {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.system(size: 11))
                        Text("Catching up…")
                            .font(.custom("HelveticaNeue-Medium", size: 12))
                    }
                    .foregroundColor(Color(hex: "#FF9500"))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(Color.tsCard)
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))
    }
}

// MARK: - Stat pill (clipboard footer)

private struct StatPill: View {
    let icon: String
    let color: Color
    let value: String
    let label: String
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundColor(color)
            Text(value)
                .font(.custom("HelveticaNeue-Bold", size: 14))
                .foregroundColor(.tsLabel)
            Text(label)
                .font(.custom("HelveticaNeue", size: 13))
                .foregroundColor(.tsSecondary)
        }
    }
}

// MARK: - Weekly Streak Card (5/7)

struct WeeklyStreakCard: View {
    // Stored: "2025-28" → "2,4,5" (weekday indices 2=Mon…8=Sun in ISO)
    @AppStorage("study_week_id")       private var weekId    = ""
    @AppStorage("study_days_this_week") private var daysStr  = ""
    @AppStorage("completed_weeks")     private var completed = 0

    private static let goal = 5

    private var currentWeekId: String {
        let cal = Calendar.current
        let year = cal.component(.yearForWeekOfYear, from: Date())
        let week = cal.component(.weekOfYear, from: Date())
        return "\(year)-\(week)"
    }

    // Weekday of today (2=Mon … 8=Sun in ISO week)
    private var todayWeekday: Int {
        var cal = Calendar.current
        cal.firstWeekday = 2 // Monday start
        return cal.component(.weekday, from: Date())
    }

    private var studiedDays: Set<Int> {
        guard weekId == currentWeekId else { return [] }
        return Set(daysStr.split(separator: ",").compactMap { Int($0) })
    }

    private var daysHit: Int { studiedDays.count }
    private var weekComplete: Bool { daysHit >= Self.goal }

    // Days of the week Mon–Sun
    private let dayLabels = ["M","T","W","T","F","S","S"]
    // ISO weekday numbers Mon=2, Tue=3, Wed=4, Thu=5, Fri=6, Sat=7, Sun=1→8
    private let dayNumbers = [2,3,4,5,6,7,8]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("This week")
                        .font(.custom("HelveticaNeue-Bold", size: 15))
                        .foregroundColor(.tsLabel)
                    Text(weekComplete
                         ? "Week complete 🏆"
                         : "\(daysHit) of \(Self.goal) days — keep going")
                        .font(.custom("HelveticaNeue", size: 12))
                        .foregroundColor(weekComplete ? Color(hex: "#30D158") : .tsSecondary)
                }
                Spacer()
                if completed > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 11))
                            .foregroundColor(Color(hex: "#FF9500"))
                        Text("\(completed)w")
                            .font(.custom("HelveticaNeue-Bold", size: 12))
                            .foregroundColor(.tsLabel)
                    }
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(Color(hex: "#FF9500").opacity(0.12))
                    .clipShape(Capsule())
                }
            }

            // Day dots Mon–Sun
            HStack(spacing: 0) {
                ForEach(Array(zip(dayLabels, dayNumbers)), id: \.1) { label, dayNum in
                    VStack(spacing: 5) {
                        Text(label)
                            .font(.custom("HelveticaNeue-Medium", size: 11))
                            .foregroundColor(.tsSecondary)
                        ZStack {
                            Circle()
                                .fill(studiedDays.contains(dayNum)
                                      ? Color.tsAccent
                                      : Color.tsInputBg)
                                .frame(width: 28, height: 28)
                            if studiedDays.contains(dayNum) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        // Today marker
                        Circle()
                            .fill(dayNum == todayWeekday ? Color.tsAccent : Color.clear)
                            .frame(width: 4, height: 4)
                    }
                    .frame(maxWidth: .infinity)
                }
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.tsInputBg).frame(height: 4)
                    Capsule()
                        .fill(weekComplete ? Color(hex: "#30D158") : Color.tsAccent)
                        .frame(width: geo.size.width * min(Double(daysHit) / Double(Self.goal), 1.0), height: 4)
                        .animation(.spring(response: 0.4), value: daysHit)
                }
            }
            .frame(height: 4)
        }
        .padding(16)
        .background(Color.tsCard)
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))
    }

    // Call this whenever the user completes a study session
    func markToday() {
        let cid = currentWeekId
        if weekId != cid {
            // New week — reset
            if daysHit >= Self.goal { completed += 1 }
            weekId  = cid
            daysStr = ""
        }
        var days = studiedDays
        days.insert(todayWeekday)
        daysStr = days.map { "\($0)" }.joined(separator: ",")
    }
}
