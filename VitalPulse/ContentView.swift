//
//  ContentView.swift
//  VitalPulse
//
//  Created by Panos Kontopoulos on 19/9/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var healthKitManager = HealthKitManager()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if healthKitManager.isAuthorized {
                    VStack(spacing: 16) {
                        HealthMetricCard(
                            title: "Steps Today",
                            value: "\(healthKitManager.stepCount)",
                            icon: "figure.walk",
                            color: .blue
                        )
                        
                        HealthMetricCard(
                            title: "Heart Rate",
                            value: healthKitManager.heartRate > 0 ? "\(Int(healthKitManager.heartRate)) BPM" : "No data",
                            icon: "heart.fill",
                            color: .red
                        )
                        
                        Button("Refresh Data") {
                            healthKitManager.fetchHealthData()
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top)
                    }
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "heart.text.square")
                            .font(.system(size: 60))
                            .foregroundColor(.red)
                        
                        Text("HealthKit Access Required")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Please allow access to your health data to view your vital signs.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .navigationTitle("VitalPulse")
        }
    }
}

struct HealthMetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    ContentView()
}
