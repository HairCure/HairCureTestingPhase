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

    // Sleep state
    @State private var showSleepSheet = false
    @State private var sleepTime      = Calendar.current.date(
        bySettingHour: 23, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var wakeTime       = Calendar.current.date(
        bySettingHour: 7,  minute: 0, second: 0, of: Date()) ?? Date()

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
        .sheet(isPresented: $showSleepSheet) {
            SleepSettingsSheet(sleepTime: $sleepTime, wakeTime: $wakeTime)
                .presentationDetents([.medium])
                .presentationCornerRadius(28)
                .presentationDragIndicator(.visible)
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

                LinearGradient(
                    stops: [
                        .init(color: Color(red: 0.424, green: 0.298, blue: 0.302), location: 0.0),
                        .init(color: Color(red: 0.298, green: 0.192, blue: 0.196), location: 1.0),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                RadialGradient(
                    colors: [Color(red: 0.953, green: 0.933, blue: 0.851).opacity(0.12), .clear],
                    center: .init(x: 0.78, y: 0.22),
                    startRadius: 10,
                    endRadius: 140
                )

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

//    private var aiCoachCard: some View {
//        ZStack(alignment: .bottomLeading) {
//
//            LinearGradient(
//                stops: [
//                    .init(color: Color(red: 0.424, green: 0.298, blue: 0.302), location: 0.0),
//                    .init(color: Color(red: 0.298, green: 0.192, blue: 0.196), location: 1.0),
//                ],
//                startPoint: .topLeading,
//                endPoint: .bottomTrailing
//            )
//
//            RadialGradient(
//                colors: [Color(red: 0.953, green: 0.933, blue: 0.851).opacity(0.14), .clear],
//                center: .init(x: 0.75, y: 0.25),
//                startRadius: 10,
//                endRadius: 160
//            )
//
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

    private var aiCoachCard: some View {
        VStack(spacing: 0) {

            // ── Gradient hero section ─────────────────────────────────────
            ZStack(alignment: .topLeading) {

                LinearGradient(
                    stops: [
                        .init(color: Color(red: 0.424, green: 0.298, blue: 0.302), location: 0.0),
                        .init(color: Color(red: 0.298, green: 0.192, blue: 0.196), location: 1.0),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                RadialGradient(
                    colors: [Color(red: 0.953, green: 0.933, blue: 0.851).opacity(0.14), .clear],
                    center: .init(x: 0.75, y: 0.25),
                    startRadius: 10,
                    endRadius: 160
                )

                RadialGradient(
                    colors: [Color(red: 0.424, green: 0.298, blue: 0.302).opacity(0.30), .clear],
                    center: .init(x: 0.15, y: 0.80),
                    startRadius: 5,
                    endRadius: 120
                )

                HStack(alignment: .center, spacing: 20) {

                    // Right icon with glow rings
                    ZStack {
                        Circle()
                            .stroke(Color(red: 0.953, green: 0.933, blue: 0.851).opacity(0.12), lineWidth: 1)
                            .frame(width: 96, height: 96)
                        Circle()
                            .stroke(Color(red: 0.953, green: 0.933, blue: 0.851).opacity(0.20), lineWidth: 1)
                            .frame(width: 72, height: 72)
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

                    // Text column
                    VStack(alignment: .leading, spacing: 10) {

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
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            Text("Personalised answers,\nanytime you need.")
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.50))
                                .lineSpacing(3)
                        }
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

            // ── "Start Session" native row ────────────────────────────────
            Button { showCoach = true } label: {
                HStack(spacing: 13) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color(red: 0.28, green: 0.14, blue: 0.08))
                        .frame(width: 26)

                    Text("Start Session")
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
    // MARK: - Feature Cards

    private var featureCardsSection: some View {
        VStack(spacing: 20) {
            todaySection
            logMealsSection
            waterCardCompact
            sleepCardCompact
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
//                NavigationLink(destination: CaloriesDetailView().environment(store)) {
                    fitnessCard(
                        title: "Calories", icon: "flame.fill",
                        iconColor: Color(red: 0.90, green: 0.50, blue: 0.15),
                        gradientColors: [Color(red: 1.0,  green: 0.90, blue: 0.78),
                                         Color(red: 0.98, green: 0.82, blue: 0.65)],
                        current: Double(store.todaysTotalCalories()),
                        target:  Double(store.activeNutritionProfile?.tdee ?? 1500),
                        ringColor: Color(red: 0.93, green: 0.55, blue: 0.20),
                        unitSuffix: "kcal",
                        darkText: true
                    )
//                }
                .buttonStyle(.plain)

//                NavigationLink(destination: MindfulDetailView().environment(store)) {
                    fitnessCard(
                        title: "MindEase", icon: "figure.mind.and.body",
                        iconColor: Color(red: 0.58, green: 0.48, blue: 0.92),
                        gradientColors: [Color(red: 0.90, green: 0.87, blue: 1.0),
                                         Color(red: 0.82, green: 0.78, blue: 0.98)],
                        current: Double(store.todaysMindfulMinutes()),
                        target:  Double(max(store.dailyMindfulTarget, 20)),
                        ringColor: Color(red: 0.50, green: 0.38, blue: 0.85),
                        unitSuffix: "min",
                        darkText: true
                    )
//                }
                .buttonStyle(.plain)
            }
        }
    }

    private func fitnessCard(
        title: String, icon: String, iconColor: Color,
        gradientColors: [Color], current: Double, target: Double,
        ringColor: Color, unitSuffix: String, darkText: Bool = false
    ) -> some View {
        let progress = min(current / max(target, 1), 1.0)
        let pct      = Int(progress * 100)
        let textPrimary   = darkText ? Color(red: 0.15, green: 0.12, blue: 0.10) : Color.white
        let textSecondary = darkText ? Color(red: 0.35, green: 0.30, blue: 0.25) : Color.white.opacity(0.55)
        let titleOpacity  = darkText ? Color(red: 0.30, green: 0.25, blue: 0.20) : Color.white.opacity(0.75)
        return VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(iconColor)
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(titleOpacity)
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
                        .foregroundColor(textPrimary)
                    Text("of goal")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(textSecondary)
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
                    .foregroundColor(textPrimary)
                Text("Goal \(Int(target)) \(unitSuffix)")
                    .font(.system(size: 11))
                    .foregroundColor(textSecondary)
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
        case .breakfast: return "Recommended time : 7:00 – 9:00 AM"
        case .lunch:     return "Recommended time : 12:00 – 2:00 PM"
        case .snack:     return "Recommended time : 4:00 – 5:00 PM"
        case .dinner:    return "Recommended time : 7:00 – 9:00 PM"
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

    // MARK: - Sleep Card

    private var sleepCardCompact: some View {
        let calendar   = Calendar.current
        let sleepComps = calendar.dateComponents([.hour, .minute], from: sleepTime)
        let wakeComps  = calendar.dateComponents([.hour, .minute], from: wakeTime)

        let sleepMinutes = (sleepComps.hour ?? 23) * 60 + (sleepComps.minute ?? 0)
        var wakeMinutes  = (wakeComps.hour  ??  7) * 60 + (wakeComps.minute  ?? 0)
        if wakeMinutes <= sleepMinutes { wakeMinutes += 24 * 60 }
        let durationMin  = wakeMinutes - sleepMinutes
        let hours        = durationMin / 60
        let mins         = durationMin % 60

        let durationText = mins == 0 ? "\(hours)h sleep" : "\(hours)h \(mins)m sleep"

        // Arc progress — 8 h = 100 %
        let progress = min(Double(durationMin) / (8.0 * 60.0), 1.0)

//        let arcColor: Color = hours >= 7
//            ? Color(red: 0.24, green: 0.58, blue: 0.98)
//            : hours >= 5
//                ? Color(red: 0.95, green: 0.65, blue: 0.15)
//                : Color(red: 0.90, green: 0.30, blue: 0.28)
        
        let arcColor: Color = hours >= 7
            ? Color(red: 0.52, green: 0.38, blue: 0.88)   // soft purple
            : hours >= 5
                ? Color(red: 0.95, green: 0.65, blue: 0.15)
                : Color(red: 0.90, green: 0.30, blue: 0.28)

        return Button { showSleepSheet = true } label: {
            VStack(alignment: .leading, spacing: 14) {

                // Header row
                HStack(alignment: .center) {
                    Text("Sleep")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.primary)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(durationText)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(arcColor)
                }

                // Arc + time labels row
                HStack(spacing: 24) {

                    // Sleep arc
                    ZStack {
                        // Track arc
                        Circle()
                            .trim(from: 0.62, to: 1.0)
                            .stroke(
                                Color(.systemGray5),
                                style: StrokeStyle(lineWidth: 10, lineCap: .round)
                            )
                            .rotationEffect(.degrees(162))
                            .frame(width: 84, height: 84)

                        // Fill arc
                        Circle()
                            .trim(from: 0.62, to: 0.62 + 0.38 * progress)
                            .stroke(
                                LinearGradient(
                                    colors: [arcColor.opacity(0.65), arcColor],
                                    startPoint: .leading, endPoint: .trailing
                                ),
                                style: StrokeStyle(lineWidth: 10, lineCap: .round)
                            )
                            .rotationEffect(.degrees(162))
                            .frame(width: 84, height: 84)
                            .animation(.easeOut(duration: 0.6), value: progress)

                        // Centre icon
                        Image(systemName: "moon.zzz.fill")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [arcColor.opacity(0.75), arcColor],
                                    startPoint: .top, endPoint: .bottom
                                )
                            )
                    }

                    // Bedtime / Wake time column
                    VStack(alignment: .leading, spacing: 12) {
                        sleepTimeRow(
                            icon: "bed.double.fill",
                            label: "Bedtime",
                            time: sleepTime,
                            color: Color(red: 0.42, green: 0.30, blue: 0.80)
                        )
                        Divider()
                        sleepTimeRow(
                            icon: "alarm.fill",
                            label: "Wake Up",
                            time: wakeTime,
                            color: Color(red: 0.52, green: 0.38, blue: 0.88)  // purple
                        )
                    }

                    Spacer(minLength: 0)
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(18)
            .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }

    private func sleepTimeRow(
        icon: String, label: String, time: Date, color: Color
    ) -> some View {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                Text(f.string(from: time))
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.primary)
            }
        }
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

// MARK: - Sleep Settings Sheet
// MARK: - Sleep Settings Sheet

//struct SleepSettingsSheet: View {
//    @Binding var sleepTime: Date
//    @Binding var wakeTime:  Date
//    @Environment(\.dismiss) private var dismiss
//
//    // Apple Health sleep history — last 7 days
//    // Each entry: (date label, hours slept)
//    @State private var sleepHistory: [(String, Double)] = []
//
//    // Apple Health water history — last 7 days
//    // Each entry: (date label, ml consumed)
//    @State private var waterHistory: [(String, Double)] = []
//
//    var body: some View {
//        NavigationStack {
//            List {
//                // ── Duration banner ───────────────────────────────────────
//                Section {
//                    durationBanner
//                        .listRowInsets(EdgeInsets())
//                        .listRowBackground(Color.clear)
//                }
//
//                // ── Schedule pickers ──────────────────────────────────────
//                Section {
//                    pickerRow(
//                        icon: "bed.double.fill",
//                        iconColor: Color(red: 0.42, green: 0.30, blue: 0.80),
//                        label: "Bedtime",
//                        selection: $sleepTime
//                    )
//                    pickerRow(
//                        icon: "alarm.fill",
//                        iconColor: Color(red: 0.52, green: 0.38, blue: 0.88),
//                        label: "Wake Up",
//                        selection: $wakeTime
//                    )
//                } header: {
//                    Text("Schedule")
//                } footer: {
//                    Text("Aim for 7–9 hours for optimal hair and scalp health.")
//                        .font(.footnote)
//                }
//
//                // ── Sleep history (Apple Health) ──────────────────────────
//                Section {
//                    if sleepHistory.isEmpty {
//                        healthUnavailableRow(icon: "bed.double.fill",
//                                             color: Color(red: 0.42, green: 0.30, blue: 0.80),
//                                             message: "No Apple Health sleep data found.")
//                    } else {
//                        ForEach(sleepHistory, id: \.0) { day, hours in
//                            sleepHistoryRow(day: day, hours: hours)
//                        }
//                    }
//                } header: {
//                    healthSourceHeader(icon: "bed.double.fill",
//                                       color: Color(red: 0.42, green: 0.30, blue: 0.80),
//                                       title: "Sleep history")
//                }
//
//                // ── Water history (Apple Health) ──────────────────────────
//                Section {
//                    if waterHistory.isEmpty {
//                        healthUnavailableRow(icon: "drop.fill",
//                                             color: Color(red: 0.15, green: 0.45, blue: 0.85),
//                                             message: "No Apple Health water data found.")
//                    } else {
//                        ForEach(waterHistory, id: \.0) { day, ml in
//                            waterHistoryRow(day: day, ml: ml)
//                        }
//                    }
//                } header: {
//                    healthSourceHeader(icon: "drop.fill",
//                                       color: Color(red: 0.15, green: 0.45, blue: 0.85),
//                                       title: "Water history")
//                }
//            }
//            .listStyle(.insetGrouped)
//            .background(Color(.systemGroupedBackground).ignoresSafeArea())
//            .navigationTitle("Sleep & Hydration")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .confirmationAction) {
//                    Button("Done") { dismiss() }
//                        .fontWeight(.semibold)
//                }
//            }
//            .onAppear {
//                loadHealthData()
//            }
//        }
//    }
//
//    // MARK: - Apple Health loader
//
//    private func loadHealthData() {
//        let store   = HKHealthStore()
//        let cal     = Calendar.current
//        let today   = cal.startOfDay(for: Date())
//        let labels  = (0..<7).reversed().map { offset -> String in
//            let d = cal.date(byAdding: .day, value: -offset, to: today)!
//            if cal.isDateInToday(d)      { return "Today" }
//            if cal.isDateInYesterday(d)  { return "Yesterday" }
//            let f = DateFormatter(); f.dateFormat = "EEE d"
//            return f.string(from: d)
//        }
//
//        // ── Sleep ─────────────────────────────────────────────────────────
//        guard HKHealthStore.isHealthDataAvailable() else { return }
//
//        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
//        let waterType = HKObjectType.quantityType(forIdentifier: .dietaryWater)!
//
//        store.requestAuthorization(toShare: nil,
//                                   read: [sleepType, waterType]) { granted, _ in
//            guard granted else { return }
//
//            // Sleep: sum asleep minutes per day for last 7 days
//            let sevenDaysAgo = cal.date(byAdding: .day, value: -6, to: today)!
//            let sleepPred = HKQuery.predicateForSamples(
//                withStart: sevenDaysAgo, end: Date())
//
//            let sleepQuery = HKSampleQuery(
//                sampleType: sleepType,
//                predicate: sleepPred,
//                limit: HKObjectQueryNoLimit,
//                sortDescriptors: nil
//            ) { _, samples, _ in
//                var minutesByDay: [String: Double] = [:]
//                (samples as? [HKCategorySample])?.forEach { s in
//                    guard s.value == HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue
//                       || s.value == HKCategoryValueSleepAnalysis.asleepCore.rawValue
//                       || s.value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue
//                       || s.value == HKCategoryValueSleepAnalysis.asleepREM.rawValue
//                    else { return }
//                    let dayStart = cal.startOfDay(for: s.startDate)
//                    let offset   = cal.dateComponents([.day], from: today, to: dayStart).day ?? 0
//                    let idx      = 6 + offset          // 0–6 index into labels
//                    guard idx >= 0, idx < 7 else { return }
//                    let mins = s.endDate.timeIntervalSince(s.startDate) / 60
//                    minutesByDay[labels[idx], default: 0] += mins
//                }
//                let history = labels.map { ($0, (minutesByDay[$0] ?? 0) / 60) }
//                DispatchQueue.main.async { sleepHistory = history }
//            }
//            store.execute(sleepQuery)
//
//            // Water: sum ml per day for last 7 days
//            let waterPred = HKQuery.predicateForSamples(
//                withStart: sevenDaysAgo, end: Date())
//
//            let waterQuery = HKStatisticsCollectionQuery(
//                quantityType: waterType,
//                quantitySamplePredicate: waterPred,
//                options: .cumulativeSum,
//                anchorDate: today,
//                intervalComponents: DateComponents(day: 1)
//            )
//            waterQuery.initialResultsHandler = { _, results, _ in
//                var mlByDay: [String: Double] = [:]
//                results?.enumerateStatistics(from: sevenDaysAgo, to: Date()) { stats, _ in
//                    let dayStart = cal.startOfDay(for: stats.startDate)
//                    let offset   = cal.dateComponents([.day], from: today, to: dayStart).day ?? 0
//                    let idx      = 6 + offset
//                    guard idx >= 0, idx < 7 else { return }
//                    let ml = stats.sumQuantity()?.doubleValue(for: .literUnit(with: .milli)) ?? 0
//                    mlByDay[labels[idx]] = ml
//                }
//                let history = labels.map { ($0, mlByDay[$0] ?? 0) }
//                DispatchQueue.main.async { waterHistory = history }
//            }
//            store.execute(waterQuery)
//        }
//    }
//
//    // MARK: - Row builders
//
//    private func sleepHistoryRow(day: String, hours: Double) -> some View {
//        let h   = Int(hours)
//        let m   = Int((hours - Double(h)) * 60)
//        let txt = hours < 0.1 ? "—"
//                : m == 0     ? "\(h) hr"
//                :              "\(h) hr \(m) min"
//
//        let barColor: Color = h >= 7
//            ? Color(red: 0.42, green: 0.30, blue: 0.80)
//            : h >= 5
//                ? Color(red: 0.95, green: 0.65, blue: 0.15)
//                : Color(red: 0.90, green: 0.30, blue: 0.28)
//
//        let progress = min(hours / 9.0, 1.0)   // 9 h = full bar
//
//        return HStack(spacing: 12) {
//            Text(day)
//                .font(.system(size: 14))
//                .foregroundColor(.secondary)
//                .frame(width: 72, alignment: .leading)
//
//            GeometryReader { geo in
//                ZStack(alignment: .leading) {
//                    Capsule()
//                        .fill(Color(.systemGray5))
//                        .frame(height: 6)
//                    Capsule()
//                        .fill(barColor)
//                        .frame(width: geo.size.width * CGFloat(progress), height: 6)
//                }
//                .frame(maxHeight: .infinity, alignment: .center)
//            }
//            .frame(height: 20)
//
//            Text(txt)
//                .font(.system(size: 14, weight: .semibold))
//                .foregroundColor(hours < 0.1 ? .secondary : .primary)
//                .frame(width: 72, alignment: .trailing)
//        }
//        .padding(.vertical, 4)
//    }
//
//    private func waterHistoryRow(day: String, ml: Double) -> some View {
//        let target: Double = 2500
//        let progress = min(ml / target, 1.0)
//        let txt  = ml < 1 ? "—" : ml >= 1000
//            ? String(format: "%.1f L", ml / 1000)
//            : "\(Int(ml)) ml"
//
//        let barColor = Color(red: 0.15, green: 0.45, blue: 0.85)
//
//        return HStack(spacing: 12) {
//            Text(day)
//                .font(.system(size: 14))
//                .foregroundColor(.secondary)
//                .frame(width: 72, alignment: .leading)
//
//            GeometryReader { geo in
//                ZStack(alignment: .leading) {
//                    Capsule()
//                        .fill(Color(.systemGray5))
//                        .frame(height: 6)
//                    Capsule()
//                        .fill(barColor)
//                        .frame(width: geo.size.width * CGFloat(progress), height: 6)
//                }
//                .frame(maxHeight: .infinity, alignment: .center)
//            }
//            .frame(height: 20)
//
//            Text(txt)
//                .font(.system(size: 14, weight: .semibold))
//                .foregroundColor(ml < 1 ? .secondary : .primary)
//                .frame(width: 72, alignment: .trailing)
//        }
//        .padding(.vertical, 4)
//    }
//
//    private func healthUnavailableRow(icon: String, color: Color, message: String) -> some View {
//        HStack(spacing: 10) {
//            Image(systemName: icon)
//                .font(.system(size: 14))
//                .foregroundColor(color)
//            Text(message)
//                .font(.system(size: 14))
//                .foregroundColor(.secondary)
//        }
//        .padding(.vertical, 4)
//    }
//
//    private func healthSourceHeader(icon: String, color: Color, title: String) -> some View {
//        HStack(spacing: 5) {
//            Image(systemName: icon)
//                .font(.system(size: 11))
//                .foregroundColor(color)
//            Text(title)
//            Text("· Apple Health")
//                .foregroundColor(.secondary)
//        }
//    }
//
//    // MARK: - Duration banner
//
//    private var durationBanner: some View {
//        let calendar = Calendar.current
//        let sc = calendar.dateComponents([.hour, .minute], from: sleepTime)
//        let wc = calendar.dateComponents([.hour, .minute], from: wakeTime)
//        var sm = (sc.hour ?? 23) * 60 + (sc.minute ?? 0)
//        var wm = (wc.hour  ??  7) * 60 + (wc.minute  ?? 0)
//        if wm <= sm { wm += 24 * 60 }
//        let dur  = wm - sm
//        let h    = dur / 60
//        let m    = dur % 60
//        let txt  = m == 0 ? "\(h) hr" : "\(h) hr \(m) min"
//        let good = h >= 7
//
//        let bannerColor: Color = good
//            ? Color(red: 0.20, green: 0.78, blue: 0.35)
//            : Color(red: 0.95, green: 0.55, blue: 0.10)
//
//        return HStack(spacing: 10) {
//            Image(systemName: good ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
//                .font(.system(size: 18, weight: .semibold))
//                .foregroundColor(bannerColor)
//            VStack(alignment: .leading, spacing: 2) {
//                Text("\(txt) of sleep scheduled")
//                    .font(.system(size: 15, weight: .semibold))
//                    .foregroundColor(.primary)
//                Text(good ? "Great! You're hitting your goal." : "Try to get at least 7 hours.")
//                    .font(.system(size: 12))
//                    .foregroundColor(.secondary)
//            }
//            Spacer()
//        }
//        .padding(14)
//        .background(
//            bannerColor.opacity(0.10),
//            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
//        )
//        .overlay(
//            RoundedRectangle(cornerRadius: 14, style: .continuous)
//                .stroke(bannerColor.opacity(0.20), lineWidth: 1)
//        )
//        .padding(.vertical, 8)
//        .padding(.horizontal, 4)
//    }
//
//    // MARK: - Picker row
//
//    private func pickerRow(
//        icon: String, iconColor: Color,
//        label: String, selection: Binding<Date>
//    ) -> some View {
//        HStack {
//            Label {
//                Text(label).font(.system(size: 16, weight: .medium))
//            } icon: {
//                Image(systemName: icon).foregroundColor(iconColor)
//            }
//            Spacer()
//            DatePicker("", selection: selection, displayedComponents: .hourAndMinute)
//                .labelsHidden()
//                .datePickerStyle(.compact)
//        }
//    }
//}
struct SleepSettingsSheet: View {
    @Binding var sleepTime: Date
    @Binding var wakeTime:  Date
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                durationBanner
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 4)

                List {
                    Section {
                        pickerRow(
                            icon: "bed.double.fill",
                            iconColor: Color(red: 0.42, green: 0.30, blue: 0.80),
                            label: "Bedtime",
                            selection: $sleepTime
                        )
                        pickerRow(
                            icon: "alarm.fill",
                            iconColor: Color(red: 0.52, green: 0.38, blue: 0.88),
                            label: "Wake Up",
                            selection: $wakeTime
                        )

                    } header: {
                        Text("Schedule")
                    } footer: {
                        Text("Aim for 7–9 hours for optimal hair and scalp health.")
                            .font(.footnote)
                    }
                }
                .listStyle(.insetGrouped)
                .scrollDisabled(true)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Sleep")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
    }

    // MARK: Duration banner

    private var durationBanner: some View {
        let calendar = Calendar.current
        let sc = calendar.dateComponents([.hour, .minute], from: sleepTime)
        let wc = calendar.dateComponents([.hour, .minute], from: wakeTime)
        var sm = (sc.hour ?? 23) * 60 + (sc.minute ?? 0)
        var wm = (wc.hour  ??  7) * 60 + (wc.minute  ?? 0)
        if wm <= sm { wm += 24 * 60 }
        let dur  = wm - sm
        let h    = dur / 60
        let m    = dur % 60
        let txt  = m == 0 ? "\(h) hr" : "\(h) hr \(m) min"
        let good = h >= 7

        let bannerColor: Color = good
            ? Color(red: 0.20, green: 0.78, blue: 0.35)
            : Color(red: 0.95, green: 0.55, blue: 0.10)

        return HStack(spacing: 10) {
            Image(systemName: good ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(bannerColor)
            VStack(alignment: .leading, spacing: 2) {
                Text("\(txt) of sleep scheduled")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                Text(good ? "Great! You're hitting your goal." : "Try to get at least 7 hours.")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(14)
        .background(
            bannerColor.opacity(0.10),
            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(bannerColor.opacity(0.20), lineWidth: 1)
        )
    }

    // MARK: Picker row

    private func pickerRow(
        icon: String,
        iconColor: Color,
        label: String,
        selection: Binding<Date>
    ) -> some View {
        HStack {
            Label {
                Text(label)
                    .font(.system(size: 16, weight: .medium))
            } icon: {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
            }
            Spacer()
            DatePicker(
                "",
                selection: selection,
                displayedComponents: .hourAndMinute
            )
            .labelsHidden()
            .datePickerStyle(.compact)
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
