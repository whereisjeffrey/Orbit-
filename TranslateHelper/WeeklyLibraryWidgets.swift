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
    @Environment(\.colorScheme) var colorScheme

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
                        HStack(spacing: 5) {
                            Image(systemName: "graduationcap.fill").font(.system(size: 13))
                            Text("Study").font(.custom("HelveticaNeue-Medium", size: 15))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16).padding(.vertical, 9)
                        .background(Color.tsAccent)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 10)
            .background(colorScheme == .dark ? Color.tsInputBg : Color(hex: "#F2F8FA"))


            // ── Lined paper word list ────────────────────────
            ZStack(alignment: .topLeading) {
                // Red margin line
                Rectangle()
                    .fill(Color(hex: "#FF6B6B").opacity(colorScheme == .dark ? 0.6 : 0.35))
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
            .background(colorScheme == .dark ? Color.black : Color.white)

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
            .background(colorScheme == .dark ? Color.tsInputBg : Color(hex: "#F2F8FA"))
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

    // Inspiration mesh background matching the vibrant gradient
    @ViewBuilder private var inspirationBackground: some View {
        ZStack {
            Color(hex: "#8B309A") // deep purple-ish mid base
            
            // Top Left — Rich Magenta
            RadialGradient(gradient: Gradient(colors: [Color(hex: "#EE2A69"), Color.clear]),
                           center: .topLeading, startRadius: 0, endRadius: 250)
            
            // Top Right — Deep Indigo Blue
            RadialGradient(gradient: Gradient(colors: [Color(hex: "#25246D"), Color.clear]),
                           center: .topTrailing, startRadius: 0, endRadius: 250)
            
            // Bottom Right — Vibrant Cyan
            RadialGradient(gradient: Gradient(colors: [Color(hex: "#14A9CD"), Color.clear]),
                           center: .bottomTrailing, startRadius: 0, endRadius: 220)
                           
            // Mid Right — Deep Blue (to bridge indigo and cyan)
            RadialGradient(gradient: Gradient(colors: [Color(hex: "#1C6CB1"), Color.clear]),
                           center: UnitPoint(x: 1.0, y: 0.6), startRadius: 0, endRadius: 200)
            
            // Bottom Center — Faded Teal/Yellow-Green
            RadialGradient(gradient: Gradient(colors: [Color(hex: "#8FBEA6"), Color.clear]),
                           center: UnitPoint(x: 0.5, y: 1.0), startRadius: 0, endRadius: 180)
            
            // Bottom Left — Peach / Yellow-Orange
            RadialGradient(gradient: Gradient(colors: [Color(hex: "#FFA032"), Color.clear]),
                           center: .bottomLeading, startRadius: 0, endRadius: 220)
            
            // Mid Left — Coral/Orange-Pink mixing into Magenta
            RadialGradient(gradient: Gradient(colors: [Color(hex: "#F56251"), Color.clear]),
                           center: UnitPoint(x: 0.0, y: 0.65), startRadius: 0, endRadius: 200)
            
            // Center subtle warmth
            RadialGradient(gradient: Gradient(colors: [Color(hex: "#C5788E").opacity(0.4), Color.clear]),
                           center: UnitPoint(x: 0.4, y: 0.5), startRadius: 0, endRadius: 160)
        }
    }

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

            HStack(spacing: 8) {
                ForEach(1...7, id: \.self) { day in
                    let dayNum = day + 1  // day1=Mon(2)...day7=Sun(8)
                    let studied = studiedDays.contains(dayNum)
                    VStack(spacing: 2) {
                        Text("Day")
                            .font(.custom("HelveticaNeue-Medium", size: 10))
                            .foregroundColor(studied ? Color(hex: "#0079C6") : Color.white.opacity(0.5))
                        Text("\(day)")
                            .font(.custom("HelveticaNeue-Bold", size: 14))
                            .foregroundColor(studied ? Color(hex: "#0079C6") : Color.white.opacity(0.5))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 7)
                    .background(studied ? Color.white : Color.white.opacity(0.2))
                    .cornerRadius(12)
                }
            }


        }
        .padding(16)
        .background(inspirationBackground)
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


// MARK: - Swipe Deck Hint

struct SwipeDeckHint: View {
    var body: some View {
        HStack(spacing: 10) {
            Text("\u{1F4CB}")
                .font(.system(size: 15))
            Text("See more, swipe right on your clipboard to view your starter decks")
                .font(.custom("HelveticaNeue-Medium", size: 13))
                .foregroundColor(Color(hex: "#0079C6"))
                .lineLimit(nil)
            Spacer()
            Image(systemName: "arrow.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color(hex: "#0079C6"))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color(hex: "#E8F4FF"))
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10)
            .stroke(Color(hex: "#0079C6").opacity(0.3), lineWidth: 1))
    }
}

// MARK: - Deck Clipboard Widget

struct DeckClipboardWidget: View {
    let deck: Deck
    let onStudy: () -> Void
    @Environment(\.colorScheme) var colorScheme

    private static let scrollThreshold = 7

    private var displayCards: [DeckCard] { deck.cards }
    private var masteredCount: Int { deck.cards.filter { $0.isConquered }.count }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Header ──────────────────────────────────────
            HStack(alignment: .center) {
                Text(deck.name)
                    .font(.custom("HelveticaNeue-Bold", size: 18))
                    .foregroundColor(.tsLabel)
                Spacer()
                if !deck.cards.isEmpty {
                    Button(action: onStudy) {
                        HStack(spacing: 5) {
                            Image(systemName: "graduationcap.fill").font(.system(size: 13))
                            Text("Study").font(.custom("HelveticaNeue-Medium", size: 15))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16).padding(.vertical, 9)
                        .background(Color.tsAccent)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 10)
            .background(colorScheme == .dark ? Color.tsInputBg : Color(hex: "#F2F8FA"))

            // ── Lined paper word list ──────────────────────
            ZStack(alignment: .topLeading) {
                Rectangle()
                    .fill(Color(hex: "#FF6B6B").opacity(colorScheme == .dark ? 0.6 : 0.35))
                    .frame(width: 1.5)
                    .padding(.leading, 36)

                if displayCards.isEmpty {
                    HStack {
                        Spacer()
                        VStack(spacing: 6) {
                            Text("\u{1F4DA}").font(.system(size: 28))
                            Text("No cards in this deck")
                                .font(.custom("HelveticaNeue", size: 13))
                                .foregroundColor(.tsSecondary)
                        }
                        .padding(.vertical, 24)
                        Spacer()
                    }
                } else if displayCards.count > Self.scrollThreshold {
                    ScrollView(.vertical, showsIndicators: false) {
                        cardList(displayCards)
                    }
                    .frame(height: CGFloat(Self.scrollThreshold) * 44)
                } else {
                    cardList(displayCards)
                }
            }
            .background(colorScheme == .dark ? Color.black : Color.white)

            // ── Footer stats ──────────────────────────────
            HStack(spacing: 16) {
                ClipStatPill(icon: "arrow.down.circle.fill", color: .tsAccent,
                             value: "\(deck.cards.count)", label: "downloaded")
                ClipStatPill(icon: "checkmark.circle.fill", color: Color(hex: "#30D158"),
                             value: "\(masteredCount)", label: "mastered")
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill").font(.system(size: 11))
                    Text("Catching up\u{2026}").font(.custom("HelveticaNeue-Medium", size: 12))
                }
                .foregroundColor(Color(hex: "#FF9500"))
            }
            .padding(.horizontal, 16).padding(.vertical, 10)
            .background(colorScheme == .dark ? Color.tsInputBg : Color(hex: "#F2F8FA"))
        }
        .background(Color.tsCard)
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.tsAccent.opacity(0.08), lineWidth: 0.5))
    }

    @ViewBuilder
    private func cardList(_ cards: [DeckCard]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(cards.enumerated()), id: \.offset) { idx, card in
                HStack(alignment: .center, spacing: 8) {
                    Text("\(idx + 1).")
                        .font(.custom("HelveticaNeue", size: 12))
                        .foregroundColor(.tsSecondary.opacity(0.45))
                        .frame(width: 24, alignment: .trailing)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(card.spanish)
                            .font(.custom("HelveticaNeue-Medium", size: 14))
                            .foregroundColor(.tsLabel)
                            .lineLimit(1)
                        Text(card.english)
                            .font(.custom("HelveticaNeue", size: 11))
                            .foregroundColor(.tsSecondary)
                            .lineLimit(1)
                    }
                    Spacer()
                    if card.isConquered {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color(hex: "#30D158"))
                            .font(.system(size: 14))
                    }
                }
                .frame(height: 44)
                .padding(.horizontal, 12)
                if idx < cards.count - 1 {
                    Divider()
                        .background(Color.tsBorder.opacity(0.3))
                        .padding(.leading, 44)
                }
            }
        }
    }
}




import UIKit

// MARK: - DeckPagerContainer
// UIPageViewController handles the horizontal slide + gesture conflict resolution.
// KVO on its internal UIScrollView drives the throw animation in real-time,
// so rotation fires consistently regardless of where on the card you touch.

struct DeckPagerContainer: UIViewControllerRepresentable {
    let pages: [AnyView]
    @Binding var currentPage: Int

    func makeUIViewController(context: Context) -> UIPageViewController {
        let vc = UIPageViewController(transitionStyle: .scroll,
                                      navigationOrientation: .horizontal)
        vc.view.backgroundColor = .clear
        vc.dataSource = context.coordinator
        vc.delegate   = context.coordinator
        let initial = context.coordinator.hostingVC(for: 0)
        vc.setViewControllers([initial], direction: .forward, animated: false)
        // Hook into internal scroll view after layout
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            context.coordinator.attachScrollObserver(to: vc)
        }
        return vc
    }

    func updateUIViewController(_ pageVC: UIPageViewController, context: Context) {
        context.coordinator.parent = self
        guard context.coordinator.currentIndex != currentPage else { return }
        let goForward = currentPage > context.coordinator.currentIndex
        let dest = context.coordinator.hostingVC(for: currentPage)
        pageVC.setViewControllers([dest],
                                  direction: goForward ? .reverse : .forward,
                                  animated: true)
        context.coordinator.currentIndex = currentPage
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    // ── Coordinator ──────────────────────────────────────────────────────────
    class Coordinator: NSObject,
                       UIPageViewControllerDataSource,
                       UIPageViewControllerDelegate {

        var parent: DeckPagerContainer
        var currentIndex: Int = 0
        private var cache: [Int: UIHostingController<AnyView>] = [:]
        private var scrollObservation: NSKeyValueObservation?

        init(_ p: DeckPagerContainer) { parent = p }

        // ── Page caching ─────────────────────────────────────────────────────
        func hostingVC(for index: Int) -> UIHostingController<AnyView> {
            guard index < parent.pages.count else {
                return UIHostingController(rootView: AnyView(EmptyView()))
            }
            if let existing = cache[index] {
                existing.rootView = parent.pages[index]
                return existing
            }
            let vc = UIHostingController(rootView: parent.pages[index])
            vc.view.backgroundColor = .clear
            vc.view.isOpaque = false
            cache[index] = vc
            return vc
        }

        private func index(of vc: UIViewController) -> Int? {
            cache.first(where: { $0.value === vc })?.key
        }

        // ── KVO: track UIPageViewController's internal scroll view ───────────
        func attachScrollObserver(to pageVC: UIPageViewController) {
            guard let sv = pageVC.view.subviews.compactMap({ $0 as? UIScrollView }).first else { return }
            scrollObservation = sv.observe(\.contentOffset, options: [.new]) { [weak self] scrollView, _ in
                self?.syncThrowAnimation(scrollView)
            }
        }

        private func syncThrowAnimation(_ sv: UIScrollView) {
            let w = sv.bounds.width
            guard w > 0 else { return }
            // UIPageViewController keeps current page at offset = w (middle of 3 slots)
            let progress = (sv.contentOffset.x - w) / w   // -1…+1  (negative = swipe right/forward)
            guard abs(progress) > 0.005 else {
                cache[currentIndex]?.view.layer.transform = CATransform3DIdentity
                return
            }
            guard let outgoing = cache[currentIndex]?.view else { return }
            // Forward swipe (progress < 0): rotate clockwise, float up
            // Backward swipe (progress > 0): rotate counter-clockwise, float up
            let angle    = CGFloat(-progress) * 0.18      // radians (~10°)
            let floatUp  = abs(progress) * 55              // max 55pt upward
            let rot      = CATransform3DMakeRotation(angle, 0, 0, 1)
            let combined = CATransform3DTranslate(rot, 0, -floatUp, 0)
            outgoing.layer.transform = combined
        }

        // ── Direction: swipe RIGHT = next (viewControllerBefore = idx+1) ─────
        func pageViewController(_ pvc: UIPageViewController,
                                viewControllerBefore vc: UIViewController) -> UIViewController? {
            guard let idx = index(of: vc), idx < parent.pages.count - 1 else { return nil }
            return hostingVC(for: idx + 1)
        }

        func pageViewController(_ pvc: UIPageViewController,
                                viewControllerAfter vc: UIViewController) -> UIViewController? {
            guard let idx = index(of: vc), idx > 0 else { return nil }
            return hostingVC(for: idx - 1)
        }

        // ── Incoming card: spring pop-in via willTransitionTo ─────────────────
        func pageViewController(_ pvc: UIPageViewController,
                                willTransitionTo pending: [UIViewController]) {
            guard let incomingView = pending.first?.view else { return }
            let scaleIn = CASpringAnimation(keyPath: "transform.scale")
            scaleIn.fromValue       = 0.88
            scaleIn.toValue         = 1.0
            scaleIn.stiffness       = 280
            scaleIn.damping         = 22
            scaleIn.initialVelocity = 4
            scaleIn.duration        = scaleIn.settlingDuration
            incomingView.layer.add(scaleIn, forKey: "ts_pop_in")
        }

        // ── Cleanup ───────────────────────────────────────────────────────────
        func pageViewController(_ pvc: UIPageViewController,
                                didFinishAnimating finished: Bool,
                                previousViewControllers: [UIViewController],
                                transitionCompleted completed: Bool) {
            previousViewControllers.forEach {
                $0.view.layer.removeAllAnimations()
                $0.view.layer.transform = CATransform3DIdentity
            }
            guard completed,
                  let current = pvc.viewControllers?.first,
                  let idx = index(of: current) else { return }
            currentIndex = idx
            DispatchQueue.main.async { self.parent.currentPage = idx }
        }
    }
}

// MARK: - Botanical Card Background

struct BotanicalCardBackground: View {
    var body: some View {
        ZStack {
            Image("DailyGoalBackground")
                .resizable()
                .scaledToFill()
            // Dark veil so white text stays legible over the bright flowers
            Color.black.opacity(0.32)
        }
        .clipped()
    }
}
