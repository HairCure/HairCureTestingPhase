//////import SwiftUI
//////
//////// ── Shared card height — change once to resize both hero cards together ───────
//////private let heroCardHeight: CGFloat = 218
//////
//////struct HomeView: View {
//////    @Binding var selectedTab: Int
//////
//////    @Environment(AppDataStore.self) private var store
//////    @State private var showCoach       = false
//////    @State private var heroPage        = 0
//////    @State private var showPlanDetails = false
//////    @State private var showHydration   = false
//////    @State private var pushMealId: UUID? = nil
//////    @State private var expandedMeals: Set<MealType> = []
//////
//////    private var report:    ScanReport?           { store.latestScanReport }
//////    private var plan:      UserPlan?             { store.activePlan }
//////    private var nutrition: UserNutritionProfile? { store.activeNutritionProfile }
//////
//////    var body: some View {
//////        NavigationStack {
//////            ZStack {
//////                Color.hcCream.ignoresSafeArea()
//////
//////                ScrollView(showsIndicators: false) {
//////                    VStack(alignment: .leading, spacing: 20) {
//////                        heroCardsSection
//////                        featureCardsSection
//////                        Color.clear.frame(height: 20)
//////                    }
//////                    .padding(.horizontal, 20)
//////                    .padding(.top, 16)
//////                }
//////            }
//////            .navigationTitle("Home")
//////            .navigationBarTitleDisplayMode(.large)
//////            .navigationDestination(item: $pushMealId) { mealId in
//////                AddMealView(mealEntryId: mealId)
//////            }
//////        }
//////        .sheet(isPresented: $showPlanDetails) {
//////            PlanResultsView(onStart: { showPlanDetails = false })
//////                .environment(store)
//////        }
//////        .sheet(isPresented: $showHydration) {
//////            HydrationTrackerView()
//////                .environment(store)
//////        }
//////        .sheet(isPresented: $showCoach) {
//////            CoachView(viewModel: CoachViewModel())
//////        }
//////    }
//////
//////    // MARK: - Hero Swipe Cards
//////
//////    private var heroCardsSection: some View {
//////        VStack(spacing: 10) {
//////            TabView(selection: $heroPage) {
//////                aiCoachCard
//////                    .padding(.horizontal, 4)
//////                    .tag(0)
//////
//////                hairHealthCard
//////                    .padding(.horizontal, 4)
//////                    .tag(1)
//////            }
//////            .tabViewStyle(.page(indexDisplayMode: .never))
//////            .frame(height: heroCardHeight)
//////            // ▼ Kills the default black TabView page-style background entirely
//////            .background(Color.hcCream)
//////
//////            // Page dots
//////            HStack(spacing: 8) {
//////                ForEach(0..<2, id: \.self) { i in
//////                    Circle()
//////                        .fill(heroPage == i ? Color.hcBrown : Color(.systemGray4))
//////                        .frame(width: heroPage == i ? 10 : 7,
//////                               height: heroPage == i ? 10 : 7)
//////                        .animation(.easeInOut(duration: 0.2), value: heroPage)
//////                }
//////            }
//////        }
//////    }
//////
//////    // MARK: - Card A — Hair Health
//////
//////    private var hairHealthCard: some View {
//////        let density  = report?.hairDensityPercent ?? 52
//////        let stage    = report?.hairFallStage.intValue ?? plan?.stage ?? 2
//////        let progress = min(CGFloat(density) / 100.0, 1.0)
//////
//////        let (severityLabel, severityColor): (String, Color) = {
//////            switch stage {
//////            case 1: return ("Healthy",  Color(red: 0.22, green: 0.78, blue: 0.45))
//////            case 2: return ("Moderate", Color(red: 1.00, green: 0.60, blue: 0.15))
//////            case 3: return ("Severe",   Color(red: 0.95, green: 0.32, blue: 0.22))
//////            default: return ("Critical", Color(red: 0.85, green: 0.15, blue: 0.15))
//////            }
//////        }()
//////
//////        let ringColor: Color = {
//////            switch stage {
//////            case 1: return Color(red: 0.22, green: 0.88, blue: 0.52)
//////            case 2: return Color(red: 1.00, green: 0.62, blue: 0.18)
//////            case 3: return Color(red: 0.95, green: 0.38, blue: 0.22)
//////            default: return Color(red: 0.85, green: 0.20, blue: 0.20)
//////            }
//////        }()
//////
//////        let scanSubtitle: String = report != nil ? "Last scan available" : "No scan yet — tap to scan"
//////
//////        return VStack(spacing: 0) {
//////
//////            // ── Gradient hero section ─────────────────────────────────────
//////            ZStack(alignment: .topLeading) {
//////
//////                LinearGradient(
//////                    stops: [
//////                        .init(color: Color(red: 0.38, green: 0.14, blue: 0.07), location: 0.0),
//////                        .init(color: Color(red: 0.22, green: 0.08, blue: 0.04), location: 0.55),
//////                        .init(color: Color(red: 0.12, green: 0.05, blue: 0.03), location: 1.0),
//////                    ],
//////                    startPoint: .topLeading,
//////                    endPoint: .bottomTrailing
//////                )
//////
//////                RadialGradient(
//////                    colors: [ringColor.opacity(0.18), .clear],
//////                    center: .init(x: 0.22, y: 0.55),
//////                    startRadius: 10,
//////                    endRadius: 110
//////                )
//////
//////                HStack(alignment: .center, spacing: 20) {
//////
//////                    // Density ring
//////                    ZStack {
//////                        Circle()
//////                            .stroke(Color.white.opacity(0.10), lineWidth: 11)
//////                            .frame(width: 96, height: 96)
//////
//////                        Circle()
//////                            .trim(from: 0, to: progress)
//////                            .stroke(
//////                                AngularGradient(
//////                                    colors: [ringColor.opacity(0.6), ringColor, ringColor.opacity(0.85)],
//////                                    center: .center,
//////                                    startAngle: .degrees(-90),
//////                                    endAngle:   .degrees(270)
//////                                ),
//////                                style: StrokeStyle(lineWidth: 11, lineCap: .round)
//////                            )
//////                            .rotationEffect(.degrees(-90))
//////                            .frame(width: 96, height: 96)
//////                            .animation(.easeOut(duration: 0.9), value: progress)
//////
//////                        VStack(spacing: 1) {
//////                            Text("\(Int(density))%")
//////                                .font(.system(size: 22, weight: .bold, design: .rounded))
//////                                .foregroundColor(.white)
//////                            Text("DENSITY")
//////                                .font(.system(size: 8, weight: .semibold))
//////                                .foregroundColor(.white.opacity(0.55))
//////                                .kerning(1.2)
//////                        }
//////                    }
//////
//////                    // Right text column
//////                    VStack(alignment: .leading, spacing: 10) {
//////
//////                        HStack(spacing: 7) {
//////                            Text("Stage \(stage)")
//////                                .font(.system(size: 12, weight: .semibold))
//////                                .foregroundColor(.white)
//////                                .padding(.horizontal, 10)
//////                                .padding(.vertical, 4)
//////                                .background(.white.opacity(0.18), in: Capsule())
//////                                .overlay(Capsule().stroke(.white.opacity(0.25), lineWidth: 0.5))
//////
//////                            Text(severityLabel)
//////                                .font(.system(size: 12, weight: .semibold))
//////                                .foregroundColor(severityColor)
//////                                .padding(.horizontal, 10)
//////                                .padding(.vertical, 4)
//////                                .background(severityColor.opacity(0.18), in: Capsule())
//////                                .overlay(Capsule().stroke(severityColor.opacity(0.35), lineWidth: 0.5))
//////                        }
//////
//////                        Text("Hair Health Score")
//////                            .font(.system(size: 20, weight: .bold))
//////                            .foregroundColor(.white)
//////                            .lineLimit(1)
//////                            .minimumScaleFactor(0.85)
//////
//////                        Text(scanSubtitle)
//////                            .font(.system(size: 13))
//////                            .foregroundColor(.white.opacity(0.50))
//////                    }
//////
//////                    Spacer(minLength: 0)
//////                }
//////                .padding(.horizontal, 18)
//////                .padding(.vertical, 22)
//////            }
//////            .frame(height: heroCardHeight - 50)
//////            .clipShape(UnevenRoundedRectangle(
//////                topLeadingRadius: 18, bottomLeadingRadius: 0,
//////                bottomTrailingRadius: 0, topTrailingRadius: 18
//////            ))
//////
//////            // ── "View Hair Progress" native row ──────────────────────────
//////            Button { showPlanDetails = true } label: {
//////                HStack(spacing: 13) {
//////                    Image(systemName: "waveform.path.ecg")
//////                        .font(.system(size: 18, weight: .medium))
//////                        .foregroundColor(Color(red: 0.28, green: 0.14, blue: 0.08))
//////                        .frame(width: 26)
//////
//////                    Text("View Hair Progress")
//////                        .font(.system(size: 16, weight: .semibold))
//////                        .foregroundColor(.primary)
//////
//////                    Spacer()
//////
//////                    ZStack {
//////                        Circle()
//////                            .fill(Color(red: 0.18, green: 0.08, blue: 0.05))
//////                            .frame(width: 32, height: 32)
//////                        Image(systemName: "arrow.right")
//////                            .font(.system(size: 13, weight: .bold))
//////                            .foregroundColor(.white)
//////                    }
//////                }
//////                .padding(.horizontal, 18)
//////                .frame(height: 50)
//////                .contentShape(Rectangle())
//////            }
//////            .buttonStyle(.plain)
//////            .background(Color.white)
//////            .clipShape(UnevenRoundedRectangle(
//////                topLeadingRadius: 0, bottomLeadingRadius: 18,
//////                bottomTrailingRadius: 18, topTrailingRadius: 0
//////            ))
//////        }
//////        .frame(height: heroCardHeight)
//////        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
//////        .shadow(color: Color(red: 0.22, green: 0.08, blue: 0.04).opacity(0.18), radius: 12, x: 0, y: 4)
//////    }
//////
//////    // MARK: - Card B — AI Coach
//////
//////    private var aiCoachCard: some View {
//////        ZStack(alignment: .bottomLeading) {
//////
//////            // Background gradient — dark slate
//////            LinearGradient(
//////                stops: [
//////                    .init(color: Color(red: 0.10, green: 0.10, blue: 0.14), location: 0.0),
//////                    .init(color: Color(red: 0.14, green: 0.10, blue: 0.18), location: 1.0),
//////                ],
//////                startPoint: .topLeading,
//////                endPoint: .bottomTrailing
//////            )
//////
//////            // Ambient glow — lavender
//////            RadialGradient(
//////                colors: [Color(red: 0.52, green: 0.38, blue: 0.85).opacity(0.28), .clear],
//////                center: .init(x: 0.75, y: 0.25),
//////                startRadius: 10,
//////                endRadius: 160
//////            )
//////
//////            // Ambient glow — app brown echo
//////            RadialGradient(
//////                colors: [Color(red: 0.70, green: 0.32, blue: 0.12).opacity(0.20), .clear],
//////                center: .init(x: 0.15, y: 0.80),
//////                startRadius: 5,
//////                endRadius: 120
//////            )
//////
//////            HStack(alignment: .center, spacing: 0) {
//////
//////                // Left text column
//////                VStack(alignment: .leading, spacing: 10) {
//////                    Spacer(minLength: 0)
//////
//////                    HStack(spacing: 5) {
//////                        Circle()
//////                            .fill(Color(red: 0.45, green: 0.92, blue: 0.58))
//////                            .frame(width: 6, height: 6)
//////                        Text("AI POWERED")
//////                            .font(.system(size: 10, weight: .bold))
//////                            .foregroundColor(Color(red: 0.45, green: 0.92, blue: 0.58))
//////                            .kerning(1.3)
//////                    }
//////
//////                    VStack(alignment: .leading, spacing: 4) {
//////                        Text("Hair Coach")
//////                            .font(.system(size: 22, weight: .bold))
//////                            .foregroundColor(.white)
//////                        Text("Personalised answers,\nanytime you need.")
//////                            .font(.system(size: 13))
//////                            .foregroundColor(.white.opacity(0.50))
//////                            .lineSpacing(3)
//////                    }
//////
//////                    Spacer(minLength: 0)
//////
//////                    Button { showCoach = true } label: {
//////                        HStack(spacing: 7) {
//////                            Text("Start Session")
//////                                .font(.system(size: 14, weight: .semibold))
//////                            Image(systemName: "arrow.right")
//////                                .font(.system(size: 12, weight: .bold))
//////                        }
//////                        .foregroundColor(Color(red: 0.12, green: 0.08, blue: 0.16))
//////                        .padding(.horizontal, 18)
//////                        .padding(.vertical, 10)
//////                        .background(.white, in: Capsule())
//////                    }
//////                    .buttonStyle(.plain)
//////
//////                    Spacer(minLength: 0)
//////                }
//////                .padding(.leading, 20)
//////                .padding(.vertical, 20)
//////
//////                Spacer()
//////
//////                // Right icon with glow rings
//////                ZStack {
//////                    
//////                    Circle()
//////                        .stroke(Color(red: 0.52, green: 0.38, blue: 0.85).opacity(0.15), lineWidth: 1)
//////                        .frame(width: 100, height: 100)
//////                    Circle()
//////                        .stroke(Color(red: 0.52, green: 0.38, blue: 0.85).opacity(0.22), lineWidth: 1)
//////                        .frame(width: 76, height: 76)
//////                    
//////                        .padding()
//////                    ZStack {
//////                        Circle()
//////                            .fill(
//////                                LinearGradient(
//////                                    colors: [
//////                                        Color(red: 0.42, green: 0.28, blue: 0.72),
//////                                        Color(red: 0.28, green: 0.18, blue: 0.52),
//////                                    ],
//////                                    startPoint: .topLeading,
//////                                    endPoint: .bottomTrailing
//////                                )
//////                            )
//////                            .frame(width: 58, height: 58)
//////                        Image(systemName: "brain.head.profile")
//////                            .font(.system(size: 24, weight: .medium))
//////                            .foregroundColor(.white)
//////                    }
//////                }
//////                .padding(.trailing, 22)
//////            }
//////        }
//////        .frame(height: heroCardHeight)
//////        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
//////        // ▼ Shadow uses a warm-neutral tone — no dark bleed onto hcCream background
//////        .shadow(color: Color(red: 0.08, green: 0.06, blue: 0.12).opacity(0.18), radius: 12, x: 0, y: 4)
//////    }
//////
//////    // MARK: - Feature Cards
//////
//////    private var featureCardsSection: some View {
//////        VStack(spacing: 20) {
//////            todaySection
//////            logMealsSection
//////            waterCardCompact
//////            dailyTipCard
//////        }
//////    }
//////
//////    // MARK: - Today (fitness rings)
//////
//////    private var todaySection: some View {
//////        VStack(alignment: .leading, spacing: 12) {
//////            Text("Today")
//////                .font(.system(size: 22, weight: .bold))
//////                .padding(.bottom, 2)
//////
//////            HStack(alignment: .top, spacing: 12) {
//////                NavigationLink(destination: CaloriesDetailView().environment(store)) {
//////                    fitnessCard(
//////                        title: "Calories", icon: "flame.fill", iconColor: .orange,
//////                        gradientColors: [Color(red: 0.13, green: 0.09, blue: 0.07),
//////                                         Color(red: 0.22, green: 0.10, blue: 0.04)],
//////                        current: Double(store.todaysTotalCalories()),
//////                        target:  Double(store.activeNutritionProfile?.tdee ?? 1500),
//////                        ringColor: .orange, unitSuffix: "kcal"
//////                    )
//////                }
//////                .buttonStyle(.plain)
//////
//////                NavigationLink(destination: MindfulDetailView().environment(store)) {
//////                    fitnessCard(
//////                        title: "MindEase", icon: "figure.mind.and.body",
//////                        iconColor: Color(red: 0.65, green: 0.55, blue: 1.0),
//////                        gradientColors: [Color(red: 0.18, green: 0.12, blue: 0.38),
//////                                         Color(red: 0.28, green: 0.18, blue: 0.55)],
//////                        current: Double(store.todaysMindfulMinutes()),
//////                        target:  Double(max(store.dailyMindfulTarget, 20)),
//////                        ringColor: Color(red: 0.40, green: 0.30, blue: 0.85),
//////                        unitSuffix: "min"
//////                    )
//////                }
//////                .buttonStyle(.plain)
//////            }
//////        }
//////    }
//////
//////    private func fitnessCard(
//////        title: String, icon: String, iconColor: Color,
//////        gradientColors: [Color], current: Double, target: Double,
//////        ringColor: Color, unitSuffix: String
//////    ) -> some View {
//////        let progress = min(current / max(target, 1), 1.0)
//////        let pct      = Int(progress * 100)
//////        return VStack(alignment: .leading, spacing: 0) {
//////            HStack {
//////                Image(systemName: icon)
//////                    .font(.system(size: 14, weight: .bold))
//////                    .foregroundColor(iconColor)
//////                Text(title)
//////                    .font(.system(size: 13, weight: .bold))
//////                    .foregroundColor(.white.opacity(0.75))
//////                Spacer()
//////            }
//////            .padding(.bottom, 14)
//////
//////            ZStack {
//////                Circle()
//////                    .stroke(ringColor.opacity(0.18), lineWidth: 10)
//////                Circle()
//////                    .trim(from: 0, to: CGFloat(progress))
//////                    .stroke(ringColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
//////                    .rotationEffect(.degrees(-90))
//////                    .animation(.easeOut(duration: 0.7), value: progress)
//////                VStack(spacing: 1) {
//////                    Text("\(pct)%")
//////                        .font(.system(size: 18, weight: .bold))
//////                        .foregroundColor(.white)
//////                    Text("of goal")
//////                        .font(.system(size: 9, weight: .medium))
//////                        .foregroundColor(.white.opacity(0.55))
//////                }
//////            }
//////            .frame(width: 72, height: 72)
//////            .frame(maxWidth: .infinity)
//////            .padding(.bottom, 14)
//////
//////            VStack(alignment: .leading, spacing: 2) {
//////                Text(current < 1000
//////                     ? "\(Int(current)) \(unitSuffix)"
//////                     : String(format: "%.0f \(unitSuffix)", current))
//////                    .font(.system(size: 16, weight: .bold))
//////                    .foregroundColor(.white)
//////                Text("Goal \(Int(target)) \(unitSuffix)")
//////                    .font(.system(size: 11))
//////                    .foregroundColor(.white.opacity(0.5))
//////            }
//////        }
//////        .padding(14)
//////        .frame(maxWidth: .infinity, maxHeight: .infinity)
//////        .background(
//////            LinearGradient(colors: gradientColors,
//////                           startPoint: .topLeading, endPoint: .bottomTrailing)
//////        )
//////        .cornerRadius(18)
//////    }
//////
//////    // MARK: - Log Meals — Apple Health "Today's Log" style
//////
//////    private var logMealsSection: some View {
//////        VStack(alignment: .leading, spacing: 0) {
//////
//////            Text("Today's Log")
//////                .font(.system(size: 20, weight: .bold))
//////                .padding(.horizontal, 16)
//////                .padding(.top, 16)
//////                .padding(.bottom, 12)
//////
//////            Divider().padding(.horizontal, 16)
//////
//////            let entries = store.todaysMealEntries()
//////                .sorted { $0.mealType.displayOrder < $1.mealType.displayOrder }
//////
//////            VStack(spacing: 0) {
//////                ForEach(Array(entries.enumerated()), id: \.element.id) { idx, entry in
//////                    let isExpanded = entry.mealType == .breakfast
//////                                  || expandedMeals.contains(entry.mealType)
//////                                  || entry.caloriesConsumed > 0
//////
//////                    if isExpanded {
//////                        expandedMealRow(entry: entry)
//////                    } else {
//////                        compactMealRow(entry: entry)
//////                    }
//////
//////                    if idx < entries.count - 1 {
//////                        Divider().padding(.leading, isExpanded ? 68 : 52)
//////                    }
//////                }
//////            }
//////            .padding(.bottom, 4)
//////        }
//////        .background(Color.white)
//////        .cornerRadius(18)
//////        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
//////    }
//////
//////    @ViewBuilder
//////    private func expandedMealRow(entry: MealEntry) -> some View {
//////        let isLogged  = entry.caloriesConsumed > 0
//////        let timeHint  = mealTimeHint(entry.mealType)
//////        let loggedStr = loggedTimeString(entry)
//////
//////        HStack(spacing: 14) {
//////            ZStack {
//////                Circle()
//////                    .fill(entry.mealType.accentColor)
//////                    .frame(width: 44, height: 44)
//////                Image(systemName: mealIcon(entry.mealType))
//////                    .font(.system(size: 18, weight: .semibold))
//////                    .foregroundColor(.white)
//////            }
//////
//////            VStack(alignment: .leading, spacing: 3) {
//////                Text(entry.mealType.displayName)
//////                    .font(.system(size: 16, weight: .semibold))
//////                    .foregroundColor(.primary)
//////                Text(isLogged ? loggedStr : timeHint)
//////                    .font(.system(size: 13))
//////                    .foregroundColor(isLogged ? entry.mealType.accentColor : .secondary)
//////            }
//////
//////            Spacer()
//////
//////            if isLogged {
//////                Image(systemName: "checkmark.circle.fill")
//////                    .font(.system(size: 26))
//////                    .foregroundColor(entry.mealType.accentColor)
//////            } else {
//////                Button { pushMealId = entry.id } label: {
//////                    Image(systemName: "plus.circle.fill")
//////                        .font(.system(size: 26))
//////                        .foregroundColor(entry.mealType.accentColor)
//////                }
//////                .buttonStyle(.plain)
//////            }
//////        }
//////        .padding(.horizontal, 16)
//////        .padding(.vertical, 14)
//////        .contentShape(Rectangle())
//////        .onTapGesture { pushMealId = entry.id }
//////    }
//////
//////    @ViewBuilder
//////    private func compactMealRow(entry: MealEntry) -> some View {
//////        HStack(spacing: 12) {
//////            Circle()
//////                .fill(entry.mealType.accentColor)
//////                .frame(width: 10, height: 10)
//////            Text(entry.mealType.displayName)
//////                .font(.system(size: 15, weight: .medium))
//////                .foregroundColor(.primary)
//////            Spacer()
//////            Button { pushMealId = entry.id } label: {
//////                Image(systemName: "plus.circle.fill")
//////                    .font(.system(size: 24))
//////                    .foregroundColor(entry.mealType.accentColor)
//////            }
//////            .buttonStyle(.plain)
//////        }
//////        .padding(.horizontal, 16)
//////        .padding(.vertical, 11)
//////        .contentShape(Rectangle())
//////        .onTapGesture {
//////            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
//////                _ = expandedMeals.insert(entry.mealType)
//////            }
//////        }
//////    }
//////
//////    // MARK: - Meal helpers
//////
//////    private func mealIcon(_ type: MealType) -> String {
//////        switch type {
//////        case .breakfast: return "cup.and.saucer.fill"
//////        case .lunch:     return "fork.knife"
//////        case .snack:     return "takeoutbag.and.cup.and.straw.fill"
//////        case .dinner:    return "moon.fill"
//////        }
//////    }
//////
//////    private func mealTimeHint(_ type: MealType) -> String {
//////        switch type {
//////        case .breakfast: return "Recommended · 7:00 – 9:00 AM"
//////        case .lunch:     return "Recommended · 12:00 – 2:00 PM"
//////        case .snack:     return "Recommended · 4:00 – 5:00 PM"
//////        case .dinner:    return "Recommended · 7:00 – 9:00 PM"
//////        }
//////    }
//////
//////    private func loggedTimeString(_ entry: MealEntry) -> String {
//////        guard let loggedAt = entry.loggedAt else {
//////            return "Logged · \(Int(entry.caloriesConsumed)) kcal"
//////        }
//////        let f = DateFormatter(); f.dateFormat = "h:mm a"
//////        return "Logged at \(f.string(from: loggedAt)) · \(Int(entry.caloriesConsumed)) kcal"
//////    }
//////
//////    // MARK: - Water Card
//////
//////    private var waterCardCompact: some View {
//////        let today    = store.todaysTotalWaterML()
//////        let target   = store.activeNutritionProfile?.waterTargetML ?? 2500
//////        let progress = min(Double(today) / Double(max(target, 1)), 1.0)
//////        let todayL   = String(format: "%.1f", today  / 1000)
//////        let targetL  = String(format: "%.1f", target / 1000)
//////
//////        return VStack(alignment: .leading, spacing: 10) {
//////            Button { showHydration = true } label: {
//////                HStack {
//////                    Text("Water Intake")
//////                        .font(.system(size: 17, weight: .bold))
//////                        .foregroundColor(.primary)
//////                    Image(systemName: "chevron.right")
//////                        .font(.system(size: 13, weight: .semibold))
//////                        .foregroundColor(.secondary)
//////                    Spacer()
//////                    Text("\(todayL)/\(targetL)L")
//////                        .font(.system(size: 15, weight: .semibold))
//////                        .foregroundColor(.primary)
//////                }
//////            }
//////            .buttonStyle(.plain)
//////
//////            GeometryReader { geo in
//////                ZStack(alignment: .leading) {
//////                    Capsule()
//////                        .fill(Color(.systemGray5))
//////                        .frame(height: 8)
//////                    Capsule()
//////                        .fill(LinearGradient(
//////                            colors: [Color(red: 0.15, green: 0.55, blue: 0.95),
//////                                     Color(red: 0.0,  green: 0.75, blue: 0.95)],
//////                            startPoint: .leading, endPoint: .trailing))
//////                        .frame(width: geo.size.width * CGFloat(progress), height: 8)
//////                        .animation(.easeOut(duration: 0.4), value: today)
//////                }
//////            }
//////            .frame(height: 8)
//////
//////            HStack(spacing: 10) {
//////                ForEach([(150, "+ 150 ml"), (250, "+ 250 ml"), (500, "+ 500 ml")], id: \.0) { ml, label in
//////                    Button {
//////                        store.logWaterIntake(cupSize: "custom", amountML: Float(ml))
//////                    } label: {
//////                        Text(label)
//////                            .font(.system(size: 13, weight: .medium))
//////                            .foregroundColor(Color(red: 0.15, green: 0.45, blue: 0.85))
//////                            .padding(.horizontal, 14)
//////                            .padding(.vertical, 7)
//////                            .background(Color(red: 0.15, green: 0.45, blue: 0.85).opacity(0.10))
//////                            .clipShape(Capsule())
//////                    }
//////                    .buttonStyle(.plain)
//////                }
//////                Spacer()
//////            }
//////        }
//////        .padding(16)
//////        .background(Color.white)
//////        .cornerRadius(18)
//////    }
//////
//////    // MARK: - Daily Tip
//////
//////    private var dailyTipCard: some View {
//////        VStack(alignment: .leading, spacing: 12) {
//////            Text("Daily Tips")
//////                .font(.system(size: 20, weight: .bold))
//////            HStack(spacing: 16) {
//////                Image(systemName: "figure.walk")
//////                    .font(.system(size: 24))
//////                    .foregroundColor(Color(red: 0.55, green: 0.40, blue: 0.30))
//////                Text("20 minutes walk improves blood flow to scalp.")
//////                    .font(.system(size: 15, weight: .medium))
//////                    .foregroundColor(.black)
//////                Spacer()
//////            }
//////            .padding(16)
//////            .background(Color(red: 0.96, green: 0.95, blue: 0.93))
//////            .cornerRadius(18)
//////        }
//////    }
//////}
//////
//////// MARK: - Reusable Ring
//////
//////struct CenterRingView: View {
//////    let progress: CGFloat
//////    let icon: String
//////    let iconColor: Color
//////    let trackColor: Color
//////    let text: String
//////
//////    var body: some View {
//////        ZStack {
//////            Circle()
//////                .stroke(trackColor.opacity(0.15), lineWidth: 14)
//////            Circle()
//////                .trim(from: 0, to: progress)
//////                .stroke(trackColor, style: StrokeStyle(lineWidth: 14, lineCap: .round))
//////                .rotationEffect(.degrees(-90))
//////            VStack(spacing: 4) {
//////                Image(systemName: icon)
//////                    .font(.system(size: 18, weight: .semibold))
//////                    .foregroundColor(iconColor)
//////                Text(text)
//////                    .font(.system(size: 10, weight: .bold))
//////            }
//////        }
//////        .frame(width: 80, height: 80)
//////        .frame(maxWidth: .infinity, alignment: .center)
//////    }
//////}
////import SwiftUI
////
////// ── Shared card height — change once to resize both hero cards together ───────
////private let heroCardHeight: CGFloat = 218
////
////struct HomeView: View {
////    @Binding var selectedTab: Int
////
////    @Environment(AppDataStore.self) private var store
////    @State private var showCoach       = false
////    @State private var heroPage        = 0
////    @State private var showPlanDetails = false
////    @State private var showHydration   = false
////    @State private var pushMealId: UUID? = nil
////    @State private var expandedMeals: Set<MealType> = []
////
////    private var report:    ScanReport?           { store.latestScanReport }
////    private var plan:      UserPlan?             { store.activePlan }
////    private var nutrition: UserNutritionProfile? { store.activeNutritionProfile }
////
////    var body: some View {
////        NavigationStack {
////            ZStack {
////                Color.hcCream.ignoresSafeArea()
////
////                ScrollView(showsIndicators: false) {
////                    VStack(alignment: .leading, spacing: 20) {
////                        heroCardsSection
////                        featureCardsSection
////                        Color.clear.frame(height: 20)
////                    }
////                    .padding(.horizontal, 20)
////                    .padding(.top, 16)
////                }
////            }
////            .navigationTitle("Home")
////            .navigationBarTitleDisplayMode(.large)
////            .navigationDestination(item: $pushMealId) { mealId in
////                AddMealView(mealEntryId: mealId)
////            }
////        }
////        .sheet(isPresented: $showPlanDetails) {
////            PlanResultsView(onStart: { showPlanDetails = false })
////                .environment(store)
////        }
////        .sheet(isPresented: $showHydration) {
////            HydrationTrackerView()
////                .environment(store)
////        }
////        .sheet(isPresented: $showCoach) {
////            CoachView(viewModel: CoachViewModel())
////        }
////    }
////
////    // MARK: - Hero Swipe Cards
////
////    private var heroCardsSection: some View {
////        VStack(spacing: 10) {
////            TabView(selection: $heroPage) {
////                aiCoachCard
////                    .padding(.horizontal, 4)
////                    .tag(0)
////
////                hairHealthCard
////                    .padding(.horizontal, 4)
////                    .tag(1)
////            }
////            .tabViewStyle(.page(indexDisplayMode: .never))
////            .frame(height: heroCardHeight)
////            // ▼ Kills the default black TabView page-style background entirely
////            .background(Color.hcCream)
////
////            // Page dots
////            HStack(spacing: 8) {
////                ForEach(0..<2, id: \.self) { i in
////                    Circle()
////                        .fill(heroPage == i ? Color.hcBrown : Color(.systemGray4))
////                        .frame(width: heroPage == i ? 10 : 7,
////                               height: heroPage == i ? 10 : 7)
////                        .animation(.easeInOut(duration: 0.2), value: heroPage)
////                }
////            }
////        }
////    }
////
////    // MARK: - Card A — Hair Health
////
////    private var hairHealthCard: some View {
////        let density  = report?.hairDensityPercent ?? 52
////        let stage    = report?.hairFallStage.intValue ?? plan?.stage ?? 2
////        let progress = min(CGFloat(density) / 100.0, 1.0)
////
////        let (severityLabel, severityColor): (String, Color) = {
////            switch stage {
////            case 1: return ("Healthy",  Color(red: 0.22, green: 0.78, blue: 0.45))
////            case 2: return ("Moderate", Color(red: 1.00, green: 0.60, blue: 0.15))
////            case 3: return ("Severe",   Color(red: 0.95, green: 0.32, blue: 0.22))
////            default: return ("Critical", Color(red: 0.85, green: 0.15, blue: 0.15))
////            }
////        }()
////
////        let ringColor: Color = {
////            switch stage {
////            case 1: return Color(red: 0.22, green: 0.88, blue: 0.52)
////            case 2: return Color(red: 1.00, green: 0.62, blue: 0.18)
////            case 3: return Color(red: 0.95, green: 0.38, blue: 0.22)
////            default: return Color(red: 0.85, green: 0.20, blue: 0.20)
////            }
////        }()
////
////        let scanSubtitle: String = report != nil ? "Last scan available" : "No scan yet — tap to scan"
////
////        return VStack(spacing: 0) {
////
////            // ── Gradient hero section ─────────────────────────────────────
////            ZStack(alignment: .topLeading) {
////
////                // Hair Health gradient: matches AI Coach #6c4c4d mauve tones
////                LinearGradient(
////                    stops: [
////                        .init(color: Color(red: 0.424, green: 0.298, blue: 0.302), location: 0.0),
////                        .init(color: Color(red: 0.298, green: 0.192, blue: 0.196), location: 1.0),
////                    ],
////                    startPoint: .topLeading,
////                    endPoint: .bottomTrailing
////                )
////
////                // Ambient glow — cream #f3eed9 highlight
////                RadialGradient(
////                    colors: [Color(red: 0.953, green: 0.933, blue: 0.851).opacity(0.12), .clear],
////                    center: .init(x: 0.78, y: 0.22),
////                    startRadius: 10,
////                    endRadius: 140
////                )
////
////                // Ambient glow — mauve echo
////                RadialGradient(
////                    colors: [Color(red: 0.424, green: 0.298, blue: 0.302).opacity(0.28), .clear],
////                    center: .init(x: 0.15, y: 0.80),
////                    startRadius: 5,
////                    endRadius: 110
////                )
////
////                HStack(alignment: .center, spacing: 20) {
////
////                    // Density ring
////                    ZStack {
////                        Circle()
////                            .stroke(Color.white.opacity(0.10), lineWidth: 11)
////                            .frame(width: 96, height: 96)
////
////                        Circle()
////                            .trim(from: 0, to: progress)
////                            .stroke(
////                                AngularGradient(
////                                    colors: [ringColor.opacity(0.6), ringColor, ringColor.opacity(0.85)],
////                                    center: .center,
////                                    startAngle: .degrees(-90),
////                                    endAngle:   .degrees(270)
////                                ),
////                                style: StrokeStyle(lineWidth: 11, lineCap: .round)
////                            )
////                            .rotationEffect(.degrees(-90))
////                            .frame(width: 96, height: 96)
////                            .animation(.easeOut(duration: 0.9), value: progress)
////
////                        VStack(spacing: 1) {
////                            Text("\(Int(density))%")
////                                .font(.system(size: 22, weight: .bold, design: .rounded))
////                                .foregroundColor(.white)
////                            Text("DENSITY")
////                                .font(.system(size: 8, weight: .semibold))
////                                .foregroundColor(.white.opacity(0.55))
////                                .kerning(1.2)
////                        }
////                    }
////
////                    // Right text column
////                    VStack(alignment: .leading, spacing: 10) {
////
////                        HStack(spacing: 7) {
////                            Text("Stage \(stage)")
////                                .font(.system(size: 12, weight: .semibold))
////                                .foregroundColor(.white)
////                                .padding(.horizontal, 10)
////                                .padding(.vertical, 4)
////                                .background(.white.opacity(0.18), in: Capsule())
////                                .overlay(Capsule().stroke(.white.opacity(0.25), lineWidth: 0.5))
////
////                            Text(severityLabel)
////                                .font(.system(size: 12, weight: .semibold))
////                                .foregroundColor(severityColor)
////                                .padding(.horizontal, 10)
////                                .padding(.vertical, 4)
////                                .background(severityColor.opacity(0.18), in: Capsule())
////                                .overlay(Capsule().stroke(severityColor.opacity(0.35), lineWidth: 0.5))
////                        }
////
////                        Text("Hair Health Score")
////                            .font(.system(size: 20, weight: .bold))
////                            .foregroundColor(.white)
////                            .lineLimit(1)
////                            .minimumScaleFactor(0.85)
////
////                        Text(scanSubtitle)
////                            .font(.system(size: 13))
////                            .foregroundColor(.white.opacity(0.50))
////                    }
////
////                    Spacer(minLength: 0)
////                }
////                .padding(.horizontal, 18)
////                .padding(.vertical, 22)
////            }
////            .frame(height: heroCardHeight - 50)
////            .clipShape(UnevenRoundedRectangle(
////                topLeadingRadius: 18, bottomLeadingRadius: 0,
////                bottomTrailingRadius: 0, topTrailingRadius: 18
////            ))
////
////            // ── "View Hair Progress" native row ──────────────────────────
////            Button { showPlanDetails = true } label: {
////                HStack(spacing: 13) {
////                    Image(systemName: "waveform.path.ecg")
////                        .font(.system(size: 18, weight: .medium))
////                        .foregroundColor(Color(red: 0.28, green: 0.14, blue: 0.08))
////                        .frame(width: 26)
////
////                    Text("View Hair Progress")
////                        .font(.system(size: 16, weight: .semibold))
////                        .foregroundColor(.primary)
////
////                    Spacer()
////
////                    ZStack {
////                        Circle()
////                            .fill(Color(red: 0.18, green: 0.08, blue: 0.05))
////                            .frame(width: 32, height: 32)
////                        Image(systemName: "arrow.right")
////                            .font(.system(size: 13, weight: .bold))
////                            .foregroundColor(.white)
////                    }
////                }
////                .padding(.horizontal, 18)
////                .frame(height: 50)
////                .contentShape(Rectangle())
////            }
////            .buttonStyle(.plain)
////            .background(Color.white)
////            .clipShape(UnevenRoundedRectangle(
////                topLeadingRadius: 0, bottomLeadingRadius: 18,
////                bottomTrailingRadius: 18, topTrailingRadius: 0
////            ))
////        }
////        .frame(height: heroCardHeight)
////        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
////        .shadow(color: Color(red: 0.424, green: 0.298, blue: 0.302).opacity(0.20), radius: 12, x: 0, y: 4)
////    }
////
////    // MARK: - Card B — AI Coach
////
////    private var aiCoachCard: some View {
////        ZStack(alignment: .bottomLeading) {
////
////            // Background gradient — warm mauve #6c4c4d tones
////            LinearGradient(
////                stops: [
////                    .init(color: Color(red: 0.424, green: 0.298, blue: 0.302), location: 0.0),
////                    .init(color: Color(red: 0.298, green: 0.192, blue: 0.196), location: 1.0),
////                ],
////                startPoint: .topLeading,
////                endPoint: .bottomTrailing
////            )
////
////            // Ambient glow — warm cream #f3eed9 highlight
////            RadialGradient(
////                colors: [Color(red: 0.953, green: 0.933, blue: 0.851).opacity(0.14), .clear],
////                center: .init(x: 0.75, y: 0.25),
////                startRadius: 10,
////                endRadius: 160
////            )
////
////            // Ambient glow — mauve echo
////            RadialGradient(
////                colors: [Color(red: 0.424, green: 0.298, blue: 0.302).opacity(0.30), .clear],
////                center: .init(x: 0.15, y: 0.80),
////                startRadius: 5,
////                endRadius: 120
////            )
////
////            HStack(alignment: .center, spacing: 0) {
////
////                // Left text column
////                VStack(alignment: .leading, spacing: 10) {
////                    Spacer(minLength: 0)
////
////                    HStack(spacing: 5) {
////                        Circle()
////                            .fill(Color(red: 0.953, green: 0.933, blue: 0.851))
////                            .frame(width: 6, height: 6)
////                        Text("AI POWERED")
////                            .font(.system(size: 10, weight: .bold))
////                            .foregroundColor(Color(red: 0.953, green: 0.933, blue: 0.851))
////                            .kerning(1.3)
////                    }
////
////                    VStack(alignment: .leading, spacing: 4) {
////                        Text("Hair Coach")
////                            .font(.system(size: 22, weight: .bold))
////                            .foregroundColor(.white)
////                        Text("Personalised answers,\nanytime you need.")
////                            .font(.system(size: 13))
////                            .foregroundColor(.white.opacity(0.55))
////                            .lineSpacing(3)
////                    }
////
////                    Spacer(minLength: 0)
////
////                    Button { showCoach = true } label: {
////                        HStack(spacing: 7) {
////                            Text("Start Session")
////                                .font(.system(size: 14, weight: .semibold))
////                            Image(systemName: "arrow.right")
////                                .font(.system(size: 12, weight: .bold))
////                        }
////                        .foregroundColor(Color(red: 0.298, green: 0.192, blue: 0.196))
////                        .padding(.horizontal, 18)
////                        .padding(.vertical, 10)
////                        .background(.white, in: Capsule())
////                    }
////                    .buttonStyle(.plain)
////
////                    Spacer(minLength: 0)
////                }
////                .padding(.leading, 20)
////                .padding(.vertical, 20)
////
////                Spacer()
////
////                // Right icon with glow rings
////                ZStack {
////                    Circle()
////                        .stroke(Color(red: 0.953, green: 0.933, blue: 0.851).opacity(0.12), lineWidth: 1)
////                        .frame(width: 100, height: 100)
////                    Circle()
////                        .stroke(Color(red: 0.953, green: 0.933, blue: 0.851).opacity(0.20), lineWidth: 1)
////                        .frame(width: 76, height: 76)
////                        .padding()
////                    ZStack {
////                        Circle()
////                            .fill(
////                                LinearGradient(
////                                    colors: [
////                                        Color(red: 0.549, green: 0.373, blue: 0.376),
////                                        Color(red: 0.380, green: 0.247, blue: 0.251),
////                                    ],
////                                    startPoint: .topLeading,
////                                    endPoint: .bottomTrailing
////                                )
////                            )
////                            .frame(width: 58, height: 58)
////                        Image(systemName: "brain.head.profile")
////                            .font(.system(size: 24, weight: .medium))
////                            .foregroundColor(Color(red: 0.953, green: 0.933, blue: 0.851))
////                    }
////                }
////                .padding(.trailing, 22)
////            }
////        }
////        .frame(height: heroCardHeight)
////        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
////        .shadow(color: Color(red: 0.424, green: 0.298, blue: 0.302).opacity(0.20), radius: 12, x: 0, y: 4)
////    }
////
////    // MARK: - Feature Cards
////
////    private var featureCardsSection: some View {
////        VStack(spacing: 20) {
////            todaySection
////            logMealsSection
////            waterCardCompact
////            dailyTipCard
////        }
////    }
////
////    // MARK: - Today (fitness rings)
////
////    private var todaySection: some View {
////        VStack(alignment: .leading, spacing: 12) {
////            Text("Today")
////                .font(.system(size: 22, weight: .bold))
////                .padding(.bottom, 2)
////
////            HStack(alignment: .top, spacing: 12) {
////                NavigationLink(destination: CaloriesDetailView().environment(store)) {
////                    fitnessCard(
////                        title: "Calories", icon: "flame.fill", iconColor: .orange,
////                        gradientColors: [Color(red: 0.13, green: 0.09, blue: 0.07),
////                                         Color(red: 0.22, green: 0.10, blue: 0.04)],
////                        current: Double(store.todaysTotalCalories()),
////                        target:  Double(store.activeNutritionProfile?.tdee ?? 1500),
////                        ringColor: .orange, unitSuffix: "kcal"
////                    )
////                }
////                .buttonStyle(.plain)
////
////                NavigationLink(destination: MindfulDetailView().environment(store)) {
////                    fitnessCard(
////                        title: "MindEase", icon: "figure.mind.and.body",
////                        iconColor: Color(red: 0.65, green: 0.55, blue: 1.0),
////                        gradientColors: [Color(red: 0.18, green: 0.12, blue: 0.38),
////                                         Color(red: 0.28, green: 0.18, blue: 0.55)],
////                        current: Double(store.todaysMindfulMinutes()),
////                        target:  Double(max(store.dailyMindfulTarget, 20)),
////                        ringColor: Color(red: 0.40, green: 0.30, blue: 0.85),
////                        unitSuffix: "min"
////                    )
////                }
////                .buttonStyle(.plain)
////            }
////        }
////    }
////
////    private func fitnessCard(
////        title: String, icon: String, iconColor: Color,
////        gradientColors: [Color], current: Double, target: Double,
////        ringColor: Color, unitSuffix: String
////    ) -> some View {
////        let progress = min(current / max(target, 1), 1.0)
////        let pct      = Int(progress * 100)
////        return VStack(alignment: .leading, spacing: 0) {
////            HStack {
////                Image(systemName: icon)
////                    .font(.system(size: 14, weight: .bold))
////                    .foregroundColor(iconColor)
////                Text(title)
////                    .font(.system(size: 13, weight: .bold))
////                    .foregroundColor(.white.opacity(0.75))
////                Spacer()
////            }
////            .padding(.bottom, 14)
////
////            ZStack {
////                Circle()
////                    .stroke(ringColor.opacity(0.18), lineWidth: 10)
////                Circle()
////                    .trim(from: 0, to: CGFloat(progress))
////                    .stroke(ringColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
////                    .rotationEffect(.degrees(-90))
////                    .animation(.easeOut(duration: 0.7), value: progress)
////                VStack(spacing: 1) {
////                    Text("\(pct)%")
////                        .font(.system(size: 18, weight: .bold))
////                        .foregroundColor(.white)
////                    Text("of goal")
////                        .font(.system(size: 9, weight: .medium))
////                        .foregroundColor(.white.opacity(0.55))
////                }
////            }
////            .frame(width: 72, height: 72)
////            .frame(maxWidth: .infinity)
////            .padding(.bottom, 14)
////
////            VStack(alignment: .leading, spacing: 2) {
////                Text(current < 1000
////                     ? "\(Int(current)) \(unitSuffix)"
////                     : String(format: "%.0f \(unitSuffix)", current))
////                    .font(.system(size: 16, weight: .bold))
////                    .foregroundColor(.white)
////                Text("Goal \(Int(target)) \(unitSuffix)")
////                    .font(.system(size: 11))
////                    .foregroundColor(.white.opacity(0.5))
////            }
////        }
////        .padding(14)
////        .frame(maxWidth: .infinity, maxHeight: .infinity)
////        .background(
////            LinearGradient(colors: gradientColors,
////                           startPoint: .topLeading, endPoint: .bottomTrailing)
////        )
////        .cornerRadius(18)
////    }
////
////    // MARK: - Log Meals — Apple Health "Today's Log" style
////
////    private var logMealsSection: some View {
////        VStack(alignment: .leading, spacing: 0) {
////
////            Text("Today's Log")
////                .font(.system(size: 20, weight: .bold))
////                .padding(.horizontal, 16)
////                .padding(.top, 16)
////                .padding(.bottom, 12)
////
////            Divider().padding(.horizontal, 16)
////
////            let entries = store.todaysMealEntries()
////                .sorted { $0.mealType.displayOrder < $1.mealType.displayOrder }
////
////            VStack(spacing: 0) {
////                ForEach(Array(entries.enumerated()), id: \.element.id) { idx, entry in
////                    let isExpanded = entry.mealType == .breakfast
////                                  || expandedMeals.contains(entry.mealType)
////                                  || entry.caloriesConsumed > 0
////
////                    if isExpanded {
////                        expandedMealRow(entry: entry)
////                    } else {
////                        compactMealRow(entry: entry)
////                    }
////
////                    if idx < entries.count - 1 {
////                        Divider().padding(.leading, isExpanded ? 68 : 52)
////                    }
////                }
////            }
////            .padding(.bottom, 4)
////        }
////        .background(Color.white)
////        .cornerRadius(18)
////        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
////    }
////
////    @ViewBuilder
////    private func expandedMealRow(entry: MealEntry) -> some View {
////        let isLogged  = entry.caloriesConsumed > 0
////        let timeHint  = mealTimeHint(entry.mealType)
////        let loggedStr = loggedTimeString(entry)
////
////        HStack(spacing: 14) {
////            ZStack {
////                Circle()
////                    .fill(entry.mealType.accentColor)
////                    .frame(width: 44, height: 44)
////                Image(systemName: mealIcon(entry.mealType))
////                    .font(.system(size: 18, weight: .semibold))
////                    .foregroundColor(.white)
////            }
////
////            VStack(alignment: .leading, spacing: 3) {
////                Text(entry.mealType.displayName)
////                    .font(.system(size: 16, weight: .semibold))
////                    .foregroundColor(.primary)
////                Text(isLogged ? loggedStr : timeHint)
////                    .font(.system(size: 13))
////                    .foregroundColor(isLogged ? entry.mealType.accentColor : .secondary)
////            }
////
////            Spacer()
////
////            if isLogged {
////                Image(systemName: "checkmark.circle.fill")
////                    .font(.system(size: 26))
////                    .foregroundColor(entry.mealType.accentColor)
////            } else {
////                Button { pushMealId = entry.id } label: {
////                    Image(systemName: "plus.circle.fill")
////                        .font(.system(size: 26))
////                        .foregroundColor(entry.mealType.accentColor)
////                }
////                .buttonStyle(.plain)
////            }
////        }
////        .padding(.horizontal, 16)
////        .padding(.vertical, 14)
////        .contentShape(Rectangle())
////        .onTapGesture { pushMealId = entry.id }
////    }
////
////    @ViewBuilder
////    private func compactMealRow(entry: MealEntry) -> some View {
////        HStack(spacing: 12) {
////            Circle()
////                .fill(entry.mealType.accentColor)
////                .frame(width: 10, height: 10)
////            Text(entry.mealType.displayName)
////                .font(.system(size: 15, weight: .medium))
////                .foregroundColor(.primary)
////            Spacer()
////            Button { pushMealId = entry.id } label: {
////                Image(systemName: "plus.circle.fill")
////                    .font(.system(size: 24))
////                    .foregroundColor(entry.mealType.accentColor)
////            }
////            .buttonStyle(.plain)
////        }
////        .padding(.horizontal, 16)
////        .padding(.vertical, 11)
////        .contentShape(Rectangle())
////        .onTapGesture {
////            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
////                _ = expandedMeals.insert(entry.mealType)
////            }
////        }
////    }
////
////    // MARK: - Meal helpers
////
////    private func mealIcon(_ type: MealType) -> String {
////        switch type {
////        case .breakfast: return "cup.and.saucer.fill"
////        case .lunch:     return "fork.knife"
////        case .snack:     return "takeoutbag.and.cup.and.straw.fill"
////        case .dinner:    return "moon.fill"
////        }
////    }
////
////    private func mealTimeHint(_ type: MealType) -> String {
////        switch type {
////        case .breakfast: return "Recommended · 7:00 – 9:00 AM"
////        case .lunch:     return "Recommended · 12:00 – 2:00 PM"
////        case .snack:     return "Recommended · 4:00 – 5:00 PM"
////        case .dinner:    return "Recommended · 7:00 – 9:00 PM"
////        }
////    }
////
////    private func loggedTimeString(_ entry: MealEntry) -> String {
////        guard let loggedAt = entry.loggedAt else {
////            return "Logged · \(Int(entry.caloriesConsumed)) kcal"
////        }
////        let f = DateFormatter(); f.dateFormat = "h:mm a"
////        return "Logged at \(f.string(from: loggedAt)) · \(Int(entry.caloriesConsumed)) kcal"
////    }
////
////    // MARK: - Water Card
////
////    private var waterCardCompact: some View {
////        let today    = store.todaysTotalWaterML()
////        let target   = store.activeNutritionProfile?.waterTargetML ?? 2500
////        let progress = min(Double(today) / Double(max(target, 1)), 1.0)
////        let todayL   = String(format: "%.1f", today  / 1000)
////        let targetL  = String(format: "%.1f", target / 1000)
////
////        return VStack(alignment: .leading, spacing: 10) {
////            Button { showHydration = true } label: {
////                HStack {
////                    Text("Water Intake")
////                        .font(.system(size: 17, weight: .bold))
////                        .foregroundColor(.primary)
////                    Image(systemName: "chevron.right")
////                        .font(.system(size: 13, weight: .semibold))
////                        .foregroundColor(.secondary)
////                    Spacer()
////                    Text("\(todayL)/\(targetL)L")
////                        .font(.system(size: 15, weight: .semibold))
////                        .foregroundColor(.primary)
////                }
////            }
////            .buttonStyle(.plain)
////
////            GeometryReader { geo in
////                ZStack(alignment: .leading) {
////                    Capsule()
////                        .fill(Color(.systemGray5))
////                        .frame(height: 8)
////                    Capsule()
////                        .fill(LinearGradient(
////                            colors: [Color(red: 0.15, green: 0.55, blue: 0.95),
////                                     Color(red: 0.0,  green: 0.75, blue: 0.95)],
////                            startPoint: .leading, endPoint: .trailing))
////                        .frame(width: geo.size.width * CGFloat(progress), height: 8)
////                        .animation(.easeOut(duration: 0.4), value: today)
////                }
////            }
////            .frame(height: 8)
////
////            HStack(spacing: 10) {
////                ForEach([(150, "+ 150 ml"), (250, "+ 250 ml"), (500, "+ 500 ml")], id: \.0) { ml, label in
////                    Button {
////                        store.logWaterIntake(cupSize: "custom", amountML: Float(ml))
////                    } label: {
////                        Text(label)
////                            .font(.system(size: 13, weight: .medium))
////                            .foregroundColor(Color(red: 0.15, green: 0.45, blue: 0.85))
////                            .padding(.horizontal, 14)
////                            .padding(.vertical, 7)
////                            .background(Color(red: 0.15, green: 0.45, blue: 0.85).opacity(0.10))
////                            .clipShape(Capsule())
////                    }
////                    .buttonStyle(.plain)
////                }
////                Spacer()
////            }
////        }
////        .padding(16)
////        .background(Color.white)
////        .cornerRadius(18)
////    }
////
////    // MARK: - Daily Tip
////
////    private var dailyTipCard: some View {
////        VStack(alignment: .leading, spacing: 12) {
////            Text("Daily Tips")
////                .font(.system(size: 20, weight: .bold))
////            HStack(spacing: 16) {
////                Image(systemName: "figure.walk")
////                    .font(.system(size: 24))
////                    .foregroundColor(Color(red: 0.55, green: 0.40, blue: 0.30))
////                Text("20 minutes walk improves blood flow to scalp.")
////                    .font(.system(size: 15, weight: .medium))
////                    .foregroundColor(.black)
////                Spacer()
////            }
////            .padding(16)
////            .background(Color(red: 0.96, green: 0.95, blue: 0.93))
////            .cornerRadius(18)
////        }
////    }
////}
////
////// MARK: - Reusable Ring
////
////struct CenterRingView: View {
////    let progress: CGFloat
////    let icon: String
////    let iconColor: Color
////    let trackColor: Color
////    let text: String
////
////    var body: some View {
////        ZStack {
////            Circle()
////                .stroke(trackColor.opacity(0.15), lineWidth: 14)
////            Circle()
////                .trim(from: 0, to: progress)
////                .stroke(trackColor, style: StrokeStyle(lineWidth: 14, lineCap: .round))
////                .rotationEffect(.degrees(-90))
////            VStack(spacing: 4) {
////                Image(systemName: icon)
////                    .font(.system(size: 18, weight: .semibold))
////                    .foregroundColor(iconColor)
////                Text(text)
////                    .font(.system(size: 10, weight: .bold))
////            }
////        }
////        .frame(width: 80, height: 80)
////        .frame(maxWidth: .infinity, alignment: .center)
////    }
////}
//import SwiftUI
//
//// ── Shared card height — change once to resize both hero cards together ───────
//private let heroCardHeight: CGFloat = 218
//
//struct HomeView: View {
//    @Binding var selectedTab: Int
//
//    @Environment(AppDataStore.self) private var store
//    @State private var showCoach       = false
//    @State private var heroPage        = 0
//    @State private var showPlanDetails = false
//    @State private var showHydration   = false
//    @State private var pushMealId: UUID? = nil
//    @State private var expandedMeals: Set<MealType> = []
//
//    private var report:    ScanReport?           { store.latestScanReport }
//    private var plan:      UserPlan?             { store.activePlan }
//    private var nutrition: UserNutritionProfile? { store.activeNutritionProfile }
//
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                Color.hcCream.ignoresSafeArea()
//
//                ScrollView(showsIndicators: false) {
//                    VStack(alignment: .leading, spacing: 20) {
//                        heroCardsSection
//                        featureCardsSection
//                        Color.clear.frame(height: 20)
//                    }
//                    .padding(.horizontal, 20)
//                    .padding(.top, 16)
//                }
//            }
//            .navigationTitle("Home")
//            .navigationBarTitleDisplayMode(.large)
//            .navigationDestination(item: $pushMealId) { mealId in
//                AddMealView(mealEntryId: mealId)
//            }
//        }
//        .sheet(isPresented: $showPlanDetails) {
//            PlanResultsView(onStart: { showPlanDetails = false })
//                .environment(store)
//        }
//        .sheet(isPresented: $showHydration) {
//            HydrationTrackerView()
//                .environment(store)
//        }
//        .sheet(isPresented: $showCoach) {
//            CoachView(viewModel: CoachViewModel())
//        }
//    }
//
//    // MARK: - Hero Swipe Cards
//
//    private var heroCardsSection: some View {
//        VStack(spacing: 10) {
//            TabView(selection: $heroPage) {
//                aiCoachCard
//                    .padding(.horizontal, 4)
//                    .tag(0)
//
//                hairHealthCard
//                    .padding(.horizontal, 4)
//                    .tag(1)
//            }
//            .tabViewStyle(.page(indexDisplayMode: .never))
//            .frame(height: heroCardHeight)
//            // ▼ Kills the default black TabView page-style background entirely
//            .background(Color.hcCream)
//
//            // Page dots
//            HStack(spacing: 8) {
//                ForEach(0..<2, id: \.self) { i in
//                    Circle()
//                        .fill(heroPage == i ? Color.hcBrown : Color(.systemGray4))
//                        .frame(width: heroPage == i ? 10 : 7,
//                               height: heroPage == i ? 10 : 7)
//                        .animation(.easeInOut(duration: 0.2), value: heroPage)
//                }
//            }
//        }
//    }
//
//    // MARK: - Card A — Hair Health
//
//    private var hairHealthCard: some View {
//        let density  = report?.hairDensityPercent ?? 52
//        let stage    = report?.hairFallStage.intValue ?? plan?.stage ?? 2
//        let progress = min(CGFloat(density) / 100.0, 1.0)
//
//        let (severityLabel, severityColor): (String, Color) = {
//            switch stage {
//            case 1: return ("Healthy",  Color(red: 0.22, green: 0.78, blue: 0.45))
//            case 2: return ("Moderate", Color(red: 1.00, green: 0.60, blue: 0.15))
//            case 3: return ("Severe",   Color(red: 0.95, green: 0.32, blue: 0.22))
//            default: return ("Critical", Color(red: 0.85, green: 0.15, blue: 0.15))
//            }
//        }()
//
//        let ringColor: Color = {
//            switch stage {
//            case 1: return Color(red: 0.22, green: 0.88, blue: 0.52)
//            case 2: return Color(red: 1.00, green: 0.62, blue: 0.18)
//            case 3: return Color(red: 0.95, green: 0.38, blue: 0.22)
//            default: return Color(red: 0.85, green: 0.20, blue: 0.20)
//            }
//        }()
//
//        let scanSubtitle: String = report != nil ? "Last scan available" : "No scan yet — tap to scan"
//
//        return VStack(spacing: 0) {
//
//            // ── Gradient hero section ─────────────────────────────────────
//            ZStack(alignment: .topLeading) {
//
//                // Hair Health gradient: matches AI Coach #6c4c4d mauve tones
//                LinearGradient(
//                    stops: [
//                        .init(color: Color(red: 0.424, green: 0.298, blue: 0.302), location: 0.0),
//                        .init(color: Color(red: 0.298, green: 0.192, blue: 0.196), location: 1.0),
//                    ],
//                    startPoint: .topLeading,
//                    endPoint: .bottomTrailing
//                )
//
//                // Ambient glow — cream #f3eed9 highlight
//                RadialGradient(
//                    colors: [Color(red: 0.953, green: 0.933, blue: 0.851).opacity(0.12), .clear],
//                    center: .init(x: 0.78, y: 0.22),
//                    startRadius: 10,
//                    endRadius: 140
//                )
//
//                // Ambient glow — mauve echo
//                RadialGradient(
//                    colors: [Color(red: 0.424, green: 0.298, blue: 0.302).opacity(0.28), .clear],
//                    center: .init(x: 0.15, y: 0.80),
//                    startRadius: 5,
//                    endRadius: 110
//                )
//
//                HStack(alignment: .center, spacing: 20) {
//
//                    // Density ring
//                    ZStack {
//                        Circle()
//                            .stroke(Color.white.opacity(0.10), lineWidth: 11)
//                            .frame(width: 96, height: 96)
//
//                        Circle()
//                            .trim(from: 0, to: progress)
//                            .stroke(
//                                AngularGradient(
//                                    colors: [ringColor.opacity(0.6), ringColor, ringColor.opacity(0.85)],
//                                    center: .center,
//                                    startAngle: .degrees(-90),
//                                    endAngle:   .degrees(270)
//                                ),
//                                style: StrokeStyle(lineWidth: 11, lineCap: .round)
//                            )
//                            .rotationEffect(.degrees(-90))
//                            .frame(width: 96, height: 96)
//                            .animation(.easeOut(duration: 0.9), value: progress)
//
//                        VStack(spacing: 1) {
//                            Text("\(Int(density))%")
//                                .font(.system(size: 22, weight: .bold, design: .rounded))
//                                .foregroundColor(.white)
//                            Text("DENSITY")
//                                .font(.system(size: 8, weight: .semibold))
//                                .foregroundColor(.white.opacity(0.55))
//                                .kerning(1.2)
//                        }
//                    }
//
//                    // Right text column
//                    VStack(alignment: .leading, spacing: 10) {
//
//                        HStack(spacing: 7) {
//                            Text("Stage \(stage)")
//                                .font(.system(size: 12, weight: .semibold))
//                                .foregroundColor(.white)
//                                .padding(.horizontal, 10)
//                                .padding(.vertical, 4)
//                                .background(.white.opacity(0.18), in: Capsule())
//                                .overlay(Capsule().stroke(.white.opacity(0.25), lineWidth: 0.5))
//
//                            Text(severityLabel)
//                                .font(.system(size: 12, weight: .semibold))
//                                .foregroundColor(severityColor)
//                                .padding(.horizontal, 10)
//                                .padding(.vertical, 4)
//                                .background(severityColor.opacity(0.18), in: Capsule())
//                                .overlay(Capsule().stroke(severityColor.opacity(0.35), lineWidth: 0.5))
//                        }
//
//                        Text("Hair Health Score")
//                            .font(.system(size: 20, weight: .bold))
//                            .foregroundColor(.white)
//                            .lineLimit(1)
//                            .minimumScaleFactor(0.85)
//
//                        Text(scanSubtitle)
//                            .font(.system(size: 13))
//                            .foregroundColor(.white.opacity(0.50))
//                    }
//
//                    Spacer(minLength: 0)
//                }
//                .padding(.horizontal, 18)
//                .padding(.vertical, 22)
//            }
//            .frame(height: heroCardHeight - 50)
//            .clipShape(UnevenRoundedRectangle(
//                topLeadingRadius: 18, bottomLeadingRadius: 0,
//                bottomTrailingRadius: 0, topTrailingRadius: 18
//            ))
//
//            // ── "View Hair Progress" native row ──────────────────────────
//            Button { showPlanDetails = true } label: {
//                HStack(spacing: 13) {
//                    Image(systemName: "waveform.path.ecg")
//                        .font(.system(size: 18, weight: .medium))
//                        .foregroundColor(Color(red: 0.28, green: 0.14, blue: 0.08))
//                        .frame(width: 26)
//
//                    Text("View Hair Progress")
//                        .font(.system(size: 16, weight: .semibold))
//                        .foregroundColor(.primary)
//
//                    Spacer()
//
//                    ZStack {
//                        Circle()
//                            .fill(Color(red: 0.18, green: 0.08, blue: 0.05))
//                            .frame(width: 32, height: 32)
//                        Image(systemName: "arrow.right")
//                            .font(.system(size: 13, weight: .bold))
//                            .foregroundColor(.white)
//                    }
//                }
//                .padding(.horizontal, 18)
//                .frame(height: 50)
//                .contentShape(Rectangle())
//            }
//            .buttonStyle(.plain)
//            .background(Color.white)
//            .clipShape(UnevenRoundedRectangle(
//                topLeadingRadius: 0, bottomLeadingRadius: 18,
//                bottomTrailingRadius: 18, topTrailingRadius: 0
//            ))
//        }
//        .frame(height: heroCardHeight)
//        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
//        .shadow(color: Color(red: 0.424, green: 0.298, blue: 0.302).opacity(0.20), radius: 12, x: 0, y: 4)
//    }
//
//    // MARK: - Card B — AI Coach
//
//    private var aiCoachCard: some View {
//        ZStack(alignment: .bottomLeading) {
//
//            // Background gradient — warm mauve #6c4c4d tones
//            LinearGradient(
//                stops: [
//                    .init(color: Color(red: 0.424, green: 0.298, blue: 0.302), location: 0.0),
//                    .init(color: Color(red: 0.298, green: 0.192, blue: 0.196), location: 1.0),
//                ],
//                startPoint: .topLeading,
//                endPoint: .bottomTrailing
//            )
//
//            // Ambient glow — warm cream #f3eed9 highlight
//            RadialGradient(
//                colors: [Color(red: 0.953, green: 0.933, blue: 0.851).opacity(0.14), .clear],
//                center: .init(x: 0.75, y: 0.25),
//                startRadius: 10,
//                endRadius: 160
//            )
//
//            // Ambient glow — mauve echo
//            RadialGradient(
//                colors: [Color(red: 0.424, green: 0.298, blue: 0.302).opacity(0.30), .clear],
//                center: .init(x: 0.15, y: 0.80),
//                startRadius: 5,
//                endRadius: 120
//            )
//
//            HStack(alignment: .center, spacing: 0) {
//
//                // Left text column
//                VStack(alignment: .leading, spacing: 10) {
//                    Spacer(minLength: 0)
//
//                    HStack(spacing: 5) {
//                        Circle()
//                            .fill(Color(red: 0.953, green: 0.933, blue: 0.851))
//                            .frame(width: 6, height: 6)
//                        Text("AI POWERED")
//                            .font(.system(size: 10, weight: .bold))
//                            .foregroundColor(Color(red: 0.953, green: 0.933, blue: 0.851))
//                            .kerning(1.3)
//                    }
//
//                    VStack(alignment: .leading, spacing: 4) {
//                        Text("Hair Coach")
//                            .font(.system(size: 22, weight: .bold))
//                            .foregroundColor(.white)
//                        Text("Personalised answers,\nanytime you need.")
//                            .font(.system(size: 13))
//                            .foregroundColor(.white.opacity(0.55))
//                            .lineSpacing(3)
//                    }
//
//                    Spacer(minLength: 0)
//
//                    Button { showCoach = true } label: {
//                        HStack(spacing: 7) {
//                            Text("Start Session")
//                                .font(.system(size: 14, weight: .semibold))
//                            Image(systemName: "arrow.right")
//                                .font(.system(size: 12, weight: .bold))
//                        }
//                        .foregroundColor(Color(red: 0.298, green: 0.192, blue: 0.196))
//                        .padding(.horizontal, 18)
//                        .padding(.vertical, 10)
//                        .background(.white, in: Capsule())
//                    }
//                    .buttonStyle(.plain)
//
//                    Spacer(minLength: 0)
//                }
//                .padding(.leading, 20)
//                .padding(.vertical, 20)
//
//                Spacer()
//
//                // Right icon with glow rings
//                ZStack {
//                    Circle()
//                        .stroke(Color(red: 0.953, green: 0.933, blue: 0.851).opacity(0.12), lineWidth: 1)
//                        .frame(width: 100, height: 100)
//                    Circle()
//                        .stroke(Color(red: 0.953, green: 0.933, blue: 0.851).opacity(0.20), lineWidth: 1)
//                        .frame(width: 76, height: 76)
//                        .padding()
//                    ZStack {
//                        Circle()
//                            .fill(
//                                LinearGradient(
//                                    colors: [
//                                        Color(red: 0.549, green: 0.373, blue: 0.376),
//                                        Color(red: 0.380, green: 0.247, blue: 0.251),
//                                    ],
//                                    startPoint: .topLeading,
//                                    endPoint: .bottomTrailing
//                                )
//                            )
//                            .frame(width: 58, height: 58)
//                        Image(systemName: "brain.head.profile")
//                            .font(.system(size: 24, weight: .medium))
//                            .foregroundColor(Color(red: 0.953, green: 0.933, blue: 0.851))
//                    }
//                }
//                .padding(.trailing, 22)
//            }
//        }
//        .frame(height: heroCardHeight)
//        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
//        .shadow(color: Color(red: 0.424, green: 0.298, blue: 0.302).opacity(0.20), radius: 12, x: 0, y: 4)
//    }
//
//    // MARK: - Feature Cards
//
//    private var featureCardsSection: some View {
//        VStack(spacing: 20) {
//            todaySection
//            logMealsSection
//            waterCardCompact
//            dailyTipCard
//        }
//    }
//
//    // MARK: - Today (fitness rings)
//
//    private var todaySection: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            Text("Today")
//                .font(.system(size: 22, weight: .bold))
//                .padding(.bottom, 2)
//
//            HStack(alignment: .top, spacing: 12) {
//                NavigationLink(destination: CaloriesDetailView().environment(store)) {
//                    fitnessCard(
//                        title: "Calories", icon: "flame.fill", iconColor: .orange,
//                        gradientColors: [Color(red: 0.13, green: 0.09, blue: 0.07),
//                                         Color(red: 0.22, green: 0.10, blue: 0.04)],
//                        current: Double(store.todaysTotalCalories()),
//                        target:  Double(store.activeNutritionProfile?.tdee ?? 1500),
//                        ringColor: .orange, unitSuffix: "kcal"
//                    )
//                }
//                .buttonStyle(.plain)
//
//                NavigationLink(destination: MindfulDetailView().environment(store)) {
//                    fitnessCard(
//                        title: "MindEase", icon: "figure.mind.and.body",
//                        iconColor: Color(red: 0.65, green: 0.55, blue: 1.0),
//                        gradientColors: [Color(red: 0.18, green: 0.12, blue: 0.38),
//                                         Color(red: 0.28, green: 0.18, blue: 0.55)],
//                        current: Double(store.todaysMindfulMinutes()),
//                        target:  Double(max(store.dailyMindfulTarget, 20)),
//                        ringColor: Color(red: 0.40, green: 0.30, blue: 0.85),
//                        unitSuffix: "min"
//                    )
//                }
//                .buttonStyle(.plain)
//            }
//        }
//    }
//
//    private func fitnessCard(
//        title: String, icon: String, iconColor: Color,
//        gradientColors: [Color], current: Double, target: Double,
//        ringColor: Color, unitSuffix: String
//    ) -> some View {
//        let progress = min(current / max(target, 1), 1.0)
//        let pct      = Int(progress * 100)
//        return VStack(alignment: .leading, spacing: 0) {
//            HStack {
//                Image(systemName: icon)
//                    .font(.system(size: 14, weight: .bold))
//                    .foregroundColor(iconColor)
//                Text(title)
//                    .font(.system(size: 13, weight: .bold))
//                    .foregroundColor(.white.opacity(0.75))
//                Spacer()
//            }
//            .padding(.bottom, 14)
//
//            ZStack {
//                Circle()
//                    .stroke(ringColor.opacity(0.18), lineWidth: 10)
//                Circle()
//                    .trim(from: 0, to: CGFloat(progress))
//                    .stroke(ringColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
//                    .rotationEffect(.degrees(-90))
//                    .animation(.easeOut(duration: 0.7), value: progress)
//                VStack(spacing: 1) {
//                    Text("\(pct)%")
//                        .font(.system(size: 18, weight: .bold))
//                        .foregroundColor(.white)
//                    Text("of goal")
//                        .font(.system(size: 9, weight: .medium))
//                        .foregroundColor(.white.opacity(0.55))
//                }
//            }
//            .frame(width: 72, height: 72)
//            .frame(maxWidth: .infinity)
//            .padding(.bottom, 14)
//
//            VStack(alignment: .leading, spacing: 2) {
//                Text(current < 1000
//                     ? "\(Int(current)) \(unitSuffix)"
//                     : String(format: "%.0f \(unitSuffix)", current))
//                    .font(.system(size: 16, weight: .bold))
//                    .foregroundColor(.white)
//                Text("Goal \(Int(target)) \(unitSuffix)")
//                    .font(.system(size: 11))
//                    .foregroundColor(.white.opacity(0.5))
//            }
//        }
//        .padding(14)
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(
//            LinearGradient(colors: gradientColors,
//                           startPoint: .topLeading, endPoint: .bottomTrailing)
//        )
//        .cornerRadius(18)
//    }
//
//    // MARK: - Log Meals — Apple Health "Today's Log" style
//
//    private var logMealsSection: some View {
//        VStack(alignment: .leading, spacing: 0) {
//
//            Text("Today's Log")
//                .font(.system(size: 20, weight: .bold))
//                .padding(.horizontal, 16)
//                .padding(.top, 16)
//                .padding(.bottom, 12)
//
//            Divider().padding(.horizontal, 16)
//
//            let entries = store.todaysMealEntries()
//                .sorted { $0.mealType.displayOrder < $1.mealType.displayOrder }
//
//            VStack(spacing: 0) {
//                ForEach(Array(entries.enumerated()), id: \.element.id) { idx, entry in
//                    let isExpanded = entry.mealType == .breakfast
//                                  || expandedMeals.contains(entry.mealType)
//                                  || entry.caloriesConsumed > 0
//
//                    if isExpanded {
//                        expandedMealRow(entry: entry)
//                    } else {
//                        compactMealRow(entry: entry)
//                    }
//
//                    if idx < entries.count - 1 {
//                        Divider().padding(.leading, isExpanded ? 68 : 52)
//                    }
//                }
//            }
//            .padding(.bottom, 4)
//        }
//        .background(Color.white)
//        .cornerRadius(18)
//        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
//    }
//
//    @ViewBuilder
//    private func expandedMealRow(entry: MealEntry) -> some View {
//        let isLogged  = entry.caloriesConsumed > 0
//        let timeHint  = mealTimeHint(entry.mealType)
//        let loggedStr = loggedTimeString(entry)
//
//        HStack(spacing: 14) {
//            ZStack {
//                Circle()
//                    .fill(entry.mealType.accentColor)
//                    .frame(width: 44, height: 44)
//                Image(systemName: mealIcon(entry.mealType))
//                    .font(.system(size: 18, weight: .semibold))
//                    .foregroundColor(.white)
//            }
//
//            VStack(alignment: .leading, spacing: 3) {
//                Text(entry.mealType.displayName)
//                    .font(.system(size: 16, weight: .semibold))
//                    .foregroundColor(.primary)
//                Text(isLogged ? loggedStr : timeHint)
//                    .font(.system(size: 13))
//                    .foregroundColor(isLogged ? Color(red: 0.20, green: 0.78, blue: 0.35) : .secondary)
//            }
//
//            Spacer()
//
//            if isLogged {
//                Image(systemName: "checkmark.circle.fill")
//                    .font(.system(size: 26))
//                    .foregroundColor(Color(red: 0.20, green: 0.78, blue: 0.35))
//            } else {
//                Button { pushMealId = entry.id } label: {
//                    Image(systemName: "plus.circle.fill")
//                        .font(.system(size: 26))
//                        .foregroundColor(.black)
//                }
//                .buttonStyle(.plain)
//            }
//        }
//        .padding(.horizontal, 16)
//        .padding(.vertical, 14)
//        .contentShape(Rectangle())
//        .onTapGesture { pushMealId = entry.id }
//    }
//
//    @ViewBuilder
//    private func compactMealRow(entry: MealEntry) -> some View {
//        HStack(spacing: 12) {
//            Circle()
//                .fill(entry.mealType.accentColor)
//                .frame(width: 10, height: 10)
//            Text(entry.mealType.displayName)
//                .font(.system(size: 15, weight: .medium))
//                .foregroundColor(.primary)
//            Spacer()
//            Button { pushMealId = entry.id } label: {
//                Image(systemName: "plus.circle.fill")
//                    .font(.system(size: 24))
//                    .foregroundColor(.black)
//            }
//            .buttonStyle(.plain)
//        }
//        .padding(.horizontal, 16)
//        .padding(.vertical, 11)
//        .contentShape(Rectangle())
//        .onTapGesture {
//            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
//                _ = expandedMeals.insert(entry.mealType)
//            }
//        }
//    }
//
//    // MARK: - Meal helpers
//
//    private func mealIcon(_ type: MealType) -> String {
//        switch type {
//        case .breakfast: return "cup.and.saucer.fill"
//        case .lunch:     return "fork.knife"
//        case .snack:     return "takeoutbag.and.cup.and.straw.fill"
//        case .dinner:    return "moon.fill"
//        }
//    }
//
//    private func mealTimeHint(_ type: MealType) -> String {
//        switch type {
//        case .breakfast: return "Recommended · 7:00 – 9:00 AM"
//        case .lunch:     return "Recommended · 12:00 – 2:00 PM"
//        case .snack:     return "Recommended · 4:00 – 5:00 PM"
//        case .dinner:    return "Recommended · 7:00 – 9:00 PM"
//        }
//    }
//
//    private func loggedTimeString(_ entry: MealEntry) -> String {
//        guard let loggedAt = entry.loggedAt else {
//            return "Logged · \(Int(entry.caloriesConsumed)) kcal"
//        }
//        let f = DateFormatter(); f.dateFormat = "h:mm a"
//        return "Logged at \(f.string(from: loggedAt)) · \(Int(entry.caloriesConsumed)) kcal"
//    }
//
//    // MARK: - Water Card
//
//    private var waterCardCompact: some View {
//        let today    = store.todaysTotalWaterML()
//        let target   = store.activeNutritionProfile?.waterTargetML ?? 2500
//        let progress = min(Double(today) / Double(max(target, 1)), 1.0)
//        let todayL   = String(format: "%.1f", today  / 1000)
//        let targetL  = String(format: "%.1f", target / 1000)
//
//        return VStack(alignment: .leading, spacing: 10) {
//            Button { showHydration = true } label: {
//                HStack {
//                    Text("Water Intake")
//                        .font(.system(size: 17, weight: .bold))
//                        .foregroundColor(.primary)
//                    Image(systemName: "chevron.right")
//                        .font(.system(size: 13, weight: .semibold))
//                        .foregroundColor(.secondary)
//                    Spacer()
//                    Text("\(todayL)/\(targetL)L")
//                        .font(.system(size: 15, weight: .semibold))
//                        .foregroundColor(.primary)
//                }
//            }
//            .buttonStyle(.plain)
//
//            GeometryReader { geo in
//                ZStack(alignment: .leading) {
//                    Capsule()
//                        .fill(Color(.systemGray5))
//                        .frame(height: 8)
//                    Capsule()
//                        .fill(LinearGradient(
//                            colors: [Color(red: 0.15, green: 0.55, blue: 0.95),
//                                     Color(red: 0.0,  green: 0.75, blue: 0.95)],
//                            startPoint: .leading, endPoint: .trailing))
//                        .frame(width: geo.size.width * CGFloat(progress), height: 8)
//                        .animation(.easeOut(duration: 0.4), value: today)
//                }
//            }
//            .frame(height: 8)
//
//            HStack(spacing: 10) {
//                ForEach([(150, "+ 150 ml"), (250, "+ 250 ml"), (500, "+ 500 ml")], id: \.0) { ml, label in
//                    Button {
//                        store.logWaterIntake(cupSize: "custom", amountML: Float(ml))
//                    } label: {
//                        Text(label)
//                            .font(.system(size: 13, weight: .medium))
//                            .foregroundColor(Color(red: 0.15, green: 0.45, blue: 0.85))
//                            .padding(.horizontal, 14)
//                            .padding(.vertical, 7)
//                            .background(Color(red: 0.15, green: 0.45, blue: 0.85).opacity(0.10))
//                            .clipShape(Capsule())
//                    }
//                    .buttonStyle(.plain)
//                }
//                Spacer()
//            }
//        }
//        .padding(16)
//        .background(Color.white)
//        .cornerRadius(18)
//    }
//
//    // MARK: - Daily Tip
//
//    private var dailyTipCard: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            Text("Daily Tips")
//                .font(.system(size: 20, weight: .bold))
//            HStack(spacing: 16) {
//                Image(systemName: "figure.walk")
//                    .font(.system(size: 24))
//                    .foregroundColor(Color(red: 0.55, green: 0.40, blue: 0.30))
//                Text("20 minutes walk improves blood flow to scalp.")
//                    .font(.system(size: 15, weight: .medium))
//                    .foregroundColor(.black)
//                Spacer()
//            }
//            .padding(16)
//            .background(Color(red: 0.96, green: 0.95, blue: 0.93))
//            .cornerRadius(18)
//        }
//    }
//}
//
//// MARK: - Reusable Ring
//
//struct CenterRingView: View {
//    let progress: CGFloat
//    let icon: String
//    let iconColor: Color
//    let trackColor: Color
//    let text: String
//
//    var body: some View {
//        ZStack {
//            Circle()
//                .stroke(trackColor.opacity(0.15), lineWidth: 14)
//            Circle()
//                .trim(from: 0, to: progress)
//                .stroke(trackColor, style: StrokeStyle(lineWidth: 14, lineCap: .round))
//                .rotationEffect(.degrees(-90))
//            VStack(spacing: 4) {
//                Image(systemName: icon)
//                    .font(.system(size: 18, weight: .semibold))
//                    .foregroundColor(iconColor)
//                Text(text)
//                    .font(.system(size: 10, weight: .bold))
//            }
//        }
//        .frame(width: 80, height: 80)
//        .frame(maxWidth: .infinity, alignment: .center)
//    }
//}

import SwiftUI

// ── Shared card height — change once to resize both hero cards together ───────
private let heroCardHeight: CGFloat = 218

struct HomeView: View {
    @Binding var selectedTab: Int

    @Environment(AppDataStore.self) private var store
    @State private var showCoach          = false
    @State private var heroPage           = 0
    @State private var pushHairProgress   = false
    @State private var showHydration      = false
    @State private var pushMealId: UUID?  = nil
    @State private var expandedMeals: Set<MealType> = []

    private var report:    ScanReport?           { store.latestScanReport }
    private var plan:      UserPlan?             { store.activePlan }
    private var nutrition: UserNutritionProfile? { store.activeNutritionProfile }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.hcCream.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        heroCardsSection
                        featureCardsSection
                        Color.clear.frame(height: 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(item: $pushMealId) { mealId in
                AddMealView(mealEntryId: mealId)
            }
            .navigationDestination(isPresented: $pushHairProgress) {
                HairProgressView()
                    .environment(store)
            }
        }
        .sheet(isPresented: $showHydration) {
            HydrationTrackerView()
                .environment(store)
        }
        .sheet(isPresented: $showCoach) {
            CoachView(viewModel: CoachViewModel())
        }
    }

    // MARK: - Hero Swipe Cards

    private var heroCardsSection: some View {
        VStack(spacing: 10) {
            TabView(selection: $heroPage) {
                aiCoachCard
                    .padding(.horizontal, 4)
                    .tag(0)

                hairHealthCard
                    .padding(.horizontal, 4)
                    .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: heroCardHeight)
            // ▼ Kills the default black TabView page-style background entirely
            .background(Color.hcCream)

            // Page dots
            HStack(spacing: 8) {
                ForEach(0..<2, id: \.self) { i in
                    Circle()
                        .fill(heroPage == i ? Color.hcBrown : Color(.systemGray4))
                        .frame(width: heroPage == i ? 10 : 7,
                               height: heroPage == i ? 10 : 7)
                        .animation(.easeInOut(duration: 0.2), value: heroPage)
                }
            }
        }
    }

    // MARK: - Card A — Hair Health

    private var hairHealthCard: some View {
        let density  = report?.hairDensityPercent ?? 52
        let stage    = report?.hairFallStage.intValue ?? plan?.stage ?? 2
        let progress = min(CGFloat(density) / 100.0, 1.0)

        let (severityLabel, severityColor): (String, Color) = {
            switch stage {
            case 1: return ("Healthy",  Color(red: 0.22, green: 0.78, blue: 0.45))
            case 2: return ("Moderate", Color(red: 1.00, green: 0.60, blue: 0.15))
            case 3: return ("Severe",   Color(red: 0.95, green: 0.32, blue: 0.22))
            default: return ("Critical", Color(red: 0.85, green: 0.15, blue: 0.15))
            }
        }()

        let ringColor: Color = {
            switch stage {
            case 1: return Color(red: 0.22, green: 0.88, blue: 0.52)
            case 2: return Color(red: 1.00, green: 0.62, blue: 0.18)
            case 3: return Color(red: 0.95, green: 0.38, blue: 0.22)
            default: return Color(red: 0.85, green: 0.20, blue: 0.20)
            }
        }()

        let scanSubtitle: String = report != nil ? "Last scan available" : "No scan yet — tap to scan"

        return VStack(spacing: 0) {

            // ── Gradient hero section ─────────────────────────────────────
            ZStack(alignment: .topLeading) {

                // Hair Health gradient: matches AI Coach #6c4c4d mauve tones
                LinearGradient(
                    stops: [
                        .init(color: Color(red: 0.424, green: 0.298, blue: 0.302), location: 0.0),
                        .init(color: Color(red: 0.298, green: 0.192, blue: 0.196), location: 1.0),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                // Ambient glow — cream #f3eed9 highlight
                RadialGradient(
                    colors: [Color(red: 0.953, green: 0.933, blue: 0.851).opacity(0.12), .clear],
                    center: .init(x: 0.78, y: 0.22),
                    startRadius: 10,
                    endRadius: 140
                )

                // Ambient glow — mauve echo
                RadialGradient(
                    colors: [Color(red: 0.424, green: 0.298, blue: 0.302).opacity(0.28), .clear],
                    center: .init(x: 0.15, y: 0.80),
                    startRadius: 5,
                    endRadius: 110
                )

                HStack(alignment: .center, spacing: 20) {

                    // Density ring
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.10), lineWidth: 11)
                            .frame(width: 96, height: 96)

                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(
                                AngularGradient(
                                    colors: [ringColor.opacity(0.6), ringColor, ringColor.opacity(0.85)],
                                    center: .center,
                                    startAngle: .degrees(-90),
                                    endAngle:   .degrees(270)
                                ),
                                style: StrokeStyle(lineWidth: 11, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .frame(width: 96, height: 96)
                            .animation(.easeOut(duration: 0.9), value: progress)

                        VStack(spacing: 1) {
                            Text("\(Int(density))%")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Text("DENSITY")
                                .font(.system(size: 8, weight: .semibold))
                                .foregroundColor(.white.opacity(0.55))
                                .kerning(1.2)
                        }
                    }

                    // Right text column
                    VStack(alignment: .leading, spacing: 10) {

                        HStack(spacing: 7) {
                            Text("Stage \(stage)")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(.white.opacity(0.18), in: Capsule())
                                .overlay(Capsule().stroke(.white.opacity(0.25), lineWidth: 0.5))

                            Text(severityLabel)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(severityColor)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(severityColor.opacity(0.18), in: Capsule())
                                .overlay(Capsule().stroke(severityColor.opacity(0.35), lineWidth: 0.5))
                        }

                        Text("Hair Health Score")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)

                        Text(scanSubtitle)
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.50))
                    }

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 22)
            }
            .frame(height: heroCardHeight - 50)
            .clipShape(UnevenRoundedRectangle(
                topLeadingRadius: 18, bottomLeadingRadius: 0,
                bottomTrailingRadius: 0, topTrailingRadius: 18
            ))

            // ── "View Hair Progress" native row ──────────────────────────
            Button { pushHairProgress = true } label: {
                HStack(spacing: 13) {
                    Image(systemName: "waveform.path.ecg")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color(red: 0.28, green: 0.14, blue: 0.08))
                        .frame(width: 26)

                    Text("View Hair Progress")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)

                    Spacer()

                    ZStack {
                        Circle()
                            .fill(Color(red: 0.18, green: 0.08, blue: 0.05))
                            .frame(width: 32, height: 32)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 18)
                .frame(height: 50)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .background(Color.white)
            .clipShape(UnevenRoundedRectangle(
                topLeadingRadius: 0, bottomLeadingRadius: 18,
                bottomTrailingRadius: 18, topTrailingRadius: 0
            ))
        }
        .frame(height: heroCardHeight)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: Color(red: 0.424, green: 0.298, blue: 0.302).opacity(0.20), radius: 12, x: 0, y: 4)
    }

    // MARK: - Card B — AI Coach

    private var aiCoachCard: some View {
        ZStack(alignment: .bottomLeading) {

            // Background gradient — warm mauve #6c4c4d tones
            LinearGradient(
                stops: [
                    .init(color: Color(red: 0.424, green: 0.298, blue: 0.302), location: 0.0),
                    .init(color: Color(red: 0.298, green: 0.192, blue: 0.196), location: 1.0),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Ambient glow — warm cream #f3eed9 highlight
            RadialGradient(
                colors: [Color(red: 0.953, green: 0.933, blue: 0.851).opacity(0.14), .clear],
                center: .init(x: 0.75, y: 0.25),
                startRadius: 10,
                endRadius: 160
            )

            // Ambient glow — mauve echo
            RadialGradient(
                colors: [Color(red: 0.424, green: 0.298, blue: 0.302).opacity(0.30), .clear],
                center: .init(x: 0.15, y: 0.80),
                startRadius: 5,
                endRadius: 120
            )

            HStack(alignment: .center, spacing: 0) {

                // Left text column
                VStack(alignment: .leading, spacing: 10) {
                    Spacer(minLength: 0)

                    HStack(spacing: 5) {
                        Circle()
                            .fill(Color(red: 0.953, green: 0.933, blue: 0.851))
                            .frame(width: 6, height: 6)
                        Text("AI POWERED")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color(red: 0.953, green: 0.933, blue: 0.851))
                            .kerning(1.3)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Hair Coach")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                        Text("Personalised answers,\nanytime you need.")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.55))
                            .lineSpacing(3)
                    }

                    Spacer(minLength: 0)

                    Button { showCoach = true } label: {
                        HStack(spacing: 7) {
                            Text("Start Session")
                                .font(.system(size: 14, weight: .semibold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundColor(Color(red: 0.298, green: 0.192, blue: 0.196))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(.white, in: Capsule())
                    }
                    .buttonStyle(.plain)

                    Spacer(minLength: 0)
                }
                .padding(.leading, 20)
                .padding(.vertical, 20)

                Spacer()

                // Right icon with glow rings
                ZStack {
                    Circle()
                        .stroke(Color(red: 0.953, green: 0.933, blue: 0.851).opacity(0.12), lineWidth: 1)
                        .frame(width: 100, height: 100)
                    Circle()
                        .stroke(Color(red: 0.953, green: 0.933, blue: 0.851).opacity(0.20), lineWidth: 1)
                        .frame(width: 76, height: 76)
                        .padding()
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.549, green: 0.373, blue: 0.376),
                                        Color(red: 0.380, green: 0.247, blue: 0.251),
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 58, height: 58)
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(Color(red: 0.953, green: 0.933, blue: 0.851))
                    }
                }
                .padding(.trailing, 22)
            }
        }
        .frame(height: heroCardHeight)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: Color(red: 0.424, green: 0.298, blue: 0.302).opacity(0.20), radius: 12, x: 0, y: 4)
    }

    // MARK: - Feature Cards

    private var featureCardsSection: some View {
        VStack(spacing: 20) {
            todaySection
            logMealsSection
            waterCardCompact
            dailyTipCard
        }
    }

    // MARK: - Today (fitness rings)

    private var todaySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today")
                .font(.system(size: 22, weight: .bold))
                .padding(.bottom, 2)

            HStack(alignment: .top, spacing: 12) {
                NavigationLink(destination: CaloriesDetailView().environment(store)) {
                    fitnessCard(
                        title: "Calories", icon: "flame.fill", iconColor: .orange,
                        gradientColors: [Color(red: 0.13, green: 0.09, blue: 0.07),
                                         Color(red: 0.22, green: 0.10, blue: 0.04)],
                        current: Double(store.todaysTotalCalories()),
                        target:  Double(store.activeNutritionProfile?.tdee ?? 1500),
                        ringColor: .orange, unitSuffix: "kcal"
                    )
                }
                .buttonStyle(.plain)

                NavigationLink(destination: MindfulDetailView().environment(store)) {
                    fitnessCard(
                        title: "MindEase", icon: "figure.mind.and.body",
                        iconColor: Color(red: 0.65, green: 0.55, blue: 1.0),
                        gradientColors: [Color(red: 0.18, green: 0.12, blue: 0.38),
                                         Color(red: 0.28, green: 0.18, blue: 0.55)],
                        current: Double(store.todaysMindfulMinutes()),
                        target:  Double(max(store.dailyMindfulTarget, 20)),
                        ringColor: Color(red: 0.40, green: 0.30, blue: 0.85),
                        unitSuffix: "min"
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func fitnessCard(
        title: String, icon: String, iconColor: Color,
        gradientColors: [Color], current: Double, target: Double,
        ringColor: Color, unitSuffix: String
    ) -> some View {
        let progress = min(current / max(target, 1), 1.0)
        let pct      = Int(progress * 100)
        return VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(iconColor)
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white.opacity(0.75))
                Spacer()
            }
            .padding(.bottom, 14)

            ZStack {
                Circle()
                    .stroke(ringColor.opacity(0.18), lineWidth: 10)
                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(ringColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.7), value: progress)
                VStack(spacing: 1) {
                    Text("\(pct)%")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    Text("of goal")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.white.opacity(0.55))
                }
            }
            .frame(width: 72, height: 72)
            .frame(maxWidth: .infinity)
            .padding(.bottom, 14)

            VStack(alignment: .leading, spacing: 2) {
                Text(current < 1000
                     ? "\(Int(current)) \(unitSuffix)"
                     : String(format: "%.0f \(unitSuffix)", current))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                Text("Goal \(Int(target)) \(unitSuffix)")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(colors: gradientColors,
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(18)
    }

    // MARK: - Log Meals — Apple Health "Today's Log" style

    private var logMealsSection: some View {
        VStack(alignment: .leading, spacing: 0) {

            Text("Today's Log")
                .font(.system(size: 20, weight: .bold))
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 12)

            Divider().padding(.horizontal, 16)

            let entries = store.todaysMealEntries()
                .sorted { $0.mealType.displayOrder < $1.mealType.displayOrder }

            VStack(spacing: 0) {
                ForEach(Array(entries.enumerated()), id: \.element.id) { idx, entry in
                    let isExpanded = entry.mealType == .breakfast
                                  || expandedMeals.contains(entry.mealType)
                                  || entry.caloriesConsumed > 0

                    if isExpanded {
                        expandedMealRow(entry: entry)
                    } else {
                        compactMealRow(entry: entry)
                    }

                    if idx < entries.count - 1 {
                        Divider().padding(.leading, isExpanded ? 68 : 52)
                    }
                }
            }
            .padding(.bottom, 4)
        }
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
    }

    @ViewBuilder
    private func expandedMealRow(entry: MealEntry) -> some View {
        let isLogged  = entry.caloriesConsumed > 0
        let timeHint  = mealTimeHint(entry.mealType)
        let loggedStr = loggedTimeString(entry)

        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(entry.mealType.accentColor)
                    .frame(width: 44, height: 44)
                Image(systemName: mealIcon(entry.mealType))
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(entry.mealType.displayName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                Text(isLogged ? loggedStr : timeHint)
                    .font(.system(size: 13))
                    .foregroundColor(isLogged ? Color(red: 0.20, green: 0.78, blue: 0.35) : .secondary)
            }

            Spacer()

            if isLogged {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 26))
                    .foregroundColor(Color(red: 0.20, green: 0.78, blue: 0.35))
            } else {
                Button { pushMealId = entry.id } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 26))
                        .foregroundColor(.hcBrown)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
        .onTapGesture { pushMealId = entry.id }
    }

    @ViewBuilder
    private func compactMealRow(entry: MealEntry) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(entry.mealType.accentColor)
                .frame(width: 10, height: 10)
            Text(entry.mealType.displayName)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.primary)
            Spacer()
            Button { pushMealId = entry.id } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.hcBrown)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 11)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                _ = expandedMeals.insert(entry.mealType)
            }
        }
    }

    // MARK: - Meal helpers

    private func mealIcon(_ type: MealType) -> String {
        switch type {
        case .breakfast: return "cup.and.saucer.fill"
        case .lunch:     return "fork.knife"
        case .snack:     return "takeoutbag.and.cup.and.straw.fill"
        case .dinner:    return "moon.fill"
        }
    }

    private func mealTimeHint(_ type: MealType) -> String {
        switch type {
        case .breakfast: return "Recommended · 7:00 – 9:00 AM"
        case .lunch:     return "Recommended · 12:00 – 2:00 PM"
        case .snack:     return "Recommended · 4:00 – 5:00 PM"
        case .dinner:    return "Recommended · 7:00 – 9:00 PM"
        }
    }

    private func loggedTimeString(_ entry: MealEntry) -> String {
        guard let loggedAt = entry.loggedAt else {
            return "Logged · \(Int(entry.caloriesConsumed)) kcal"
        }
        let f = DateFormatter(); f.dateFormat = "h:mm a"
        return "Logged at \(f.string(from: loggedAt)) · \(Int(entry.caloriesConsumed)) kcal"
    }

    // MARK: - Water Card

    private var waterCardCompact: some View {
        let today    = store.todaysTotalWaterML()
        let target   = store.activeNutritionProfile?.waterTargetML ?? 2500
        let progress = min(Double(today) / Double(max(target, 1)), 1.0)
        let todayL   = String(format: "%.1f", today  / 1000)
        let targetL  = String(format: "%.1f", target / 1000)

        return VStack(alignment: .leading, spacing: 10) {
            Button { showHydration = true } label: {
                HStack {
                    Text("Water Intake")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.primary)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(todayL)/\(targetL)L")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                }
            }
            .buttonStyle(.plain)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                    Capsule()
                        .fill(LinearGradient(
                            colors: [Color(red: 0.15, green: 0.55, blue: 0.95),
                                     Color(red: 0.0,  green: 0.75, blue: 0.95)],
                            startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * CGFloat(progress), height: 8)
                        .animation(.easeOut(duration: 0.4), value: today)
                }
            }
            .frame(height: 8)

            HStack(spacing: 10) {
                ForEach([(150, "+ 150 ml"), (250, "+ 250 ml"), (500, "+ 500 ml")], id: \.0) { ml, label in
                    Button {
                        store.logWaterIntake(cupSize: "custom", amountML: Float(ml))
                    } label: {
                        Text(label)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(red: 0.15, green: 0.45, blue: 0.85))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(Color(red: 0.15, green: 0.45, blue: 0.85).opacity(0.10))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(18)
    }

    // MARK: - Daily Tip

    private var dailyTipCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily Tips")
                .font(.system(size: 20, weight: .bold))
            HStack(spacing: 16) {
                Image(systemName: "figure.walk")
                    .font(.system(size: 24))
                    .foregroundColor(Color(red: 0.55, green: 0.40, blue: 0.30))
                Text("20 minutes walk improves blood flow to scalp.")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.black)
                Spacer()
            }
            .padding(16)
            .background(Color(red: 0.96, green: 0.95, blue: 0.93))
            .cornerRadius(18)
        }
    }
}

// MARK: - Reusable Ring

struct CenterRingView: View {
    let progress: CGFloat
    let icon: String
    let iconColor: Color
    let trackColor: Color
    let text: String

    var body: some View {
        ZStack {
            Circle()
                .stroke(trackColor.opacity(0.15), lineWidth: 14)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(trackColor, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                .rotationEffect(.degrees(-90))
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(iconColor)
                Text(text)
                    .font(.system(size: 10, weight: .bold))
            }
        }
        .frame(width: 80, height: 80)
        .frame(maxWidth: .infinity, alignment: .center)
    }
}
