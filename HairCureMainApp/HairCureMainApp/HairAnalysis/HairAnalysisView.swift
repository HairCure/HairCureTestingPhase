//
//  HairAnalysisView.swift
//  HairCure
//
//  Photo upload screen — Path A UI.
//  MOCK: "Continue" shows a 1.4s spinner then goes to FallbackAssessmentView.
//  PRODUCTION: replace analyzeButtonTapped() body with real ML model call.
//  5 slots: Front · Back · Left · Right · Top
//

import SwiftUI
import PhotosUI

private struct PhotoSlot: Identifiable {
    let id: String
    let label: String
    var image: UIImage? = nil
}

struct HairAnalysisView: View {
    let onComplete: () -> Void

    @Environment(AppDataStore.self) private var store

    @State private var slots: [PhotoSlot] = [
        PhotoSlot(id: "front", label: "Front View"),
        PhotoSlot(id: "back",  label: "Back View"),
        PhotoSlot(id: "left",  label: "Left View"),
        PhotoSlot(id: "right", label: "Right View"),
        PhotoSlot(id: "top",   label: "Top View")
    ]

    @State private var activeSlotId: String?
    @State private var showingPicker  = false
    @State private var isAnalyzing    = false
    @State private var showFallback   = false

    var body: some View {
        ZStack {
            Color.hcCream.ignoresSafeArea()

            VStack(spacing: 0) {
                navBar
                    .padding(.top, 8)

                Text("Take clear photos of your scalp from all angles for accurate density analysis")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        ForEach(0..<slots.count, id: \.self) { i in
                            photoCard(index: i)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }

            // Continue pinned at bottom
            VStack {
                Spacer()
                Button { analyzeButtonTapped() } label: {
                    Text("Continue")
                        .hcPrimaryButton()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 36)
            }

            if isAnalyzing { analyzingOverlay }
        }
        .sheet(isPresented: $showingPicker) {
            pickerSheet
        }
        .fullScreenCover(isPresented: $showFallback) {
            FallbackAssessmentView(onComplete: onComplete)
        }
    }

    // ── Nav bar ──
    private var navBar: some View {
        HStack {
            HCBackButton { goToFallback() }
            Spacer()
            Text("Upload Scalp Photos")
                .font(.system(size: 18, weight: .bold))
            Spacer()
            Button("Skip") { goToFallback() }
                .font(.system(size: 16))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 16)
    }

    // ── Photo card ──
    private func photoCard(index i: Int) -> some View {
        let slot = slots[i]
        return VStack(alignment: .leading, spacing: 10) {
            Text(slot.label)
                .font(.system(size: 15, weight: .semibold))

            Button {
                activeSlotId  = slot.id
                showingPicker = true
            } label: {
                ZStack {
                    if let img = slot.image {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity).frame(height: 180)
                            .clipped().cornerRadius(10)
                        VStack {
                            HStack {
                                Spacer()
                                Image(systemName: "eye.fill")
                                    .font(.system(size: 18)).foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.black.opacity(0.45))
                                    .clipShape(Circle())
                                    .padding(10)
                            }
                            Spacer()
                        }
                    } else {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                            .foregroundColor(Color(.systemGray4))
                            .frame(maxWidth: .infinity).frame(height: 180)
                            .background(Color.white.opacity(0.5).cornerRadius(10))
                        Image(systemName: "camera")
                            .font(.system(size: 32))
                            .foregroundColor(Color(.systemGray3))
                    }
                }
            }
            .buttonStyle(.plain)

            HStack {
                Text(slot.image != nil ? "Tap to upload" : "Tap to upload  or  Take a Photo")
                    .font(.system(size: 13)).foregroundColor(.secondary)
                Spacer()
                Button {
                    slots[i].image = nil
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14)).foregroundColor(.secondary)
                }
            }
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(.systemGray5), lineWidth: 1))
    }

    // ── Analyzing overlay ──
    private var analyzingOverlay: some View {
        ZStack {
            Color.black.opacity(0.45).ignoresSafeArea()
            VStack(spacing: 20) {
                ProgressView().scaleEffect(1.4).tint(.white)
                Text("Analyzing your scalp…")
                    .font(.system(size: 16, weight: .medium)).foregroundColor(.white)
            }
            .padding(36)
            .background(Color(red: 0.15, green: 0.1, blue: 0.1).opacity(0.92))
            .cornerRadius(20)
        }
    }

    // ── Photo picker sheet ──
    @ViewBuilder
    private var pickerSheet: some View {
        if let slotId = activeSlotId,
           let idx = slots.firstIndex(where: { $0.id == slotId }) {
            _PhotoPickerSheet(slotLabel: slots[idx].label) { image in
                slots[idx].image = image
                showingPicker    = false
                activeSlotId     = nil
            } onDismiss: {
                showingPicker = false
                activeSlotId  = nil
            }
        }
    }

    // ── Actions ──

    /// MOCK: 1.4s spinner → Path B.
    /// PRODUCTION: replace with ML model call; only fall through on failure.
    private func analyzeButtonTapped() {
        isAnalyzing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            isAnalyzing = false
            goToFallback()
        }
    }

    private func goToFallback() {
        showFallback = true
    }
}

// ── Photos picker wrapper ──
private struct _PhotoPickerSheet: View {
    let slotLabel: String
    let onImageSelected: (UIImage) -> Void
    let onDismiss: () -> Void

    @State private var pickerItem: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            PhotosPicker(selection: $pickerItem, matching: .images) {
                VStack(spacing: 16) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 48)).foregroundColor(Color.hcBrown)
                    Text("Select photo for \(slotLabel)")
                        .font(.system(size: 16)).foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle(slotLabel)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onDismiss)
                }
            }
            .onChange(of: pickerItem) { _, newItem in
                guard let item = newItem else { return }
                Task {
                    if let data  = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        await MainActor.run { onImageSelected(image) }
                    }
                }
            }
        }
    }
}
