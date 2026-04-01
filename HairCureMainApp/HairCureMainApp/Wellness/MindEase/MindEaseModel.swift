//
//  MindEaseModel.swift
//
//  Foundation layer for the MindEase feature.
//  Owns:
//    • Data models

import Foundation

// MARK: - Shared Date Picker Sheet

//struct DatePickerSheet: View {
//    @Binding var selectedDate: Date
//    var accentColor: Color = .mindEasePurple
//    @Binding var isPresented: Bool
//
//    private var yesterday: Date {
//        Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
//    }
//
//    var body: some View {
//        NavigationStack {
//            VStack(spacing: 0) {
//                DatePicker(
//                    "Select a date",
//                    selection: $selectedDate,
//                    in: ...yesterday,
//                    displayedComponents: .date
//                )
//                .datePickerStyle(.graphical)
//                .tint(accentColor)
//                .padding(.horizontal, 16)
//                .padding(.top, 8)
//                Spacer()
//            }
//            .navigationTitle("Pick a Day")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .confirmationAction) {
//                    Button("Done") { isPresented = false }
//                        .fontWeight(.semibold)
//                        .foregroundColor(accentColor)
//                }
//                ToolbarItem(placement: .cancellationAction) {
//                    Button("Cancel") { isPresented = false }
//                }
//            }
//        }
//        .presentationDetents([.medium, .large])
//        .presentationDragIndicator(.visible)
//    }
//}

// MARK: - Category

struct MindEaseCategory: Identifiable, Hashable {
    let id: UUID
    var title: String
    var categoryDescription: String
    var cardImageUrl: String
    var cardIconName: String
    var tagline: String
}

// MARK: - Category Content

struct MindEaseCategoryContent: Identifiable, Hashable {
    let id: UUID
    var categoryId: UUID
    var title: String
    var contentDescription: String
    var caption: String
    var mediaURL: String
    var mediaType: String               // "video" | "audio"
    var durationSeconds: Int
    var difficultyLevel: String
    var imageurl: String
    var lastPlaybackSeconds: Int

    var durationMinutes: Int { durationSeconds / 60 }

    // MARK: Computed Helpers

   
}

// MARK: - Mindful Session

struct MindfulSession: Identifiable, Hashable {
    let id: UUID
    var userId: UUID
    var contentId: UUID
    var sessionDate: Date
    var minutesCompleted: Int
    var startTime: Date
    var endTime: Date
}

// MARK: - Today's Plan

struct TodaysPlan: Identifiable, Hashable {
    let id: UUID
    var userId: UUID
    var planDate: Date
    var contentId: UUID
    var categoryId: UUID
    var planId: String
    var minutesTarget: Int
    var minutesCompleted: Int
    var isCompleted: Bool
}
