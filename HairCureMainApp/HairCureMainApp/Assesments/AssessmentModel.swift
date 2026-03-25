

import Foundation

// MARK: - Assessment & Questions

struct Assessment: Identifiable {
    let id: UUID
    var userId: UUID
    var completionPercent: Float
    var completedAt: Date?
//  @Relationship(deleteRule: .cascade) var answers: [UserAnswer] = []
}

enum QuestionType: String, Codable {
    case singleChoice   // one option pill selected
    case multiChoice    // multiple options
    case imageChoice    // visual image cards (stage picker)
    case freeText       // typed answer
    case picker         // scroll wheel — age/height/weight
}

enum KeyboardType: String, Codable {
    case text
    case decimal
    case number
}

enum ScoreDimension: String, Codable {
    case diet
    case stress
    case sleep
    case hairCare
    case hydration  // folded into diet score
    case none       // hair context / BMR Qs — no lifestyle score
}

struct Question: Identifiable {
    let id: UUID
    var questionType: QuestionType
    var questionText: String
    var questionOrderIndex: Int
    var scoreDimension: ScoreDimension
    var pickerMin: Float?
    var pickerMax: Float?
    var pickerStep: Float?
    var pickerUnit: String?
    var keyboardType: KeyboardType?
//  @Relationship(deleteRule: .cascade) var options: [QuestionOption] = []
}

enum OptionType: String, Codable {
    case text
    case image
}

struct QuestionOption: Identifiable {
    let id: UUID
    var questionId: UUID
    var optionOrderIndex: Int
    var optionText: String
    var imageURL: String?
    var optionType: OptionType
}

// Maps each answer option → score value (engine reads this table)
struct QuestionScoreMap: Identifiable {
    let id: UUID
    var questionId: UUID
    var optionId: UUID
    var scoreDimension: ScoreDimension
    var scoreValue: Float           // 0.0 – 10.0
}

struct UserAnswer: Identifiable {
    let id: UUID
    let answeredAt: Date
    var questionId: UUID
    var assessmentId: UUID
    var selectedOptionId: UUID?
    var selectedOptionIds: [UUID]
    var answerText: String?
    var pickerValue: Float?
    // Written after lookup in QuestionScoreMap
    var scoreValue: Float?
    var scoreDimension: ScoreDimension?
}

// MARK: - Scalp Scan & Report

enum ScanType: String, Codable {
    case initial
    case weekly
}

enum AnalysisSource: String, Codable {
    case aiModel        // 4 photos submitted → AI result
    case selfAssessed   // user picked stage/scalp/density manually
}

struct ScalpScan: Identifiable {
    let id: UUID
    var userId: UUID
    let scanDate: Date
    var frontImageURL: String
    var leftImageURL: String
    var rightImageURL: String
    var backImageURL: String
    var topImageURL: String
    let scanType: ScanType
//  @Relationship(deleteRule: .cascade) var report: ScanReport?
}

enum HairFallStage: String, Codable, CaseIterable {
    case stage1
    case stage2
    case stage3
    case stage4  // refer to doctor

    var displayName: String {
        switch self {
        case .stage1: return "Stage 1 — Early thinning"
        case .stage2: return "Stage 2 — Noticeable thinning"
        case .stage3: return "Stage 3 — Crown patch forming"
        case .stage4: return "Stage 4 — Advanced hair loss"
        }
    }

    var intValue: Int {
        switch self {
        case .stage1: return 1
        case .stage2: return 2
        case .stage3: return 3
        case .stage4: return 4
        }
    }
}

enum ScalpCondition: String, Codable {
    case dandruff
    case dry
    case oily
    case inflamed
    case normal

    var displayName: String { rawValue.capitalized }
}

enum HairDensityLevel: String, Codable {
    case high
    case medium
    case low
    case veryLow

    var displayName: String {
        switch self {
        case .high:    return "Thick & full"
        case .medium:  return "Medium"
        case .low:     return "Thin"
        case .veryLow: return "Very thin"
        }
    }
}

struct ScanReport: Identifiable {
    let id: UUID
    let createdAt: Date
    var scalpScanId: UUID
    var hairDensityPercent: Float
    var hairDensityLevel: HairDensityLevel
    var hairFallStage: HairFallStage
    var scalpCondition: ScalpCondition
    var analysisSource: AnalysisSource
    // Engine output — written once scores are calculated
    var planId: String              // "1A"–"3C" or "refer_doctor"
    var lifestyleScore: Float       // composite 0–10
    var dietScore: Float
    var stressScore: Float
    var sleepScore: Float
    var hairCareScore: Float
    var recommendedPlan: String     // human-readable summary
}

// MARK: - Recommendation Engine Output

enum LifestyleProfile: String, Codable {
    case poor       // composite 0–4
    case moderate   // composite 5–7
    case good       // composite 8–10

    static func from(score: Float) -> LifestyleProfile {
        switch score {
        case 0..<5: return .poor
        case 5..<8: return .moderate
        default:    return .good
        }
    }
}

struct UserPlan: Identifiable {
    let id: UUID
    var userId: UUID
    var scanReportId: UUID
    var planId: String              // "1A"|"1B"|"1C"|"2A"|"2B"|"2C"|"3A"|"3B"|"3C"|"refer_doctor"
    var stage: Int                  // 1, 2, 3, 4
    var lifestyleProfile: LifestyleProfile
    var scalpModifier: ScalpCondition
    // MindEase session assignments from plan matrix
    var meditationMinutesPerDay: Int
    var yogaMinutesPerDay: Int
    var soundMinutesPerDay: Int
    var sessionFrequencyPerWeek: Int
    var isActive: Bool
    var assignedAt: Date
    var expiresAt: Date             // triggers weekly re-assessment nudge
}

// MARK: - Nutrition Profile (BMR Engine Output)

enum ActivityLevel: String, Codable, CaseIterable {
    case sedentary   // × 1.2
    case light       // × 1.375
    case moderate    // × 1.55
    case veryActive  // × 1.725

    var multiplier: Double {
        switch self {
        case .sedentary:  return 1.2
        case .light:      return 1.375
        case .moderate:   return 1.55
        case .veryActive: return 1.725
        }
    }

    var displayName: String {
        switch self {
        case .sedentary:  return "Sedentary (desk job, little exercise)"
        case .light:      return "Light (1–3 days/week exercise)"
        case .moderate:   return "Moderate (3–5 days/week)"
        case .veryActive: return "Very Active (intense daily exercise)"
        }
    }
}

struct UserNutritionProfile: Identifiable {
    let id: UUID
    var userId: UUID
    var activityLevel: ActivityLevel
    var bmr: Float
    var tdee: Float
    // Per-slot calorie budgets
    var breakfastCalTarget: Float   // tdee × 0.25
    var lunchCalTarget: Float       // tdee × 0.35
    var snackCalTarget: Float       // tdee × 0.15
    var dinnerCalTarget: Float      // tdee × 0.25
    // Daily macro targets
    var proteinTargetGm: Float
    var carbTargetGm: Float
    var fatTargetGm: Float
    var waterTargetML: Float        // 35ml × weightKg
    var createdAt: Date
    var updatedAt: Date
}


