import Foundation
import Observation

// MARK: - HairInsightsDataStore

@Observable
class HairInsightsDataStore {

    // MARK: - Properties

    var careTips: [CareTip]           = []
    var homeRemedies: [HomeRemedy]    = []
    var userFavorites: [UserFavorite] = []

    // MARK: - Init

    init() {
        seedCareTips()
        seedRemedies()
    }

    // MARK: - Favourite Helpers
// checks if user has made  favourite this item
    func isFavorite(contentId: UUID) -> Bool {
        userFavorites.contains { $0.contentId == contentId }
    }

    func toggleFavorite(contentId: UUID) {
        // if user already made fav remove it
        if let idx = userFavorites.firstIndex(where: { $0.contentId == contentId }) {
            userFavorites.remove(at: idx)
            
        }
        //otherwise add it
        else {
            userFavorites.append(UserFavorite(
                id: UUID(),
                contentId: contentId,
                savedAt: Date()
            ))
        }
    }

    // MARK: - Favourited Content Resolvers
    //Takes raw userFavorites IDs → looks them up in careTips array → returns actual [CareTip] objects in most-recently-saved order
    
    func favouritedCareTips() -> [CareTip] {
        let ids = userFavorites
            .sorted { $0.savedAt > $1.savedAt }
            .map(\.contentId)
        return ids.compactMap { id in careTips.first { $0.id == id } }
    }

    func favouritedHomeRemedies() -> [HomeRemedy] {
        let ids = userFavorites
            .sorted { $0.savedAt > $1.savedAt }
            .map(\.contentId)
        return ids.compactMap { id in homeRemedies.first { $0.id == id } }
        
        
    }

    func allFavourites() -> [AnyFavouriteItem] {
        let tips    = favouritedCareTips().map    { AnyFavouriteItem.careTip($0) }
        let remedies = favouritedHomeRemedies().map { AnyFavouriteItem.remedy($0) }
        return tips + remedies
    }
//    `//Calls both functions above
//    - Wraps each result into `AnyFavouriteItem` so both types live in one unified array
//    - Combines them with `+

    // MARK: - Seed Data
   // private bcs  called only once from init() and never needed by anyone outside the class.
    // this function only exists to serve init()

    private func seedCareTips() {
        careTips = [
            CareTip(id: UUID(), title: "Oil Massage",
                    tipDescription: "A warm oil massage before washing increases blood flow to hair follicles, promoting growth and reducing shedding.",
                    mediaURL: "oil_massage_thumb", isActive: true),
            CareTip(id: UUID(), title: "Silk Pillowcase",
                    tipDescription: "Sleeping on silk reduces friction and prevents hair breakage and split ends overnight.",
                    mediaURL: "silk_pillowcase_thumb", isActive: true),
            CareTip(id: UUID(), title: "Cold Water Rinse",
                    tipDescription: "Finishing your wash with cold water seals the hair cuticle for added shine and less frizz.",
                    mediaURL: "cold_water_rinse_thumb", isActive: true),
            CareTip(id: UUID(), title: "Scalp Massage",
                    tipDescription: "A 5-minute daily scalp massage stimulates follicles and may increase hair thickness over time.",
                    mediaURL: "scalp_massage_thumb", isActive: true),
        ]
    }

    private func seedRemedies() {
        homeRemedies = [
            HomeRemedy(id: UUID(), title: "Aloevera Hair Mask",
                       remedyDescription: "Applying aloevera hair mask ?",
                       mediaURL: "aloevera_mask_thumb", videoDurationSeconds: 120,
                       benefits: "Soothes the scalp, reduces hair fall, and adds smooth healthy shine.",
                       instructions: "Apply fresh aloe vera gel to scalp and hair. Leave for 30 minutes. Rinse with mild shampoo.",
                       isActive: true),
            HomeRemedy(id: UUID(), title: "Onion Juice Massage",
                       remedyDescription: "How to do onion juice massage ?",
                       mediaURL: "onion_juice_thumb", videoDurationSeconds: 105,
                       benefits: "Rich in sulphur which boosts collagen production and reduces hair thinning.",
                       instructions: "Blend 2 onions, strain the juice, apply to scalp, leave for 15 minutes, wash off.",
                       isActive: true),
            HomeRemedy(id: UUID(), title: "Egg White Mask",
                       remedyDescription: "How to apply egg white mask ?",
                       mediaURL: "egg_mask_thumb", videoDurationSeconds: 150,
                       benefits: "Protein-packed mask that strengthens the hair shaft and reduces breakage.",
                       instructions: "Whisk 2 egg whites, apply to damp hair, leave for 20 minutes, rinse with cool water.",
                       isActive: true),
        ]
    }
}

// MARK: - AnyFavouriteItem
// this is a type erased wrapper enum let us values of diff array to mix in one
enum AnyFavouriteItem: Identifiable {
    case careTip(CareTip)
    case remedy(HomeRemedy)

    var id: UUID {
        switch self {
        case .careTip(let t): return t.id
        case .remedy(let r):  return r.id
        }
    }

    var title: String {
        switch self {
        case .careTip(let t): return t.title
        case .remedy(let r):  return r.title
        }
    }

    var mediaURL: String? {
        switch self {
        case .careTip(let t): return t.mediaURL
        case .remedy(let r):  return r.mediaURL
        }
    }
}
#if DEBUG
extension HairInsightsDataStore {
    static func mock() -> HairInsightsDataStore {
        return HairInsightsDataStore()  // init() already calls seedCareTips() and seedRemedies()
    }
}
#endif
