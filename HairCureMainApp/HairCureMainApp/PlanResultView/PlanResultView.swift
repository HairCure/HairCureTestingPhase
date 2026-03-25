//
//
//import SwiftUI
//
//struct PlanResultsView: View {
//    let onStart: () -> Void
//
//    @Environment(AppDataStore.self) private var store
//
//    @State private var cardPage    = 0      // 0 = analysis, 1 = lifestyle
//    @State private var animateBars = false
//
//    private var report:    ScanReport?           { store.latestScanReport }
//    private var plan:      UserPlan?             { store.activePlan }
//    private var nutrition: UserNutritionProfile? { store.activeNutritionProfile }
//
//    // Density → fixed thresholds
//    private func densityLabel(_ pct: Float) -> String {
//        switch pct {
//        case 80...100: return "High (\(Int(pct))%)"
//        case 60..<80:  return "Medium (\(Int(pct))%)"
//        case 40..<60:  return "Low (\(Int(pct))%)"
//        default:       return "Very Low (\(Int(pct))%)"
//        }
//    }
//    private func densityColor(_ pct: Float) -> Color {
//        switch pct {
//        case 80...100: return .green
//        case 60..<80:  return .orange
//        case 40..<60:  return Color(red: 0.85, green: 0.45, blue: 0.1)
//        default:       return .red
//        }
//    }
//
//    var body: some View {
//        ZStack(alignment: .bottom) {
//            Color.hcCream.ignoresSafeArea()
//
//            ScrollView(showsIndicators: false) {
//                VStack(spacing: 0) {
//                    navBar
//                        .padding(.bottom, 20)
//
//                    scanPhotoRow
//                        .padding(.horizontal, 20)
//                        .padding(.bottom, 20)
//
//                    swipeableCards
//                        .padding(.bottom, 20)
//
//                    planBadgeCard
//                        .padding(.horizontal, 20)
//                        .padding(.bottom, 20)
//
//                    recommendedPlanSection
//                        .padding(.horizontal, 20)
//                        .padding(.bottom, 20)
//
//                    dailyTargetsSection
//                        .padding(.horizontal, 20)
//                        .padding(.bottom, 110)
//                }
//                .padding(.top, 12)
//            }
//
//            ctaButton
//        }
//        .onAppear {
//            withAnimation(.easeOut(duration: 0.85).delay(0.3)) {
//                animateBars = true
//            }
//        }
//    }
//
//    // ─────────────────────────────────────
//    // MARK: 1 — Nav Bar
//    // ─────────────────────────────────────
//
//    private var navBar: some View {
//        HStack {
//            HCBackButton { onStart() }
//            Spacer()
//            Text("Scan Report")
//                .font(.system(size: 20, weight: .bold))
//                .foregroundColor(.primary)
//            Spacer()
//            Color.clear.frame(width: 40, height: 40)
//        }
//        .padding(.horizontal, 16)
//    }
//
//    // ─────────────────────────────────────
//    // MARK: 2 — Scan Photo Row
//    // ─────────────────────────────────────
//
//    private var scanPhotoRow: some View {
//        // Mock timestamps — in production read from ScalpScan.scanDate
//        let times = ["12 : 35 PM", "12 : 40 PM", "12 : 45 PM"]
//
//        return HStack(spacing: 12) {
//            ForEach(0..<3, id: \.self) { i in
//                VStack(spacing: 6) {
//                    RoundedRectangle(cornerRadius: 14)
//                        .fill(Color(.systemGray5))
//                        .frame(height: 95)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 14)
//                                .stroke(
//                                    style: StrokeStyle(lineWidth: 1.5, dash: [5, 4])
//                                )
//                                .foregroundColor(Color(.systemGray4))
//                        )
//                        .overlay(
//                            Image(systemName: "camera")
//                                .font(.system(size: 22))
//                                .foregroundColor(Color(.systemGray3))
//                        )
//                    Text(times[i])
//                        .font(.system(size: 11))
//                        .foregroundColor(.secondary)
//                }
//                .frame(maxWidth: .infinity)
//            }
//        }
//    }
//
//    // ─────────────────────────────────────
//    // MARK: 3 — Horizontal Paging Cards
//    // ─────────────────────────────────────
//
//    private var swipeableCards: some View {
//        VStack(spacing: 12) {
//            TabView(selection: $cardPage) {
//                hairAnalysisCard.tag(1)
//                lifestyleScoresCard.tag(0)
//            }
//            .tabViewStyle(.page(indexDisplayMode: .never))
//            .frame(height: 190)
//
//            // Page dots
//            HStack(spacing: 8) {
//                ForEach(0..<2, id: \.self) { i in
//                    Circle()
//                        .fill(cardPage == i ? Color.hcBrown : Color(.systemGray4))
//                        .frame(width: cardPage == i ? 10 : 8,
//                               height: cardPage == i ? 10 : 8)
//                        .animation(.easeInOut(duration: 0.2), value: cardPage)
//                }
//            }
//        }
//        .padding(.horizontal, 20)
//    }
//
//    // Card A — Hair Analysis Results
//    private var hairAnalysisCard: some View {
//        let density  = report?.hairDensityPercent ?? 52
//        let stage    = report?.hairFallStage.intValue ?? plan?.stage ?? 2
//        let scalp    = report?.scalpCondition ?? plan?.scalpModifier ?? .dry
//
//        return VStack(alignment: .leading, spacing: 0) {
//            Text("Your Hair Analysis Results")
//                .font(.system(size: 16, weight: .bold))
//                .foregroundColor(.primary)
//                .padding(.bottom, 10)
//
//            Divider().padding(.bottom, 14)
//
//            resultRow(label: "Hair Density",
//                      value: "\(Int(density))%",
//                      color: densityColor(density))
//            resultRow(label: "Growth Stage",
//                      value: "Stage \(stage)",
//                      color: stageColor(stage))
//            resultRow(label: "Scalp Condition",
//                      value: scalpLabel(scalp),
//                      color: Color(red: 0.2, green: 0.55, blue: 0.9))
//        }
//        .padding(20)
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .background(Color.white)
//        .cornerRadius(18)
//    }
//
//    private func resultRow(label: String, value: String, color: Color) -> some View {
//        HStack {
//            Text(label)
//                .font(.system(size: 15))
//                .foregroundColor(.primary)
//            Spacer()
//            Text(value)
//                .font(.system(size: 15, weight: .semibold))
//                .foregroundColor(color)
//        }
//        .padding(.bottom, 14)
//    }
//
//    private var lifestyleScoresCard: some View {
//        HStack(alignment: .center, spacing: 20) {
//            compositeRing
//                .frame(width: 108, height: 108)
//            VStack(spacing: 11) {
//                dimBar("Sleep",     report?.sleepScore    ?? 2.0, Color(red: 0.3,  green: 0.55, blue: 0.9))
//                dimBar("Stress",    report?.stressScore   ?? 4.0, Color(red: 0.4,  green: 0.72, blue: 0.35))
//                dimBar("Diet",      report?.dietScore     ?? 3.5, Color(red: 0.9,  green: 0.58, blue: 0.18))
//                dimBar("Hair care", report?.hairCareScore ?? 4.0, Color.hcBrown)
//            }
//        }
//        .padding(18)
//        .background(Color.white)
//        .cornerRadius(18)
//    }
//
//    private func scoreRow(_ label: String, _ value: Float, _ dotColor: Color) -> some View {
//        HStack {
//            Text(label)
//                .font(.system(size: 15))
//                .foregroundColor(.primary)
//                .frame(width: 90, alignment: .leading)
//            Spacer()
//            Circle().fill(dotColor).frame(width: 9, height: 9)
//            Text("\(Int(value))/10")
//                .font(.system(size: 15, weight: .semibold))
//                .foregroundColor(.primary)
//                .frame(width: 48, alignment: .trailing)
//        }
//        .padding(.bottom, 10)
//    }
//
//    // ─────────────────────────────────────
//    // MARK: 4 — Plan Badge Card
//    // ─────────────────────────────────────
//
//    private var planBadgeCard: some View {
//        let stage   = plan?.stage ?? report?.hairFallStage.intValue ?? 2
//        let profile = plan?.lifestyleProfile ?? .poor
//
//        let (profileLabel, profileColor): (String, Color) = {
//            switch profile {
//            case .poor:     return ("Poor lifestyle",     .red)
//            case .moderate: return ("Moderate lifestyle", .orange)
//            case .good:     return ("Good lifestyle",     .green)
//            }
//        }()
//
//        return VStack(spacing: 14) {
//            ZStack {
//                Circle()
//                    .fill(Color.hcBrown)
//                    .frame(width: 96, height: 96)
//                    .shadow(color: Color.hcBrown.opacity(0.3), radius: 10, y: 4)
//                VStack(spacing: 1) {
//                    Text("Plan")
//                        .font(.system(size: 13, weight: .medium))
//                        .foregroundColor(.white.opacity(0.75))
//                    Text(plan?.planId ?? "2A")
//                        .font(.system(size: 30, weight: .bold))
//                        .foregroundColor(.white)
//                }
//            }
//
//            Text("Your personalised hair recovery plan")
//                .font(.system(size: 15))
//                .foregroundColor(.secondary)
//
//            HStack(spacing: 10) {
//                // Stage pill
//                HStack(spacing: 6) {
//                    Circle().fill(stageColor(stage)).frame(width: 8, height: 8)
//                    Text("Stage \(stage)")
//                        .font(.system(size: 13, weight: .semibold))
//                        .foregroundColor(stageColor(stage))
//                }
//                .padding(.horizontal, 14).padding(.vertical, 8)
//                .background(stageColor(stage).opacity(0.12))
//                .cornerRadius(20)
//
//                // Lifestyle pill
//                Text(profileLabel)
//                    .font(.system(size: 13, weight: .semibold))
//                    .foregroundColor(profileColor)
//                    .padding(.horizontal, 14).padding(.vertical, 8)
//                    .background(profileColor.opacity(0.12))
//                    .cornerRadius(20)
//            }
//        }
//        .frame(maxWidth: .infinity)
//        .padding(.vertical, 28)
//        .background(Color.white)
//        .cornerRadius(20)
//    }
//
//    // ─────────────────────────────────────
//    // MARK: 5 — Recommended Plan Section
//    // ─────────────────────────────────────
//
//    private var recommendedPlanSection: some View {
//        let scalp = plan?.scalpModifier ?? report?.scalpCondition ?? .dry
//        let np    = nutrition
//
//        // Build recommendation rows from engine output
//        var items: [(icon: String, iconBg: Color, iconFg: Color, title: String, subtitle: String)] = []
//
//        // Diet
//        items.append((
//            icon:     "leaf.fill",
//            iconBg:   Color(red: 1.0,  green: 0.65, blue: 0.2),
//            iconFg:   .white,
//            title:    "Protein Rich-Diet",
//            subtitle: "For keratin production and hair follicle strength"
//        ))
//
//        // Sleep
//        items.append((
//            icon:     "moon.zzz.fill",
//            iconBg:   Color(red: 0.38, green: 0.3, blue: 0.75),
//            iconFg:   .white,
//            title:    "Sleep",
//            subtitle: "Aim for 7–8 hours to reduce cortisol and support hair repair"
//        ))
//
//        // Hydration
//        let waterL = np.map { String(format: "%.1f", $0.waterTargetML / 1000) } ?? "2.5"
//        items.append((
//            icon:     "drop.fill",
//            iconBg:   Color(red: 0.15, green: 0.55, blue: 0.9),
//            iconFg:   .white,
//            title:    "Hydration",
//            subtitle: "Drink at least \(waterL)L of water to keep your scalp and body hydrated"
//        ))
//
//        // Stress
//        items.append((
//            icon:     "heart.fill",
//            iconBg:   Color(red: 0.2,  green: 0.72, blue: 0.4),
//            iconFg:   .white,
//            title:    "Stress Management",
//            subtitle: "High stress pushes hair follicles into a resting phase — daily MindEase sessions help"
//        ))
//
//        // Scalp-specific tip
//        let (scalpTitle, scalpSub) = scalpPlanItem(scalp)
//        items.append((
//            icon:     scalpIcon(scalp),
//            iconBg:   Color.hcTeal,
//            iconFg:   .white,
//            title:    scalpTitle,
//            subtitle: scalpSub
//        ))
//
//        return VStack(alignment: .leading, spacing: 12) {
//            Text("Recommended Plan")
//                .font(.system(size: 22, weight: .bold))
//                .foregroundColor(.primary)
//                .padding(.bottom, 4)
//
//            ForEach(0..<items.count, id: \.self) { i in
//                let item = items[i]
//                recommendCard(
//                    icon:     item.icon,
//                    iconBg:   item.iconBg,
//                    iconFg:   item.iconFg,
//                    title:    item.title,
//                    subtitle: item.subtitle
//                )
//            }
//        }
//    }
//
//    private func recommendCard(
//        icon: String, iconBg: Color, iconFg: Color,
//        title: String, subtitle: String
//    ) -> some View {
//        HStack(alignment: .center, spacing: 16) {
//            ZStack {
//                Circle().fill(iconBg).frame(width: 50, height: 50)
//                Image(systemName: icon)
//                    .font(.system(size: 20))
//                    .foregroundColor(iconFg)
//            }
//            VStack(alignment: .leading, spacing: 4) {
//                Text(title)
//                    .font(.system(size: 16, weight: .semibold))
//                    .foregroundColor(.primary)
//                Text(subtitle)
//                    .font(.system(size: 13))
//                    .foregroundColor(.secondary)
//                    .lineSpacing(3)
//                    .fixedSize(horizontal: false, vertical: true)
//            }
//            Spacer(minLength: 0)
//        }
//        .padding(16)
//        .background(Color.white)
//        .cornerRadius(16)
//    }
//
//    // MARK: 6 — Daily Targets Strip
//    
//    @ViewBuilder
//    private var dailyTargetsSection: some View {
//        if let np = nutrition {
//            VStack(alignment: .leading, spacing: 12) {
//                Text("Daily Targets")
//                    .font(.system(size: 12, weight: .semibold))
//                    .foregroundColor(.secondary)
//                    .textCase(.uppercase)
//                    .tracking(0.6)
//
//                HStack(spacing: 0) {
//                    targetCell(value: "\(Int(np.tdee))",
//                               unit: "kcal", label: "Calories")
//                    dividerLine
//                    targetCell(value: "\(Int(np.proteinTargetGm))",
//                               unit: "g", label: "Protein")
//                    dividerLine
//                    targetCell(value: "\(Int(np.carbTargetGm))",
//                               unit: "g", label: "Carbs")
//                    dividerLine
//                    targetCell(value: String(format: "%.1f", np.waterTargetML / 1000),
//                               unit: "L", label: "Water")
//                    dividerLine
//                    targetCell(value: "7.5",
//                               unit: "hrs", label: "Sleep")
//                    dividerLine
//                    targetCell(
//                        value: "\(mindEaseMinutes)",
//                        unit: "min", label: "MindEase"
//                    )
//                }
//                .padding(.vertical, 18)
//                .background(Color.white)
//                .cornerRadius(16)
//            }
//        }
//    }
//
//    private func targetCell(value: String, unit: String, label: String) -> some View {
//        VStack(spacing: 3) {
//            Text(value)
//                .font(.system(size: 17, weight: .bold))
//                .foregroundColor(.primary)
//            Text(unit)
//                .font(.system(size: 11, weight: .medium))
//                .foregroundColor(Color.hcBrown)
//            Text(label)
//                .font(.system(size: 11))
//                .foregroundColor(.secondary)
//        }
//        .frame(maxWidth: .infinity)
//    }
//
//    private var dividerLine: some View {
//        Rectangle()
//            .fill(Color(.systemGray5))
//            .frame(width: 1, height: 44)
//    }
//
//    // MARK: 7 — CTA
//
//    private var ctaButton: some View {
//        VStack(spacing: 0) {
//            LinearGradient(
//                colors: [Color.hcCream.opacity(0), Color.hcCream],
//                startPoint: .top, endPoint: .bottom
//            )
//            .frame(height: 32)
//            .allowsHitTesting(false)
//
//            Button { onStart() } label: {
//                Text("Get Started")
//                    .hcPrimaryButton()
//            }
//            .padding(.horizontal, 20)
//            .padding(.bottom, 36)
//            .background(Color.hcCream)
//        }
//    }
//
//    // ─────────────────────────────────────
//    // MARK: Helpers
//    // ─────────────────────────────────────
//
//    private func stageColor(_ s: Int) -> Color {
//        switch s {
//        case 1:  return .green
//        case 2:  return .orange
//        case 3:  return Color(red: 0.85, green: 0.35, blue: 0.1)
//        default: return .red
//        }
//    }
//
//    private func scalpLabel(_ c: ScalpCondition) -> String {
//        switch c {
//        case .dry:      return "Mild Dryness"
//        case .dandruff: return "Dandruff"
//        case .oily:     return "Oily Scalp"
//        case .inflamed: return "Inflamed"
//        case .normal:   return "Normal"
//        }
//    }
//
//    private func scalpIcon(_ c: ScalpCondition) -> String {
//        switch c {
//        case .dry:      return "drop.fill"
//        case .dandruff: return "snowflake"
//        case .oily:     return "waveform.path"
//        case .inflamed: return "flame.fill"
//        case .normal:   return "checkmark.seal.fill"
//        }
//    }
//
//    private func scalpPlanItem(_ c: ScalpCondition) -> (String, String) {
//        switch c {
//        case .dry:
//            return ("Scalp Oiling Routine",
//                    "Warm coconut or almond oil twice a week — reduces dryness and supports follicle strength")
//        case .dandruff:
//            return ("Anti-Dandruff Routine",
//                    "Zinc-rich foods and anti-fungal shampoo — wash every 2–3 days with ketoconazole formula")
//        case .oily:
//            return ("Sebum Control",
//                    "Wash every 2 days — zinc foods regulate sebum. Avoid heavy oils directly on scalp")
//        case .inflamed:
//            return ("Soothing Scalp Care",
//                    "Omega-3 foods and aloe vera gel twice a week — reduces redness and inflammation")
//        case .normal:
//            return ("Maintain Scalp Health",
//                    "Oil once a week, wash every 2–3 days — keep up the healthy routine")
//        }
//    }
//    
//    private var mindEaseMinutes: Int {
//        guard let p = plan else { return 80 }
//        return p.meditationMinutesPerDay + p.yogaMinutesPerDay + p.soundMinutesPerDay
//    }
//    
//    private var compositeRing: some View {
//        let score = report?.lifestyleScore ?? 3.25
//        let frac  = CGFloat(score / 10.0)
//        let c: Color = score < 5 ? .orange : score < 8 ? .orange : .green
//        return ZStack {
//            Circle()
//                .stroke(c.opacity(0.18), lineWidth: 11)
//            Circle()
//                .trim(from: 0, to: animateBars ? frac : 0)
//                .stroke(c, style: StrokeStyle(lineWidth: 11, lineCap: .round))
//                .rotationEffect(.degrees(-90))
//                .animation(.easeOut(duration: 1.0).delay(0.2), value: animateBars)
//            VStack(spacing: 1) {
//                Text(String(format: "%.1f", score))
//                    .font(.system(size: 22, weight: .bold)).foregroundColor(.primary)
//                Text("/ 10").font(.system(size: 11)).foregroundColor(.secondary)
//                Text("composite").font(.system(size: 10)).foregroundColor(.secondary)
//            }
//        }
//    }
//
//    private func dimBar(_ title: String, _ value: Float, _ c: Color) -> some View {
//        let frac = CGFloat(value / 10.0)
//        return VStack(alignment: .leading, spacing: 4) {
//            HStack {
//                Text(title)
//                    .font(.system(size: 13)).foregroundColor(.secondary)
//                    .frame(width: 62, alignment: .leading)
//                Spacer()
//                Text(String(format: "%.1f", value))
//                    .font(.system(size: 13, weight: .semibold)).foregroundColor(.primary)
//            }
//            GeometryReader { g in
//                ZStack(alignment: .leading) {
//                    Capsule().fill(c.opacity(0.15)).frame(height: 6)
//                    Capsule().fill(c)
//                        .frame(width: animateBars ? g.size.width * frac : 0, height: 6)
//                        .animation(.easeOut(duration: 0.85).delay(0.3), value: animateBars)
//                }
//            }
//            .frame(height: 6)
//        }
//    }
//}
//
//
//import SwiftUI
//
//struct PlanResultsView: View {
//    let onStart: () -> Void
//
//    @Environment(AppDataStore.self) private var store
//
//    @State private var cardPage    = 0      // 0 = analysis, 1 = lifestyle
//    @State private var animateBars = false
//
//    private var report:    ScanReport?           { store.latestScanReport }
//    private var plan:      UserPlan?             { store.activePlan }
//    private var nutrition: UserNutritionProfile? { store.activeNutritionProfile }
//
//    // Density → fixed thresholds
//    private func densityLabel(_ pct: Float) -> String {
//        switch pct {
//        case 80...100: return "High (\(Int(pct))%)"
//        case 60..<80:  return "Medium (\(Int(pct))%)"
//        case 40..<60:  return "Low (\(Int(pct))%)"
//        default:       return "Very Low (\(Int(pct))%)"
//        }
//    }
//    private func densityColor(_ pct: Float) -> Color {
//        switch pct {
//        case 80...100: return .green
//        case 60..<80:  return .orange
//        case 40..<60:  return Color(red: 0.85, green: 0.45, blue: 0.1)
//        default:       return .red
//        }
//    }
//
//    var body: some View {
//        ZStack(alignment: .bottom) {
//            Color.hcCream.ignoresSafeArea()
//
//            ScrollView(showsIndicators: false) {
//                VStack(spacing: 0) {
//                    navBar
//                        .padding(.bottom, 20)
//
//                    scanPhotoRow
//                        .padding(.horizontal, 20)
//                        .padding(.bottom, 20)
//
//                    swipeableCards
//                        .padding(.bottom, 20)
//
//                    planBadgeCard
//                        .padding(.horizontal, 20)
//                        .padding(.bottom, 20)
//
//                    recommendedPlanSection
//                        .padding(.horizontal, 20)
//                        .padding(.bottom, 20)
//
//                    dailyTargetsSection
//                        .padding(.horizontal, 20)
//                        .padding(.bottom, 110)
//                }
//                .padding(.top, 12)
//            }
//
//            ctaButton
//        }
//        .onAppear {
//            withAnimation(.easeOut(duration: 0.85).delay(0.3)) {
//                animateBars = true
//            }
//        }
//    }
//
//    // ─────────────────────────────────────
//    // MARK: 1 — Nav Bar
//    // ─────────────────────────────────────
//
//    private var navBar: some View {
//        HStack {
//            HCBackButton { onStart() }
//            Spacer()
//            Text("Scan Report")
//                .font(.system(size: 20, weight: .bold))
//                .foregroundColor(.primary)
//            Spacer()
//            Color.clear.frame(width: 40, height: 40)
//        }
//        .padding(.horizontal, 16)
//    }
//
//    // ─────────────────────────────────────
//    // MARK: 2 — Scan Photo Row
//    // ─────────────────────────────────────
//
//    private var scanPhotoRow: some View {
//        // Mock timestamps — in production read from ScalpScan.scanDate
//        let times = ["12 : 35 PM", "12 : 40 PM", "12 : 45 PM"]
//
//        return HStack(spacing: 12) {
//            ForEach(0..<3, id: \.self) { i in
//                VStack(spacing: 6) {
//                    RoundedRectangle(cornerRadius: 14)
//                        .fill(Color(.systemGray5))
//                        .frame(height: 95)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 14)
//                                .stroke(
//                                    style: StrokeStyle(lineWidth: 1.5, dash: [5, 4])
//                                )
//                                .foregroundColor(Color(.systemGray4))
//                        )
//                        .overlay(
//                            Image(systemName: "camera")
//                                .font(.system(size: 22))
//                                .foregroundColor(Color(.systemGray3))
//                        )
//                    Text(times[i])
//                        .font(.system(size: 11))
//                        .foregroundColor(.secondary)
//                }
//                .frame(maxWidth: .infinity)
//            }
//        }
//    }
//
//    // ─────────────────────────────────────
//    // MARK: 3 — Horizontal Paging Cards
//    // ─────────────────────────────────────
//
//    private var swipeableCards: some View {
//        VStack(spacing: 12) {
//            TabView(selection: $cardPage) {
//                hairAnalysisCard.tag(1)
//                lifestyleScoresCard.tag(0)
//            }
//            .tabViewStyle(.page(indexDisplayMode: .never))
//            .frame(height: 190)
//
//            // Page dots
//            HStack(spacing: 8) {
//                ForEach(0..<2, id: \.self) { i in
//                    Circle()
//                        .fill(cardPage == i ? Color.hcBrown : Color(.systemGray4))
//                        .frame(width: cardPage == i ? 10 : 8,
//                               height: cardPage == i ? 10 : 8)
//                        .animation(.easeInOut(duration: 0.2), value: cardPage)
//                }
//            }
//        }
//        .padding(.horizontal, 20)
//    }
//
//    // Card A — Hair Analysis Results
//    private var hairAnalysisCard: some View {
//        let density  = report?.hairDensityPercent ?? 52
//        let stage    = report?.hairFallStage.intValue ?? plan?.stage ?? 2
//        let scalp    = report?.scalpCondition ?? plan?.scalpModifier ?? .dry
//
//        return VStack(alignment: .leading, spacing: 0) {
//            Text("Your Hair Analysis Results")
//                .font(.system(size: 16, weight: .bold))
//                .foregroundColor(.primary)
//                .padding(.bottom, 10)
//
//            Divider().padding(.bottom, 14)
//
//            resultRow(label: "Hair Density",
//                      value: "\(Int(density))%",
//                      color: densityColor(density))
//            resultRow(label: "Growth Stage",
//                      value: "Stage \(stage)",
//                      color: stageColor(stage))
//            resultRow(label: "Scalp Condition",
//                      value: scalpLabel(scalp),
//                      color: Color(red: 0.2, green: 0.55, blue: 0.9))
//        }
//        .padding(20)
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .background(Color.white)
//        .cornerRadius(18)
//    }
//
//    private func resultRow(label: String, value: String, color: Color) -> some View {
//        HStack {
//            Text(label)
//                .font(.system(size: 15))
//                .foregroundColor(.primary)
//            Spacer()
//            Text(value)
//                .font(.system(size: 15, weight: .semibold))
//                .foregroundColor(color)
//        }
//        .padding(.bottom, 14)
//    }
//
//    // Card B — Lifestyle Scores
////    private var lifestyleScoresCard: some View {
////        let profile  = plan?.lifestyleProfile ?? .poor
////        let sleep    = report?.sleepScore    ?? 2.0
////        let stress   = report?.stressScore   ?? 4.0
////        let diet     = report?.dietScore     ?? 3.5
////        let hairCare = report?.hairCareScore ?? 4.0
////
////        let (badgeLabel, badgeColor): (String, Color) = {
////            switch profile {
////            case .poor:     return ("Poor",     Color(red: 1.0, green: 0.75, blue: 0.75))
////            case .moderate: return ("Moderate", Color(red: 1.0, green: 0.88, blue: 0.7))
////            case .good:     return ("Good",     Color(red: 0.75, green: 0.95, blue: 0.8))
////            }
////        }()
////        let badgeText: Color = profile == .poor ? Color(red: 0.85, green: 0.2, blue: 0.2)
////                             : profile == .moderate ? Color(red: 0.7, green: 0.4, blue: 0.0)
////                             : Color(red: 0.1, green: 0.55, blue: 0.25)
////
////        return VStack(alignment: .leading, spacing: 0) {
////            HStack {
////                Text("Lifestyle Scores")
////                    .font(.system(size: 16, weight: .bold))
////                    .foregroundColor(.primary)
////                Spacer()
////                Text(badgeLabel)
////                    .font(.system(size: 13, weight: .semibold))
////                    .foregroundColor(badgeText)
////                    .padding(.horizontal, 14).padding(.vertical, 5)
////                    .background(badgeColor)
////                    .cornerRadius(20)
////            }
////            .padding(.bottom, 10)
////
////            Divider().padding(.bottom, 12)
////
////            scoreRow("Sleep",     sleep,    Color(red: 0.95, green: 0.4, blue: 0.4))
////            scoreRow("Stress",    stress,   Color(red: 0.95, green: 0.7, blue: 0.15))
////            scoreRow("Diet",      diet,     Color(red: 0.95, green: 0.7, blue: 0.15))
////            scoreRow("Hair Care", hairCare, Color(red: 0.95, green: 0.7, blue: 0.15))
////        }
////        .padding(20)
////        .frame(maxWidth: .infinity, alignment: .leading)
////        .background(Color.white)
////        .cornerRadius(18)
////    }
//
//    private var lifestyleScoresCard: some View {
//        HStack(alignment: .center, spacing: 20) {
//            compositeRing
//                .frame(width: 108, height: 108)
//            VStack(spacing: 11) {
//                dimBar("Sleep",     report?.sleepScore    ?? 2.0, Color(red: 0.3,  green: 0.55, blue: 0.9))
//                dimBar("Stress",    report?.stressScore   ?? 4.0, Color(red: 0.4,  green: 0.72, blue: 0.35))
//                dimBar("Diet",      report?.dietScore     ?? 3.5, Color(red: 0.9,  green: 0.58, blue: 0.18))
//                dimBar("Hair care", report?.hairCareScore ?? 4.0, Color.hcBrown)
//            }
//        }
//        .padding(18)
//        .background(Color.white)
//        .cornerRadius(18)
//    }
//
//    private func scoreRow(_ label: String, _ value: Float, _ dotColor: Color) -> some View {
//        HStack {
//            Text(label)
//                .font(.system(size: 15))
//                .foregroundColor(.primary)
//                .frame(width: 90, alignment: .leading)
//            Spacer()
//            Circle().fill(dotColor).frame(width: 9, height: 9)
//            Text("\(Int(value))/10")
//                .font(.system(size: 15, weight: .semibold))
//                .foregroundColor(.primary)
//                .frame(width: 48, alignment: .trailing)
//        }
//        .padding(.bottom, 10)
//    }
//
//    // ─────────────────────────────────────
//    // MARK: 4 — Plan Badge Card
//    // ─────────────────────────────────────
//
//    private var planBadgeCard: some View {
//        let stage   = plan?.stage ?? report?.hairFallStage.intValue ?? 2
//        let profile = plan?.lifestyleProfile ?? .poor
//
//        let (profileLabel, profileColor): (String, Color) = {
//            switch profile {
//            case .poor:     return ("Poor lifestyle",     .red)
//            case .moderate: return ("Moderate lifestyle", .orange)
//            case .good:     return ("Good lifestyle",     .green)
//            }
//        }()
//
//        return VStack(spacing: 14) {
//            ZStack {
//                Circle()
//                    .fill(Color.hcBrown)
//                    .frame(width: 96, height: 96)
//                    .shadow(color: Color.hcBrown.opacity(0.3), radius: 10, y: 4)
//                VStack(spacing: 1) {
//                    Text("Plan")
//                        .font(.system(size: 13, weight: .medium))
//                        .foregroundColor(.white.opacity(0.75))
//                    Text(plan?.planId ?? "2A")
//                        .font(.system(size: 30, weight: .bold))
//                        .foregroundColor(.white)
//                }
//            }
//
//            Text("Your personalised hair recovery plan")
//                .font(.system(size: 15))
//                .foregroundColor(.secondary)
//
//            HStack(spacing: 10) {
//                // Stage pill
//                HStack(spacing: 6) {
//                    Circle().fill(stageColor(stage)).frame(width: 8, height: 8)
//                    Text("Stage \(stage)")
//                        .font(.system(size: 13, weight: .semibold))
//                        .foregroundColor(stageColor(stage))
//                }
//                .padding(.horizontal, 14).padding(.vertical, 8)
//                .background(stageColor(stage).opacity(0.12))
//                .cornerRadius(20)
//
//                // Lifestyle pill
//                Text(profileLabel)
//                    .font(.system(size: 13, weight: .semibold))
//                    .foregroundColor(profileColor)
//                    .padding(.horizontal, 14).padding(.vertical, 8)
//                    .background(profileColor.opacity(0.12))
//                    .cornerRadius(20)
//            }
//        }
//        .frame(maxWidth: .infinity)
//        .padding(.vertical, 28)
//        .background(Color.white)
//        .cornerRadius(20)
//    }
//
//    // ─────────────────────────────────────
//    // MARK: 5 — Recommended Plan Section
//    // ─────────────────────────────────────
//
//    private var recommendedPlanSection: some View {
//        let scalp = plan?.scalpModifier ?? report?.scalpCondition ?? .dry
//        let np    = nutrition
//
//        // Build recommendation rows from engine output
//        var items: [(icon: String, iconBg: Color, iconFg: Color, title: String, subtitle: String)] = []
//
//        // Diet
//        items.append((
//            icon:     "leaf.fill",
//            iconBg:   Color(red: 1.0,  green: 0.65, blue: 0.2),
//            iconFg:   .white,
//            title:    "Protein Rich-Diet",
//            subtitle: "For keratin production and hair follicle strength"
//        ))
//
//        // Sleep
//        items.append((
//            icon:     "moon.zzz.fill",
//            iconBg:   Color(red: 0.38, green: 0.3, blue: 0.75),
//            iconFg:   .white,
//            title:    "Sleep",
//            subtitle: "Aim for 7–8 hours to reduce cortisol and support hair repair"
//        ))
//
//        // Hydration
//        let waterL = np.map { String(format: "%.1f", $0.waterTargetML / 1000) } ?? "2.5"
//        items.append((
//            icon:     "drop.fill",
//            iconBg:   Color(red: 0.15, green: 0.55, blue: 0.9),
//            iconFg:   .white,
//            title:    "Hydration",
//            subtitle: "Drink at least \(waterL)L of water to keep your scalp and body hydrated"
//        ))
//
//        // Stress
//        items.append((
//            icon:     "heart.fill",
//            iconBg:   Color(red: 0.2,  green: 0.72, blue: 0.4),
//            iconFg:   .white,
//            title:    "Stress Management",
//            subtitle: "High stress pushes hair follicles into a resting phase — daily MindEase sessions help"
//        ))
//
//        // Scalp-specific tip
//        let (scalpTitle, scalpSub) = scalpPlanItem(scalp)
//        items.append((
//            icon:     scalpIcon(scalp),
//            iconBg:   Color.hcTeal,
//            iconFg:   .white,
//            title:    scalpTitle,
//            subtitle: scalpSub
//        ))
//
//        return VStack(alignment: .leading, spacing: 12) {
//            Text("Recommended Plan")
//                .font(.system(size: 22, weight: .bold))
//                .foregroundColor(.primary)
//                .padding(.bottom, 4)
//
//            ForEach(0..<items.count, id: \.self) { i in
//                let item = items[i]
//                recommendCard(
//                    icon:     item.icon,
//                    iconBg:   item.iconBg,
//                    iconFg:   item.iconFg,
//                    title:    item.title,
//                    subtitle: item.subtitle
//                )
//            }
//        }
//    }
//
//    private func recommendCard(
//        icon: String, iconBg: Color, iconFg: Color,
//        title: String, subtitle: String
//    ) -> some View {
//        HStack(alignment: .center, spacing: 16) {
//            ZStack {
//                Circle().fill(iconBg).frame(width: 50, height: 50)
//                Image(systemName: icon)
//                    .font(.system(size: 20))
//                    .foregroundColor(iconFg)
//            }
//            VStack(alignment: .leading, spacing: 4) {
//                Text(title)
//                    .font(.system(size: 16, weight: .semibold))
//                    .foregroundColor(.primary)
//                Text(subtitle)
//                    .font(.system(size: 13))
//                    .foregroundColor(.secondary)
//                    .lineSpacing(3)
//                    .fixedSize(horizontal: false, vertical: true)
//            }
//            Spacer(minLength: 0)
//        }
//        .padding(16)
//        .background(Color.white)
//        .cornerRadius(16)
//    }
//
//    // ─────────────────────────────────────
//    // MARK: 6 — Daily Targets Strip
//    // ─────────────────────────────────────
//
//    @ViewBuilder
//    private var dailyTargetsSection: some View {
//        if let np = nutrition {
//            VStack(alignment: .leading, spacing: 12) {
//                Text("Daily Targets")
//                    .font(.system(size: 12, weight: .semibold))
//                    .foregroundColor(.secondary)
//                    .textCase(.uppercase)
//                    .tracking(0.6)
//
//                HStack(spacing: 0) {
//                    targetCell(value: "\(Int(np.tdee))",
//                               unit: "kcal", label: "Calories")
//                    dividerLine
//                    targetCell(value: "\(Int(np.proteinTargetGm))",
//                               unit: "g", label: "Protein")
//                    dividerLine
//                    targetCell(value: "\(Int(np.carbTargetGm))",
//                               unit: "g", label: "Carbs")
//                    dividerLine
//                    targetCell(value: String(format: "%.1f", np.waterTargetML / 1000),
//                               unit: "L", label: "Water")
//                    dividerLine
//                    targetCell(value: "7.5",
//                               unit: "hrs", label: "Sleep")
//                    dividerLine
//                    targetCell(
//                        value: "\(mindEaseMinutes)",
//                        unit: "min", label: "MindEase"
//                    )
//                }
//                .padding(.vertical, 18)
//                .background(Color.white)
//                .cornerRadius(16)
//            }
//        }
//    }
//
//    private func targetCell(value: String, unit: String, label: String) -> some View {
//        VStack(spacing: 3) {
//            Text(value)
//                .font(.system(size: 17, weight: .bold))
//                .foregroundColor(.primary)
//            Text(unit)
//                .font(.system(size: 11, weight: .medium))
//                .foregroundColor(Color.hcBrown)
//            Text(label)
//                .font(.system(size: 11))
//                .foregroundColor(.secondary)
//        }
//        .frame(maxWidth: .infinity)
//    }
//
//    private var dividerLine: some View {
//        Rectangle()
//            .fill(Color(.systemGray5))
//            .frame(width: 1, height: 44)
//    }
//
//    // ─────────────────────────────────────
//    // MARK: 7 — CTA
//    // ─────────────────────────────────────
//
//    private var ctaButton: some View {
//        VStack(spacing: 0) {
//            LinearGradient(
//                colors: [Color.hcCream.opacity(0), Color.hcCream],
//                startPoint: .top, endPoint: .bottom
//            )
//            .frame(height: 32)
//            .allowsHitTesting(false)
//
//            Button { onStart() } label: {
//                Text("Get Started")
//                    .hcPrimaryButton()
//            }
//            .padding(.horizontal, 20)
//            .padding(.bottom, 36)
//            .background(Color.hcCream)
//        }
//    }
//
//    // ─────────────────────────────────────
//    // MARK: Helpers
//    // ─────────────────────────────────────
//
//    private func stageColor(_ s: Int) -> Color {
//        switch s {
//        case 1:  return .green
//        case 2:  return .orange
//        case 3:  return Color(red: 0.85, green: 0.35, blue: 0.1)
//        default: return .red
//        }
//    }
//
//    private func scalpLabel(_ c: ScalpCondition) -> String {
//        switch c {
//        case .dry:      return "Mild Dryness"
//        case .dandruff: return "Dandruff"
//        case .oily:     return "Oily Scalp"
//        case .inflamed: return "Inflamed"
//        case .normal:   return "Normal"
//        }
//    }
//
//    private func scalpIcon(_ c: ScalpCondition) -> String {
//        switch c {
//        case .dry:      return "drop.fill"
//        case .dandruff: return "snowflake"
//        case .oily:     return "waveform.path"
//        case .inflamed: return "flame.fill"
//        case .normal:   return "checkmark.seal.fill"
//        }
//    }
//
//    private func scalpPlanItem(_ c: ScalpCondition) -> (String, String) {
//        switch c {
//        case .dry:
//            return ("Scalp Oiling Routine",
//                    "Warm coconut or almond oil twice a week — reduces dryness and supports follicle strength")
//        case .dandruff:
//            return ("Anti-Dandruff Routine",
//                    "Zinc-rich foods and anti-fungal shampoo — wash every 2–3 days with ketoconazole formula")
//        case .oily:
//            return ("Sebum Control",
//                    "Wash every 2 days — zinc foods regulate sebum. Avoid heavy oils directly on scalp")
//        case .inflamed:
//            return ("Soothing Scalp Care",
//                    "Omega-3 foods and aloe vera gel twice a week — reduces redness and inflammation")
//        case .normal:
//            return ("Maintain Scalp Health",
//                    "Oil once a week, wash every 2–3 days — keep up the healthy routine")
//        }
//    }
//
//    private var mindEaseMinutes: Int {
//        guard let p = plan else { return 80 }
//        return p.meditationMinutesPerDay + p.yogaMinutesPerDay + p.soundMinutesPerDay
//    }
//
//    private var compositeRing: some View {
//        let score = report?.lifestyleScore ?? 3.25
//        let frac  = CGFloat(score / 10.0)
//        let c: Color = score < 5 ? .orange : score < 8 ? .orange : .green
//        return ZStack {
//            Circle()
//                .stroke(c.opacity(0.18), lineWidth: 11)
//            Circle()
//                .trim(from: 0, to: animateBars ? frac : 0)
//                .stroke(c, style: StrokeStyle(lineWidth: 11, lineCap: .round))
//                .rotationEffect(.degrees(-90))
//                .animation(.easeOut(duration: 1.0).delay(0.2), value: animateBars)
//            VStack(spacing: 1) {
//                Text(String(format: "%.1f", score))
//                    .font(.system(size: 22, weight: .bold)).foregroundColor(.primary)
//                Text("/ 10").font(.system(size: 11)).foregroundColor(.secondary)
//                Text("composite").font(.system(size: 10)).foregroundColor(.secondary)
//            }
//        }
//    }
//
//    private func dimBar(_ title: String, _ value: Float, _ c: Color) -> some View {
//        let frac = CGFloat(value / 10.0)
//        return VStack(alignment: .leading, spacing: 4) {
//            HStack {
//                Text(title)
//                    .font(.system(size: 13)).foregroundColor(.secondary)
//                    .frame(width: 62, alignment: .leading)
//                Spacer()
//                Text(String(format: "%.1f", value))
//                    .font(.system(size: 13, weight: .semibold)).foregroundColor(.primary)
//            }
//            GeometryReader { g in
//                ZStack(alignment: .leading) {
//                    Capsule().fill(c.opacity(0.15)).frame(height: 6)
//                    Capsule().fill(c)
//                        .frame(width: animateBars ? g.size.width * frac : 0, height: 6)
//                        .animation(.easeOut(duration: 0.85).delay(0.3), value: animateBars)
//                }
//            }
//            .frame(height: 6)
//        }
//    }
//}
import SwiftUI

struct PlanResultsView: View {
    let onStart: () -> Void

    @Environment(AppDataStore.self) private var store

    @State private var cardPage    = 0      // 0 = hair analysis, 1 = lifestyle
    @State private var animateBars = false

    private var report:    ScanReport?           { store.latestScanReport }
    private var plan:      UserPlan?             { store.activePlan }
    private var nutrition: UserNutritionProfile? { store.activeNutritionProfile }

    // Density → fixed thresholds
    private func densityLabel(_ pct: Float) -> String {
        switch pct {
        case 80...100: return "High (\(Int(pct))%)"
        case 60..<80:  return "Medium (\(Int(pct))%)"
        case 40..<60:  return "Low (\(Int(pct))%)"
        default:       return "Very Low (\(Int(pct))%)"
        }
    }
    private func densityColor(_ pct: Float) -> Color {
        switch pct {
        case 80...100: return .green
        case 60..<80:  return .orange
        case 40..<60:  return Color(red: 0.85, green: 0.45, blue: 0.1)
        default:       return .red
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.hcCream.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    navBar
                        .padding(.bottom, 20)

                    scanPhotoRow
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)

                    swipeableCards
                        .padding(.bottom, 20)

                    planBadgeCard
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)

                    recommendedPlanSection
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)

                    dailyTargetsSection
                        .padding(.horizontal, 20)
                        .padding(.bottom, 110)
                }
                .padding(.top, 12)
            }

            ctaButton
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.85).delay(0.3)) {
                animateBars = true
            }
        }
    }

    // ─────────────────────────────────────
    // MARK: 1 — Nav Bar
    // ─────────────────────────────────────

    private var navBar: some View {
        HStack {
            HCBackButton { onStart() }
            Spacer()
            Text("Scan Report")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            Spacer()
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, 16)
    }

    // ─────────────────────────────────────
    // MARK: 2 — Scan Photo Row
    // ─────────────────────────────────────

    private var scanPhotoRow: some View {
        let times = ["12 : 35 PM", "12 : 40 PM", "12 : 45 PM"]

        return HStack(spacing: 12) {
            ForEach(0..<3, id: \.self) { i in
                VStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(.systemGray5))
                        .frame(height: 95)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(
                                    style: StrokeStyle(lineWidth: 1.5, dash: [5, 4])
                                )
                                .foregroundColor(Color(.systemGray4))
                        )
                        .overlay(
                            Image(systemName: "camera")
                                .font(.system(size: 22))
                                .foregroundColor(Color(.systemGray3))
                        )
                    Text(times[i])
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    // ─────────────────────────────────────
    // MARK: 3 — Horizontal Paging Cards
    // card 0 = Hair Analysis (shown first), card 1 = Lifestyle Scores
    // ─────────────────────────────────────

    private var swipeableCards: some View {
        VStack(spacing: 12) {
            TabView(selection: $cardPage) {
                hairAnalysisCard.tag(0)         // ← first card, dot 0
                lifestyleScoresCard.tag(1)      // ← second card, dot 1
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 190)

            // Page dots
            HStack(spacing: 8) {
                ForEach(0..<2, id: \.self) { i in
                    Circle()
                        .fill(cardPage == i ? Color.hcBrown : Color(.systemGray4))
                        .frame(width: cardPage == i ? 10 : 8,
                               height: cardPage == i ? 10 : 8)
                        .animation(.easeInOut(duration: 0.2), value: cardPage)
                }
            }
        }
        .padding(.horizontal, 20)
    }

    // Card A — Hair Analysis Results
    private var hairAnalysisCard: some View {
        let density  = report?.hairDensityPercent ?? 52
        let stage    = report?.hairFallStage.intValue ?? plan?.stage ?? 2
        let scalp    = report?.scalpCondition ?? plan?.scalpModifier ?? .dry

        return VStack(alignment: .leading, spacing: 0) {
            Text("Your Hair Analysis Results")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.primary)
                .padding(.bottom, 10)

            Divider().padding(.bottom, 14)

            resultRow(label: "Hair Density",
                      value: "\(Int(density))%",
                      color: densityColor(density))
            resultRow(label: "Growth Stage",
                      value: "Stage \(stage)",
                      color: stageColor(stage))
            resultRow(label: "Scalp Condition",
                      value: scalpLabel(scalp),
                      color: Color(red: 0.2, green: 0.55, blue: 0.9))
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(18)
    }

    private func resultRow(label: String, value: String, color: Color) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 15))
                .foregroundColor(.primary)
            Spacer()
            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(color)
        }
        .padding(.bottom, 14)
    }

    // Card B — Lifestyle Scores (now with title + divider to match Card A)
    private var lifestyleScoresCard: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Title row — mirrors "Your Hair Analysis Results" style
            Text("Your Lifestyle Scores")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.primary)
                .padding(.bottom, 10)

            Divider().padding(.bottom, 12)

            // Ring + dimension bars
            HStack(alignment: .center, spacing: 20) {
                compositeRing
                    .frame(width: 100, height: 100)
                VStack(spacing: 10) {
                    dimBar("Sleep",     report?.sleepScore    ?? 2.0, Color(red: 0.3,  green: 0.55, blue: 0.9))
                    dimBar("Stress",    report?.stressScore   ?? 4.0, Color(red: 0.4,  green: 0.72, blue: 0.35))
                    dimBar("Diet",      report?.dietScore     ?? 3.5, Color(red: 0.9,  green: 0.58, blue: 0.18))
                    dimBar("Hair care", report?.hairCareScore ?? 4.0, Color.hcBrown)
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(18)
    }

    private func scoreRow(_ label: String, _ value: Float, _ dotColor: Color) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 15))
                .foregroundColor(.primary)
                .frame(width: 90, alignment: .leading)
            Spacer()
            Circle().fill(dotColor).frame(width: 9, height: 9)
            Text("\(Int(value))/10")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.primary)
                .frame(width: 48, alignment: .trailing)
        }
        .padding(.bottom, 10)
    }

    // ─────────────────────────────────────
    // MARK: 4 — Plan Badge Card
    // ─────────────────────────────────────

    private var planBadgeCard: some View {
        let stage   = plan?.stage ?? report?.hairFallStage.intValue ?? 2
        let profile = plan?.lifestyleProfile ?? .poor

        let (profileLabel, profileColor): (String, Color) = {
            switch profile {
            case .poor:     return ("Poor lifestyle",     .red)
            case .moderate: return ("Moderate lifestyle", .orange)
            case .good:     return ("Good lifestyle",     .green)
            }
        }()

        return VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.hcBrown)
                    .frame(width: 96, height: 96)
                    .shadow(color: Color.hcBrown.opacity(0.3), radius: 10, y: 4)
                VStack(spacing: 1) {
                    Text("Plan")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.75))
                    Text(plan?.planId ?? "2A")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)
                }
            }

            Text("Your personalised hair recovery plan")
                .font(.system(size: 15))
                .foregroundColor(.secondary)

            HStack(spacing: 10) {
                HStack(spacing: 6) {
                    Circle().fill(stageColor(stage)).frame(width: 8, height: 8)
                    Text("Stage \(stage)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(stageColor(stage))
                }
                .padding(.horizontal, 14).padding(.vertical, 8)
                .background(stageColor(stage).opacity(0.12))
                .cornerRadius(20)

                Text(profileLabel)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(profileColor)
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .background(profileColor.opacity(0.12))
                    .cornerRadius(20)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .background(Color.white)
        .cornerRadius(20)
    }

    // ─────────────────────────────────────
    // MARK: 5 — Recommended Plan Section
    // ─────────────────────────────────────

    private var recommendedPlanSection: some View {
        let scalp = plan?.scalpModifier ?? report?.scalpCondition ?? .dry
        let np    = nutrition

        var items: [(icon: String, iconBg: Color, iconFg: Color, title: String, subtitle: String)] = []

        items.append((
            icon:     "leaf.fill",
            iconBg:   Color(red: 1.0,  green: 0.65, blue: 0.2),
            iconFg:   .white,
            title:    "Protein Rich-Diet",
            subtitle: "For keratin production and hair follicle strength"
        ))
        items.append((
            icon:     "moon.zzz.fill",
            iconBg:   Color(red: 0.38, green: 0.3, blue: 0.75),
            iconFg:   .white,
            title:    "Sleep",
            subtitle: "Aim for 7–8 hours to reduce cortisol and support hair repair"
        ))
        let waterL = np.map { String(format: "%.1f", $0.waterTargetML / 1000) } ?? "2.5"
        items.append((
            icon:     "drop.fill",
            iconBg:   Color(red: 0.15, green: 0.55, blue: 0.9),
            iconFg:   .white,
            title:    "Hydration",
            subtitle: "Drink at least \(waterL)L of water to keep your scalp and body hydrated"
        ))
        items.append((
            icon:     "heart.fill",
            iconBg:   Color(red: 0.2,  green: 0.72, blue: 0.4),
            iconFg:   .white,
            title:    "Stress Management",
            subtitle: "High stress pushes hair follicles into a resting phase — daily MindEase sessions help"
        ))
        let (scalpTitle, scalpSub) = scalpPlanItem(scalp)
        items.append((
            icon:     scalpIcon(scalp),
            iconBg:   Color.hcTeal,
            iconFg:   .white,
            title:    scalpTitle,
            subtitle: scalpSub
        ))

        return VStack(alignment: .leading, spacing: 12) {
            Text("Recommended Plan")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.primary)
                .padding(.bottom, 4)

            ForEach(0..<items.count, id: \.self) { i in
                let item = items[i]
                recommendCard(
                    icon:     item.icon,
                    iconBg:   item.iconBg,
                    iconFg:   item.iconFg,
                    title:    item.title,
                    subtitle: item.subtitle
                )
            }
        }
    }

    private func recommendCard(
        icon: String, iconBg: Color, iconFg: Color,
        title: String, subtitle: String
    ) -> some View {
        HStack(alignment: .center, spacing: 16) {
            ZStack {
                Circle().fill(iconBg).frame(width: 50, height: 50)
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(iconFg)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
    }

    // ─────────────────────────────────────
    // MARK: 6 — Daily Targets Strip
    // ─────────────────────────────────────

    @ViewBuilder
    private var dailyTargetsSection: some View {
        if let np = nutrition {
            VStack(alignment: .leading, spacing: 12) {
                Text("Daily Targets")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                    .tracking(0.6)

                HStack(spacing: 0) {
                    targetCell(value: "\(Int(np.tdee))",
                               unit: "kcal", label: "Calories")
                    dividerLine
                    targetCell(value: "\(Int(np.proteinTargetGm))",
                               unit: "g", label: "Protein")
                    dividerLine
                    targetCell(value: "\(Int(np.carbTargetGm))",
                               unit: "g", label: "Carbs")
                    dividerLine
                    targetCell(value: String(format: "%.1f", np.waterTargetML / 1000),
                               unit: "L", label: "Water")
                    dividerLine
                    targetCell(value: "7.5",
                               unit: "hrs", label: "Sleep")
                    dividerLine
                    targetCell(
                        value: "\(mindEaseMinutes)",
                        unit: "min", label: "MindEase"
                    )
                }
                .padding(.vertical, 18)
                .background(Color.white)
                .cornerRadius(16)
            }
        }
    }

    private func targetCell(value: String, unit: String, label: String) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.primary)
            Text(unit)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color.hcBrown)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var dividerLine: some View {
        Rectangle()
            .fill(Color(.systemGray5))
            .frame(width: 1, height: 44)
    }

    // ─────────────────────────────────────
    // MARK: 7 — CTA
    // ─────────────────────────────────────

    private var ctaButton: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [Color.hcCream.opacity(0), Color.hcCream],
                startPoint: .top, endPoint: .bottom
            )
            .frame(height: 32)
            .allowsHitTesting(false)

            Button { onStart() } label: {
                Text("Get Started")
                    .hcPrimaryButton()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 36)
            .background(Color.hcCream)
        }
    }

    // ─────────────────────────────────────
    // MARK: Helpers
    // ─────────────────────────────────────

    private func stageColor(_ s: Int) -> Color {
        switch s {
        case 1:  return .green
        case 2:  return .orange
        case 3:  return Color(red: 0.85, green: 0.35, blue: 0.1)
        default: return .red
        }
    }

    private func scalpLabel(_ c: ScalpCondition) -> String {
        switch c {
        case .dry:      return "Mild Dryness"
        case .dandruff: return "Dandruff"
        case .oily:     return "Oily Scalp"
        case .inflamed: return "Inflamed"
        case .normal:   return "Normal"
        }
    }

    private func scalpIcon(_ c: ScalpCondition) -> String {
        switch c {
        case .dry:      return "drop.fill"
        case .dandruff: return "snowflake"
        case .oily:     return "waveform.path"
        case .inflamed: return "flame.fill"
        case .normal:   return "checkmark.seal.fill"
        }
    }

    private func scalpPlanItem(_ c: ScalpCondition) -> (String, String) {
        switch c {
        case .dry:
            return ("Scalp Oiling Routine",
                    "Warm coconut or almond oil twice a week — reduces dryness and supports follicle strength")
        case .dandruff:
            return ("Anti-Dandruff Routine",
                    "Zinc-rich foods and anti-fungal shampoo — wash every 2–3 days with ketoconazole formula")
        case .oily:
            return ("Sebum Control",
                    "Wash every 2 days — zinc foods regulate sebum. Avoid heavy oils directly on scalp")
        case .inflamed:
            return ("Soothing Scalp Care",
                    "Omega-3 foods and aloe vera gel twice a week — reduces redness and inflammation")
        case .normal:
            return ("Maintain Scalp Health",
                    "Oil once a week, wash every 2–3 days — keep up the healthy routine")
        }
    }

    private var mindEaseMinutes: Int {
        guard let p = plan else { return 80 }
        return p.meditationMinutesPerDay + p.yogaMinutesPerDay + p.soundMinutesPerDay
    }

    private var compositeRing: some View {
        let score = report?.lifestyleScore ?? 3.25
        let frac  = CGFloat(score / 10.0)
        let c: Color = score < 5 ? .orange : score < 8 ? .orange : .green
        return ZStack {
            Circle()
                .stroke(c.opacity(0.18), lineWidth: 11)
            Circle()
                .trim(from: 0, to: animateBars ? frac : 0)
                .stroke(c, style: StrokeStyle(lineWidth: 11, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 1.0).delay(0.2), value: animateBars)
            VStack(spacing: 1) {
                Text(String(format: "%.1f", score))
                    .font(.system(size: 22, weight: .bold)).foregroundColor(.primary)
                Text("/ 10").font(.system(size: 11)).foregroundColor(.secondary)
                Text("composite").font(.system(size: 10)).foregroundColor(.secondary)
            }
        }
    }

    private func dimBar(_ title: String, _ value: Float, _ c: Color) -> some View {
        let frac = CGFloat(value / 10.0)
        return VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.system(size: 13)).foregroundColor(.secondary)
                    .frame(width: 62, alignment: .leading)
                Spacer()
                Text(String(format: "%.1f", value))
                    .font(.system(size: 13, weight: .semibold)).foregroundColor(.primary)
            }
            GeometryReader { g in
                ZStack(alignment: .leading) {
                    Capsule().fill(c.opacity(0.15)).frame(height: 6)
                    Capsule().fill(c)
                        .frame(width: animateBars ? g.size.width * frac : 0, height: 6)
                        .animation(.easeOut(duration: 0.85).delay(0.3), value: animateBars)
                }
            }
            .frame(height: 6)
        }
    }
}
