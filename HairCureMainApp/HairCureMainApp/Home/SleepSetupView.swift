
//
//
////
////  SleepSetupView.swift
////  HairCure
////
////  Sheet — set bed time + wake time + alarm toggle.
////  Saves via store.saveSleepRecord().
////
//
//import SwiftUI
//
//struct SleepSetupView: View {
//    @Environment(AppDataStore.self) private var store
//    @Environment(\.dismiss)         private var dismiss
//
//    @State private var bedTime     = Calendar.current.date(bySettingHour: 23, minute: 0, second: 0, of: Date())!
//    @State private var wakeTime    = Calendar.current.date(bySettingHour: 7,  minute: 0, second: 0, of: Date())!
//    @State private var alarmOn     = true
//    @State private var saved       = false
//
//    private var hoursSlept: Float {
//        var diff = wakeTime.timeIntervalSince(bedTime)
//        if diff < 0 { diff += 86400 }
//        return Float(diff / 3600)
//    }
//
//    private var sleepQualityColor: Color {
//        switch hoursSlept {
//        case 7...:   return .green
//        case 6..<7:  return .orange
//        default:     return .red
//        }
//    }
//
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                Color.hcCream.ignoresSafeArea()
//
//                ScrollView(showsIndicators: false) {
//                    VStack(spacing: 24) {
//
//                        // Hours preview
//                        hoursPreview
//                            .padding(.top, 8)
//
//                        // Bed time picker
//                        pickerCard(label: "Bed time", icon: "moon.fill",
//                                   iconColor: Color(red: 0.38, green: 0.35, blue: 0.8),
//                                   binding: $bedTime)
//
//                        // Wake time picker
//                        pickerCard(label: "Wake time", icon: "sun.max.fill",
//                                   iconColor: Color(red: 0.95, green: 0.7, blue: 0.15),
//                                   binding: $wakeTime)
//
//                        // Alarm toggle
//                        HStack {
//                            Image(systemName: "alarm.fill")
//                                .foregroundColor(Color.hcBrown)
//                                .font(.system(size: 18))
//                            Text("Set alarm for wake time")
//                                .font(.system(size: 15))
//                                .foregroundColor(.primary)
//                            Spacer()
//                            Toggle("", isOn: $alarmOn)
//                                .tint(Color.hcBrown)
//                                .labelsHidden()
//                        }
//                        .padding(16)
//                        .background(Color.white)
//                        .cornerRadius(14)
//                        .padding(.horizontal, 20)
//
//                        // Save
//                        Button {
//                            store.saveSleepRecord(
//                                bedTime: bedTime, wakeTime: wakeTime,
//                                alarmEnabled: alarmOn, alarmTime: wakeTime
//                            )
//                            saved = true
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
//                                dismiss()
//                            }
//                        } label: {
//                            Text(saved ? "Saved!" : "Save Sleep Schedule")
//                                .hcPrimaryButton()
//                        }
//                        .padding(.horizontal, 20)
//                        .disabled(saved)
//
//                        // Last night card if exists
//                        if let last = store.lastNightSleep {
//                            VStack(alignment: .leading, spacing: 6) {
//                                Text("Last night")
//                                    .font(.system(size: 12, weight: .semibold))
//                                    .foregroundColor(.secondary)
//                                    .textCase(.uppercase)
//                                    .tracking(0.5)
//                                HStack {
//                                    Image(systemName: "moon.zzz.fill")
//                                        .foregroundColor(Color(red: 0.38, green: 0.35, blue: 0.8))
//                                    Text("\(String(format: "%.1f", last.hoursSlept)) hours slept")
//                                        .font(.system(size: 15, weight: .medium))
//                                        .foregroundColor(.primary)
//                                    Spacer()
//                                    Text(last.hoursSlept >= 7 ? "Good" : "Under target")
//                                        .font(.system(size: 13))
//                                        .foregroundColor(last.hoursSlept >= 7 ? .green : .orange)
//                                }
//                            }
//                            .padding(16)
//                            .background(Color.white)
//                            .cornerRadius(14)
//                            .padding(.horizontal, 20)
//                        }
//                    }
//                    .padding(.bottom, 40)
//                }
//            }
//            .navigationTitle("Sleep Tracker")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button {
//                        dismiss()
//                    } label: {
//                        Image(systemName: "xmark")
//                            .font(.system(size: 14, weight: .medium))
//                            .foregroundColor(.primary)
//                            .frame(width: 32, height: 32)
//                            .background(Color(.systemGray5))
//                            .clipShape(Circle())
//                    }
//                }
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Done") { dismiss() }
//                        .foregroundColor(Color.hcBrown)
//                }
//            }
//        }
//    }
//
//    // ── Hours preview ──
//    private var hoursPreview: some View {
//        VStack(spacing: 6) {
//            Text(String(format: "%.1f", hoursSlept))
//                .font(.system(size: 48, weight: .bold))
//                .foregroundColor(sleepQualityColor)
//            Text("hours of sleep")
//                .font(.system(size: 14))
//                .foregroundColor(.secondary)
//            Text(hoursSlept >= 7 ? "Great target!" : hoursSlept >= 6 ? "Slightly under — aim for 7+" : "Below target — hair repair needs 7+ hrs")
//                .font(.system(size: 13))
//                .foregroundColor(sleepQualityColor)
//        }
//        .frame(maxWidth: .infinity)
//        .padding(.vertical, 24)
//        .background(Color.white)
//        .cornerRadius(18)
//        .padding(.horizontal, 20)
//        .animation(.easeInOut(duration: 0.2), value: hoursSlept)
//    }
//
//    // ── Time picker card ──
//    private func pickerCard(
//        label: String, icon: String,
//        iconColor: Color, binding: Binding<Date>
//    ) -> some View {
//        VStack(alignment: .leading, spacing: 10) {
//            HStack(spacing: 10) {
//                Image(systemName: icon)
//                    .foregroundColor(iconColor)
//                    .font(.system(size: 16))
//                Text(label)
//                    .font(.system(size: 15, weight: .semibold))
//                    .foregroundColor(.primary)
//            }
//            DatePicker("", selection: binding, displayedComponents: .hourAndMinute)
//                .datePickerStyle(.wheel)
//                .labelsHidden()
//                .frame(maxWidth: .infinity)
//                .clipped()
//        }
//        .padding(16)
//        .background(Color.white)
//        .cornerRadius(14)
//        .padding(.horizontal, 20)
//    }
//}
