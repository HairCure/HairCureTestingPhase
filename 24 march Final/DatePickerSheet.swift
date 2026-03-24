//
//  DatePickerSheet.swift
//  HairCureTesting1
//
//  Shared bottom-sheet date picker used by WaterIntakeHistoryView and SleepHistoryView.
//  Presents a graphical calendar with a "Done" button.
//

import SwiftUI

struct DatePickerSheet: View {
    @Binding var selectedDate: Date
    let accentColor: Color
    @Binding var isPresented: Bool

    // Only allow up to today
    private let range: PartialRangeThrough<Date> = ...Date()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    in: range,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .tint(accentColor)
                .padding(.horizontal, 12)
                .padding(.top, 8)

                Spacer()
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Select Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        // Clamp to start of day so queries match
                        selectedDate = Calendar.current.startOfDay(for: selectedDate)
                        isPresented  = false
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(accentColor)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                        .foregroundColor(.secondary)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
