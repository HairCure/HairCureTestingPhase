////
////  MindfulDetailView.swift
////  HairCureTesting1
////
//
//import SwiftUI
//import Charts
//
//struct MindfulDetailView: View {
//    @Environment(\.dismiss) private var dismiss
//    @Environment(AppDataStore.self) private var store
//    @Environment(MindEaseDataStore.self) private var mindEaseStore
//
//    struct MindfulSegment: Identifiable {
//        let id = UUID()
//        let name: String
//        let color: Color
//        let minutes: Int
//        let target: Int
//    }
//    
//    @State private var segments: [MindfulSegment] = []
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 20) {
//            HStack(alignment: .firstTextBaseline, spacing: 8) {
//                Text("Today")
//                    .font(.system(size: 28, weight: .bold))
//                Text("\(mindEaseStore.todaysMindfulMinutes()) min")
//                    .font(.system(size: 14, weight: .bold))
//                    .foregroundColor(.blue)
//            }
//            .padding(.horizontal, 20)
//            .padding(.top, 10)
//            
//            Text(Date().formatted(.dateTime.day(.twoDigits).month().year()))
//                .font(.system(size: 14))
//                .foregroundColor(.secondary)
//                .padding(.horizontal, 20)
//                .padding(.top, -15)
//            
//            Chart {
//                ForEach(segments) { segment in
//                    BarMark(
//                        x: .value("Category", segment.name),
//                        y: .value("Minutes", segment.minutes)
//                    )
//                    .foregroundStyle(segment.color)
//                    .cornerRadius(4)
//                }
//            }
//            .chartYAxis {
//                AxisMarks(values: [0, 10, 20]) { value in
//                    AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [4]))
//                    AxisValueLabel()
//                }
//            }
//            .chartXAxis(.hidden)
//            .chartLegend(.hidden)
//            .frame(height: 180)
//            .padding(24)
//            .background(Color.white)
//            .cornerRadius(18)
//            .padding(.horizontal, 20)
//            
//            // Legend / Progress
//            VStack(alignment: .leading, spacing: 16) {
//                ForEach(segments) { segment in
//                    HStack {
//                        Circle().fill(segment.color).frame(width: 8, height: 8)
//                        Text(segment.name)
//                            .font(.system(size: 16))
//                        Spacer()
//                        Text("\(segment.minutes)/\(segment.target) min")
//                            .font(.system(size: 16))
//                    }
//                }
//            }
//            .padding(.horizontal, 24)
//            .padding(.top, 10)
//            
//            Spacer()
//        }
//        .background(Color.hcCream.ignoresSafeArea())
//        .navigationTitle("Mindful Minutes")
//        .navigationBarTitleDisplayMode(.inline)
//        .navigationBarBackButtonHidden(true)
//        .toolbar {
//            ToolbarItem(placement: .navigationBarLeading) {
//                Button { dismiss() } label: {
//                    Image(systemName: "chevron.left")
//                        .foregroundColor(.black)
//                        .padding(8)
//                        .background(Color.white)
//                        .clipShape(Circle())
//                }
//            }
//        }
//        .onAppear {
//            let plan = store.activePlan
//            let yogaTarget = plan?.yogaMinutesPerDay ?? 10
//            let breathTarget = plan?.meditationMinutesPerDay ?? 5
//            
//            let totalMins = mindEaseStore.todaysMindfulMinutes()
//            segments = [
//                MindfulSegment(name: "Relaxing Sounds", color: .teal, minutes: min(5, totalMins / 3), target: 5),
//                MindfulSegment(name: "Yoga", color: .red, minutes: totalMins / 2, target: yogaTarget),
//                MindfulSegment(name: "Meditation", color: .blue.opacity(0.5), minutes: totalMins / 4, target: breathTarget)
//            ]
//        }
//    }
//}
