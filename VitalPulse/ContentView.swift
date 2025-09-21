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
            VStack(alignment: .leading, spacing: 20) {
                if healthKitManager.isAuthorized {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        HealthMetricCard(
                            title: "Steps Today",
                            value: "\(healthKitManager.stepCount)",
                            icon: "figure.walk",
                            color: .blue
                        )
                        
                        HealthMetricCard(
                            title: "Active Energy",
                            value: healthKitManager.activeEnergyBurned > 0 ? "\(Int(healthKitManager.activeEnergyBurned)) cal" : "No data",
                            icon: "flame.fill",
                            color: .orange
                        )
                        
                        HealthMetricCard(
                            title: "Stand Minutes",
                            value: healthKitManager.standMinutes > 0 ? "\(Int(healthKitManager.standMinutes)) min" : "No data",
                            icon: "figure.stand",
                            color: .purple
                        )
                        
                        HealthMetricCard(
                            title: "Exercise Time",
                            value: healthKitManager.exerciseTime > 0 ? "\(Int(healthKitManager.exerciseTime)) min" : "No data",
                            icon: "stopwatch.fill",
                            color: .green
                        )
                        
                        HealthMetricCard(
                            title: "Heart Rate",
                            value: healthKitManager.heartRate > 0 ? "\(Int(healthKitManager.heartRate)) BPM" : "No data",
                            icon: "heart.fill",
                            color: .red
                        )
                        
                        HealthMetricCard(
                            title: "Heart Rate Variability",
                            value: healthKitManager.heartRateVariability > 0 ? "\(Int(healthKitManager.heartRateVariability)) ms" : "No data",
                            icon: "waveform.path.ecg",
                            color: .pink
                        )
                        
                        HealthMetricCard(
                            title: "Walking + Running",
                            value: healthKitManager.walkingRunningDistance > 0 ? String(format: "%.2f km", healthKitManager.walkingRunningDistance) : "No data",
                            icon: "figure.walk",
                            color: .teal
                        )
                        
                        HealthMetricCard(
                            title: "Swimming Distance",
                            value: healthKitManager.swimmingDistance > 0 ? String(format: "%.2f km", healthKitManager.swimmingDistance) : "No data",
                            icon: "figure.pool.swim",
                            color: .mint
                        )
                    }
                    
                    HStack {
                        Spacer()
                        Button("Refresh Data") {
                            healthKitManager.fetchHealthData()
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top)
                        Spacer()
                    }
                    
                    Spacer()
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
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        Image("VitalPulseIcon")
                            .resizable()
                            .frame(width: 48, height: 48)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        Text("VitalPulse")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                    .padding(.top, 40)
                }
            }
        }
    }
}

struct HealthMetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                Text(value)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    ContentView()
}
