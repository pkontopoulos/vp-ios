//
//  SplashView.swift
//  VitalPulse
//
//  Created by Panos Kontopoulos on 21/9/25.
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var opacity = 0.0
    @State private var scale = 0.8
    
    var body: some View {
        if isActive {
            MainTabView()
        } else {
            VStack(spacing: 24) {
                Spacer()
                
                Image("VitalPulseIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .scaleEffect(scale)
                    .opacity(opacity)
                
                Text("VitalPulse")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .opacity(opacity)
                
                Text("Your Health Data Companion")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .opacity(opacity)
                
                Spacer()
                
                // Loading indicator
                ProgressView()
                    .scaleEffect(1.2)
                    .opacity(opacity)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.white]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .onAppear {
                // Animate splash screen elements
                withAnimation(.easeIn(duration: 0.8)) {
                    opacity = 1.0
                    scale = 1.0
                }
                
                // Transition to main app after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView()
}
