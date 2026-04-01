//
//  SwiftUIView.swift
//  HairCureMainApp
//
//  Created by Avnish Singh on 3/25/26.
//

import SwiftUI

struct ScrollTransitionPreview: View {
    // Sample data for the cards
    let colors: [Color] = [.blue, .purple, .pink, .orange, .red, .green, .teal]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(0..<20) { index in
                    RoundedRectangle(cornerRadius: 25)
                        .fill(colors[index % colors.count].gradient)
                        .frame(height: 200)
                        .overlay {
                            Text("Card \(index + 1)")
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal)
                        
                        // MARK: - The Transition Logic
                        .scrollTransition(.animated.threshold(.visible(0.3))) { c, p in
                            c.opacity(p.isIdentity ? 1 : 0).offset(y: p.isIdentity ? 0 : -10)
                        }

                        
                }
            }
            .padding(.vertical)
        }
    }
}

#Preview {
    ScrollTransitionPreview()
}
