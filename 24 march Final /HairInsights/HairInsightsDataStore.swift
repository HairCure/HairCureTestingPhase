
import Foundation
import Observation

@Observable
final class HairInsightsDataStore {

    // MARK: - State

    var hairInsights:  [HairInsight]  = []
    var careTips:      [CareTip]      = []
    var homeRemedies:  [HomeRemedy]   = []
    var dailyTips:     [DailyTip]     = []
    var userFavorites: [UserFavorite] = []

    /// Mirrors AppDataStore.currentUserId so favourite operations stay in sync.
    var currentUserId: UUID

    // MARK: - Init

    init(currentUserId: UUID) {
        self.currentUserId = currentUserId
        seedHairInsights()
        seedCareTips()
        seedHomeRemedies()
        seedDailyTips()
    }

    // ─────────────────────────────────────────────────────────────
    // MARK: - Seeding  (moved verbatim from AppDataStore)
    // ─────────────────────────────────────────────────────────────

    // MARK: Hair Insights  (Stage 2 / dry scalp)

    private func seedHairInsights() {
        [("How zinc deficiency causes hair thinning",
          "Zinc is essential for hair follicle function. Low levels cause the follicle to shrink, leading to visible thinning at the crown.",
          "all", [2, 3]),
         ("Why dry scalp increases breakage",
          "A dry scalp lacks natural oils to protect the hair shaft, increasing brittleness and making hair fall appear worse.",
          "dry", [1, 2, 3]),
         ("The link between cortisol and hair loss",
          "Chronic stress raises cortisol, pushing follicles into the resting phase. Diffuse shedding follows 2–3 months later.",
          "all", [1, 2, 3]),
         ("Best foods to increase biotin naturally",
          "Eggs, almonds, and sweet potatoes are among the richest natural sources of biotin — directly linked to keratin production.",
          "all", [1, 2]),
         ("Oiling routine for dry scalp relief",
          "Warm coconut or almond oil twice a week hydrates the scalp, reduces itching, and creates an environment where hair grows stronger.",
          "dry", [1, 2, 3]),
         ("How sleep deprivation affects your hair",
          "Hair cells are among the fastest dividing in the body. Under 6 hrs consistently disrupts the repair cycle.",
          "all", [1, 2, 3]),
         ("Why daily washing may be hurting you",
          "Daily washing strips natural sebum, causing glands to overcompensate — worsening dryness and irritation.",
          "dry", [1, 2])
        ].forEach { title, desc, scalp, stages in
            hairInsights.append(HairInsight(
                id: UUID(),
                title: title,
                insightDescription: desc,
                category: "hair_health",
                mediaURL: nil,
                targetHairTypes: ["all"],
                targetScalpConditions: [scalp],
                targetPlanStages: stages,
                difficultyLevel: nil,
                isActive: true
            ))
        }
    }

    // MARK: Care Tips

    private func seedCareTips() {
        [("Wash hair every 2–3 days",
          "Over-washing strips the scalp. Washing every 2–3 days maintains natural oil balance.",
          "washing", 1),
         ("Use lukewarm water, not hot",
          "Hot water opens the cuticle too aggressively and dries the scalp.",
          "washing", 2),
         ("Oil your scalp twice a week",
          "Warm coconut or almond oil left for 30 min nourishes follicles and reduces dryness.",
          "oiling", 1),
         ("Avoid tight hairstyles",
          "Tight ponytails put traction on follicles at the hairline — over time causing traction alopecia.",
          "styling", 3),
         ("Pat dry — don't rub",
          "Rubbing wet hair causes breakage. Pat gently with a soft cotton towel.",
          "drying", 2),
         ("Use a wide-tooth comb on wet hair",
          "Wet hair stretches easily. Work from ends upward to prevent snapping.",
          "combing", 2)
        ].forEach { title, desc, cat, priority in
            careTips.append(CareTip(
                id: UUID(),
                title: title,
                tipDescription: desc,
                mediaURL: nil,
                category: cat,
                benefits: "Reduces breakage and supports hair growth",
                actionSteps: nil,
                priority: priority
            ))
        }
    }

    // MARK: Home Remedies

    private func seedHomeRemedies() {
        [("Onion Juice Scalp Treatment",
          "Sulphur in onion juice boosts collagen and improves circulation to follicles.",
          "Reduces hair fall and promotes regrowth",
          "Blend 1 onion, strain juice, apply to scalp 30 min, wash with mild shampoo. Twice a week."),
         ("Aloe Vera Scalp Mask",
          "Proteolytic enzymes repair dead skin cells on the scalp and condition hair.",
          "Soothes dry scalp, reduces dandruff, strengthens hair",
          "Apply fresh aloe gel to scalp and hair. Leave 45 min. Rinse with cool water."),
         ("Fenugreek Seed Hair Mask",
          "Fenugreek contains lecithin and proteins that strengthen hair shafts.",
          "Reduces hair fall and adds shine",
          "Soak 2 tbsp seeds overnight, grind to paste, mix with yogurt. Apply 30 min, wash off."),
         ("Egg & Olive Oil Mask",
          "Egg yolk provides biotin; olive oil adds moisture and shine.",
          "Deep conditioning, reduces dryness",
          "Mix 1 egg yolk with 2 tbsp olive oil. Apply 20 min. Rinse with cool water.")
        ].forEach { title, desc, benefits, instructions in
            homeRemedies.append(HomeRemedy(
                id: UUID(),
                title: title,
                remedyDescription: desc,
                mediaURL: nil,
                benefits: benefits,
                instructions: instructions
            ))
        }
    }

    // MARK: Daily Tips

    private func seedDailyTips() {
        ["Drink a glass of water first thing in the morning to kickstart metabolism.",
         "Pumpkin seeds are rich in zinc — add a handful to your snack today.",
         "A 10-min walk after meals improves nutrient absorption and reduces stress.",
         "Comb gently from ends to roots to prevent breakage and stimulate the scalp.",
         "One egg at breakfast gives you biotin directly linked to keratin production.",
         "7–8 hrs of sleep allows hair cells to repair — aim for a consistent bedtime.",
         "5-minute scalp massage daily improves blood circulation to follicles."
        ].enumerated().forEach { i, tip in
            dailyTips.append(DailyTip(
                id: UUID(),
                tipText: tip,
                category: "hair_health",
                displayDate: Calendar.current.date(byAdding: .day, value: i, to: Date())
            ))
        }
    }

    // ─────────────────────────────────────────────────────────────
    // MARK: - Favourite Helpers (used by HairInsightDetailView)
    // ─────────────────────────────────────────────────────────────

    /// Returns `true` when the current user has favourited `contentId`.
    func isFavourited(contentId: UUID) -> Bool {
        userFavorites.contains {
            $0.userId == currentUserId && $0.contentId == contentId
        }
    }

    /// Adds or removes a favourite entry.  Idempotent — safe to call repeatedly.
    func setFavourited(_ favourited: Bool, contentType: String, contentId: UUID) {
        if favourited {
            guard !isFavourited(contentId: contentId) else { return }
            userFavorites.append(UserFavorite(
                id: UUID(),
                userId: currentUserId,
                contentType: contentType,
                contentId: contentId,
                savedAt: Date()
            ))
        } else {
            userFavorites.removeAll {
                $0.userId == currentUserId && $0.contentId == contentId
            }
        }
    }

    // ─────────────────────────────────────────────────────────────
    // MARK: - Convenience Queries
    // ─────────────────────────────────────────────────────────────

    /// All favourites belonging to the current user.
    var currentUserFavorites: [UserFavorite] {
        userFavorites.filter { $0.userId == currentUserId }
    }

    /// Today's daily tip, falling back to the first available tip if none matches.
    var todaysTip: DailyTip? {
        let today = Calendar.current.startOfDay(for: Date())
        return dailyTips.first {
            guard let d = $0.displayDate else { return false }
            return Calendar.current.startOfDay(for: d) == today
        } ?? dailyTips.first
    }

    /// Care tips sorted by priority ascending.
    var sortedCareTips: [CareTip] {
        careTips.sorted { $0.priority < $1.priority }
    }
}
