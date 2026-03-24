////
////  PlanResultsView.swift
////  HairCureTesting1
////
////  Created by Abhinav Yadav on 19/03/26.
////
//
//
////
////  PlanResultsView.swift
////  HairCure
////
////  Shown after FallbackAssessmentView runs the engine.
////  Reads: store.latestScanReport, store.activePlan, store.activeNutritionProfile
////
////  Sections:
////   1. Plan badge + stage + lifestyle pills
////   2. Composite score ring + 4 dimension bars
////   3. Plan title + summary
////   4. Scalp modifier note
////   5. 4 module focus cards (Diet / MindEase / Hair Care / Insights)
////   6. Nutrition targets strip
////   7. "Start My Plan" CTA
////
//
//import SwiftUI
//
//struct PlanResultsView: View {
//    let onStart: () -> Void
//
//    @Environment(AppDataStore.self) private var store
//    @State private var animateBars = false
//    @State private var animateRing = false
//
//    private var report:    ScanReport?           { store.latestScanReport }
//    private var plan:      UserPlan?             { store.activePlan }
//    private var nutrition: UserNutritionProfile? { store.activeNutritionProfile }
//
//    private var scores: RecommendationEngine.LifestyleScores {
//        RecommendationEngine.LifestyleScores(
//            diet:      report?.dietScore     ?? 3.5,
//            stress:    report?.stressScore   ?? 4.0,
//            sleep:     report?.sleepScore    ?? 2.0,
//            hairCare:  report?.hairCareScore ?? 4.0,
//            hydration: 4.0,
//            composite: report?.lifestyleScore ?? 3.25
//        )
//    }
//
//    var body: some View {
//        ZStack(alignment: .bottom) {
//            Color.hcCream.ignoresSafeArea()
//
//            ScrollView(showsIndicators: false) {
//                VStack(spacing: 20) {
//                    headerBanner
//                    scoreSection
//                    planSummaryCard
//                    if let p = plan { scalpCard(p) }
//                    if let p = plan { modulesSection(p) }
//                    nutritionStrip
//                    Color.clear.frame(height: 90)
//                }
//                .padding(.horizontal, 20)
//                .padding(.top, 24)
//            }
//
//            ctaButton
//        }
//        .onAppear {
//            withAnimation(.easeOut(duration: 1.0).delay(0.25)) { animateRing = true }
//            withAnimation(.easeOut(duration: 0.85).delay(0.4))  { animateBars = true }
//        }
//    }
//
//    // ─────────────────────────────────────
//    // MARK: 1 — Header
//    // ─────────────────────────────────────
//
//    private var headerBanner: some View {
//        VStack(spacing: 14) {
//            ZStack {
//                Circle()
//                    .fill(Color.hcBrown)
//                    .frame(width: 96, height: 96)
//                VStack(spacing: 1) {
//                    Text("Plan")
//                        .font(.system(size: 13, weight: .medium))
//                        .foregroundColor(.white.opacity(0.75))
//                    Text(plan?.planId ?? "–")
//                        .font(.system(size: 30, weight: .bold))
//                        .foregroundColor(.white)
//                }
//            }
//            .shadow(color: Color.hcBrown.opacity(0.25), radius: 10, y: 4)
//
//            Text("Your personalised hair recovery plan")
//                .font(.system(size: 15))
//                .foregroundColor(.secondary)
//
//            HStack(spacing: 10) {
//                stagePill
//                lifestylePill
//            }
//        }
//        .frame(maxWidth: .infinity)
//        .padding(.vertical, 28)
//        .background(Color.white)
//        .cornerRadius(20)
//    }
//
//    private var stagePill: some View {
//        let s = plan?.stage ?? report?.hairFallStage.intValue ?? 2
//        let c = stageColor(s)
//        return HStack(spacing: 6) {
//            Circle().fill(c).frame(width: 7, height: 7)
//            Text("Stage \(s)")
//                .font(.system(size: 13, weight: .semibold))
//                .foregroundColor(c)
//        }
//        .padding(.horizontal, 14).padding(.vertical, 7)
//        .background(c.opacity(0.12)).cornerRadius(20)
//    }
//
//    private var lifestylePill: some View {
//        let (label, c): (String, Color) = {
//            switch plan?.lifestyleProfile ?? .moderate {
//            case .poor:     return ("Poor", .red)
//            case .moderate: return ("Moderate", .orange)
//            case .good:     return ("Good", .green)
//            }
//        }()
//        return Text("\(label) lifestyle")
//            .font(.system(size: 13, weight: .semibold))
//            .foregroundColor(c)
//            .padding(.horizontal, 14).padding(.vertical, 7)
//            .background(c.opacity(0.12)).cornerRadius(20)
//    }
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
//    // ─────────────────────────────────────
//    // MARK: 2 — Scores
//    // ─────────────────────────────────────
//
//    private var scoreSection: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            label("Lifestyle scores")
//            HStack(alignment: .center, spacing: 20) {
//                ring.frame(width: 108, height: 108)
//                VStack(spacing: 11) {
//                    dimBar("Sleep",     scores.sleep,    Color(red: 0.3, green: 0.55, blue: 0.9))
//                    dimBar("Stress",    scores.stress,   Color(red: 0.4, green: 0.72, blue: 0.35))
//                    dimBar("Diet",      scores.diet,     Color(red: 0.9, green: 0.58, blue: 0.18))
//                    dimBar("Hair care", scores.hairCare, Color.hcBrown)
//                }
//            }
//            .padding(18)
//            .background(Color.white)
//            .cornerRadius(16)
//        }
//    }
//
//    private var ring: some View {
//        let score = scores.composite
//        let frac  = CGFloat(score / 10.0)
//        let c: Color = score < 5 ? .red : score < 8 ? .orange : .green
//        return ZStack {
//            Circle().stroke(c.opacity(0.14), lineWidth: 11)
//            Circle()
//                .trim(from: 0, to: animateRing ? frac : 0)
//                .stroke(c, style: StrokeStyle(lineWidth: 11, lineCap: .round))
//                .rotationEffect(.degrees(-90))
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
//                Text(title).font(.system(size: 12)).foregroundColor(.secondary)
//                    .frame(width: 58, alignment: .leading)
//                Spacer()
//                Text(String(format: "%.1f", value))
//                    .font(.system(size: 12, weight: .semibold)).foregroundColor(.primary)
//            }
//            GeometryReader { g in
//                ZStack(alignment: .leading) {
//                    Capsule().fill(c.opacity(0.15)).frame(height: 6)
//                    Capsule().fill(c)
//                        .frame(width: animateBars ? g.size.width * frac : 0, height: 6)
//                }
//            }.frame(height: 6)
//        }
//    }
//
//    // ─────────────────────────────────────
//    // MARK: 3 — Plan Summary Card
//    // ─────────────────────────────────────
//
//    private var planSummaryCard: some View {
//        let desc = plan.map {
//            RecommendationEngine.buildPlanDescription(
//                planId: $0.planId, scalpCondition: $0.scalpModifier, scores: scores)
//        }
//        return VStack(alignment: .leading, spacing: 12) {
//            label("Your plan")
//            VStack(alignment: .leading, spacing: 10) {
//                Text(desc?.planTitle ?? "Personalised plan")
//                    .font(.system(size: 17, weight: .bold)).foregroundColor(.primary)
//                Text(desc?.planSummary ?? "")
//                    .font(.system(size: 14)).foregroundColor(.secondary).lineSpacing(4)
//            }
//            .padding(16)
//            .frame(maxWidth: .infinity, alignment: .leading)
//            .background(Color.hcBrown.opacity(0.06))
//            .cornerRadius(14)
//            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.hcBrown.opacity(0.18), lineWidth: 1))
//        }
//    }
//
//    // ─────────────────────────────────────
//    // MARK: 4 — Scalp Card
//    // ─────────────────────────────────────
//
//    private func scalpCard(_ p: UserPlan) -> some View {
//        let (note, icon) = scalpInfo(p.scalpModifier)
//        return HStack(spacing: 14) {
//            Image(systemName: icon)
//                .font(.system(size: 20)).foregroundColor(Color.hcTeal)
//                .frame(width: 38, height: 38)
//                .background(Color.hcTeal.opacity(0.1)).cornerRadius(10)
//            Text(note)
//                .font(.system(size: 13)).foregroundColor(.primary).lineSpacing(3)
//            Spacer()
//        }
//        .padding(14)
//        .background(Color.hcTeal.opacity(0.07))
//        .cornerRadius(14)
//        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.hcTeal.opacity(0.22), lineWidth: 1))
//    }
//
//    private func scalpInfo(_ c: ScalpCondition) -> (String, String) {
//        switch c {
//        case .dry:      return ("Dry scalp — oiling schedule and Vitamin A foods added.", "drop.fill")
//        case .dandruff: return ("Dandruff — zinc-rich foods and anti-fungal routine added.", "snowflake")
//        case .oily:     return ("Oily scalp — sebum-balancing tips and wash frequency adjusted.", "waveform.path")
//        case .inflamed: return ("Inflammation — Omega-3 foods and cooling oil routine prioritised.", "flame.fill")
//        case .normal:   return ("Scalp is normal — standard plan applied.", "checkmark.seal.fill")
//        }
//    }
//
//    // ─────────────────────────────────────
//    // MARK: 5 — Module Cards
//    // ─────────────────────────────────────
//
//    private func modulesSection(_ p: UserPlan) -> some View {
//        let desc = RecommendationEngine.buildPlanDescription(
//            planId: p.planId, scalpCondition: p.scalpModifier, scores: scores)
//        let mindTitle = "MindEase · \(p.meditationMinutesPerDay + p.yogaMinutesPerDay + p.soundMinutesPerDay) min/day"
//
//        return VStack(alignment: .leading, spacing: 12) {
//            label("What your plan includes")
//            moduleCard(icon: "fork.knife",         color: Color(red: 0.9, green: 0.55, blue: 0.1),  title: "Diet",       body: desc.dietFocus)
//            moduleCard(icon: "brain.head.profile",  color: Color(red: 0.45, green: 0.35, blue: 0.85), title: mindTitle,   body: desc.mindEaseFocus)
//            moduleCard(icon: "drop.halffull",       color: Color.hcTeal,                              title: "Hair care",  body: desc.hairCareFocus)
//            moduleCard(icon: "lightbulb.fill",      color: Color(red: 0.2, green: 0.65, blue: 0.4),   title: "Insights",   body: desc.insightsFocus)
//        }
//    }
//
//    private func moduleCard(icon: String, color: Color, title: String, body: String) -> some View {
//        HStack(alignment: .top, spacing: 14) {
//            Image(systemName: icon)
//                .font(.system(size: 17)).foregroundColor(color)
//                .frame(width: 36, height: 36)
//                .background(color.opacity(0.12)).cornerRadius(10)
//            VStack(alignment: .leading, spacing: 5) {
//                Text(title).font(.system(size: 14, weight: .semibold)).foregroundColor(.primary)
//                Text(body).font(.system(size: 13)).foregroundColor(.secondary)
//                    .lineSpacing(3).fixedSize(horizontal: false, vertical: true)
//            }
//            Spacer(minLength: 0)
//        }
//        .padding(14)
//        .background(Color.white)
//        .cornerRadius(14)
//    }
//
//    // ─────────────────────────────────────
//    // MARK: 6 — Nutrition Strip
//    // ─────────────────────────────────────
//
//    @ViewBuilder
//    private var nutritionStrip: some View {
//        if let np = nutrition {
//            VStack(alignment: .leading, spacing: 12) {
//                label("Daily targets")
//                HStack(spacing: 0) {
//                    nutCell("Calories", "\(Int(np.tdee))",              "kcal")
//                    Divider().frame(height: 44)
//                    nutCell("Protein",  "\(Int(np.proteinTargetGm))",   "g")
//                    Divider().frame(height: 44)
//                    nutCell("Carbs",    "\(Int(np.carbTargetGm))",      "g")
//                    Divider().frame(height: 44)
//                    nutCell("Water",    String(format: "%.1f", np.waterTargetML / 1000), "L")
//                }
//                .padding(.vertical, 14)
//                .background(Color.white)
//                .cornerRadius(14)
//            }
//        }
//    }
//
//    private func nutCell(_ title: String, _ value: String, _ unit: String) -> some View {
//        VStack(spacing: 3) {
//            Text(value).font(.system(size: 17, weight: .bold)).foregroundColor(.primary)
//            Text(unit).font(.system(size: 11)).foregroundColor(Color.hcBrown)
//            Text(title).font(.system(size: 11)).foregroundColor(.secondary)
//        }
//        .frame(maxWidth: .infinity)
//    }
//
//    // ─────────────────────────────────────
//    // MARK: CTA + helpers
//    // ─────────────────────────────────────
//
//    private var ctaButton: some View {
//        Button { onStart() } label: {
//            Text("Start My Plan")
//                .hcPrimaryButton()
//        }
//        .padding(.horizontal, 20)
//        .padding(.bottom, 36)
//        .background(
//            LinearGradient(
//                colors: [Color.hcCream.opacity(0), Color.hcCream],
//                startPoint: .top, endPoint: .bottom
//            )
//            .frame(height: 110)
//            .allowsHitTesting(false),
//            alignment: .bottom
//        )
//    }
//
//    private func label(_ text: String) -> some View {
//        Text(text)
//            .font(.system(size: 12, weight: .semibold))
//            .foregroundColor(.secondary)
//            .textCase(.uppercase)
//            .tracking(0.6)
//    }
//}
