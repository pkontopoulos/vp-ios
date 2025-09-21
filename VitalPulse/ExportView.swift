//
//  ExportView.swift
//  VitalPulse
//
//  Created by Panos Kontopoulos on 21/9/25.
//

import SwiftUI

struct ShareableFile: Identifiable {
    let id = UUID()
    let url: URL
}

struct ExportView: View {
    @StateObject private var healthKitManager = HealthKitManager()
    @State private var selectedTab = 0
    @State private var startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
    @State private var endDate = Date()
    @State private var isExporting = false
    @State private var csvFileURL: URL?
    @State private var exportStatus = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if healthKitManager.isAuthorized {
                    Picker("Export Type", selection: $selectedTab) {
                        Text("Date Presets").tag(0)
                        Text("Custom Dates").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    TabView(selection: $selectedTab) {
                        DatePresetsView(
                            healthKitManager: healthKitManager,
                            isExporting: $isExporting,
                            exportStatus: $exportStatus,
                            csvFileURL: $csvFileURL
                        )
                        .tag(0)
                        
                        CustomDatesView(
                            healthKitManager: healthKitManager,
                            startDate: $startDate,
                            endDate: $endDate,
                            isExporting: $isExporting,
                            exportStatus: $exportStatus,
                            csvFileURL: $csvFileURL
                        )
                        .tag(1)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "heart.text.square")
                            .font(.system(size: 60))
                            .foregroundColor(.red)
                        
                        Text("HealthKit Access Required")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Please allow access to your health data to export your metrics.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
            }
            .navigationTitle("Export Data")
            .sheet(item: Binding<ShareableFile?>(
                get: { csvFileURL.map { ShareableFile(url: $0) } },
                set: { _ in 
                    csvFileURL = nil
                    exportStatus = ""
                }
            )) { file in
                ShareSheet(activityItems: [file.url])
            }
        }
    }
}

struct DatePresetsView: View {
    let healthKitManager: HealthKitManager
    @Binding var isExporting: Bool
    @Binding var exportStatus: String
    @Binding var csvFileURL: URL?
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Select a date range to automatically export")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            List {
                ForEach(DatePreset.allCases, id: \.self) { preset in
                    PresetRow(
                        preset: preset,
                        isExporting: isExporting,
                        action: { exportData(for: preset) }
                    )
                }
            }
            .listStyle(.plain)
            
            if isExporting {
                VStack(spacing: 8) {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Exporting...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            
            if !exportStatus.isEmpty && !isExporting {
                Text(exportStatus)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .padding(.top)
    }
    
    private func exportData(for preset: DatePreset) {
        let dateRange = preset.dateRange()
        exportData(startDate: dateRange.start, endDate: dateRange.end, presetName: preset.rawValue)
    }
    
    private func exportData(startDate: Date, endDate: Date, presetName: String) {
        isExporting = true
        exportStatus = "Fetching health data for \(presetName)..."
        
        healthKitManager.fetchHealthDataForDateRange(startDate: startDate, endDate: endDate) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.exportStatus = "Generating CSV file..."
                    self.generateCSV(from: data, startDate: startDate, endDate: endDate, presetName: presetName)
                case .failure(let error):
                    self.exportStatus = "Export failed: \(error.localizedDescription)"
                    self.isExporting = false
                }
            }
        }
    }
    
    private func generateCSV(from data: [HealthDataEntry], startDate: Date, endDate: Date, presetName: String) {
        let csvHeader = "Date,Steps,Heart Rate (BPM),Active Energy (cal),Exercise Time (min),Stand Minutes,HRV (ms),Walking Distance (km),Swimming Distance (km)\n"
        
        let csvContent = data.map { entry in
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let dateString = formatter.string(from: entry.date)
            
            return "\(dateString),\(entry.stepCount),\(entry.heartRate),\(Int(entry.activeEnergyBurned)),\(Int(entry.exerciseTime)),\(Int(entry.standMinutes)),\(Int(entry.heartRateVariability)),\(String(format: "%.2f", entry.walkingRunningDistance)),\(String(format: "%.2f", entry.swimmingDistance))"
        }.joined(separator: "\n")
        
        let fullCSV = csvHeader + csvContent
        
        let fileName = "VitalPulse_\(presetName.replacingOccurrences(of: " ", with: "_"))_\(formatDate(startDate))_to_\(formatDate(endDate)).csv"
        
        do {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsPath.appendingPathComponent(fileName)
            
            try fullCSV.write(to: fileURL, atomically: true, encoding: .utf8)
            
            self.csvFileURL = fileURL
            self.exportStatus = "Export successful! \(data.count) days exported for \(presetName)."
            
            // File URL is set and will automatically trigger the sheet
        } catch {
            self.exportStatus = "Failed to save CSV file: \(error.localizedDescription)"
        }
        
        self.isExporting = false
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

struct PresetRow: View {
    let preset: DatePreset
    let isExporting: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: preset.icon)
                    .font(.title3)
                    .foregroundColor(.blue)
                    .frame(width: 24, height: 24)
                
                Text(preset.rawValue)
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(height: 44)
            .contentShape(Rectangle())
        }
        .disabled(isExporting)
        .opacity(isExporting ? 0.6 : 1.0)
        .buttonStyle(.plain)
    }
}

struct CustomDatesView: View {
    let healthKitManager: HealthKitManager
    @Binding var startDate: Date
    @Binding var endDate: Date
    @Binding var isExporting: Bool
    @Binding var exportStatus: String
    @Binding var csvFileURL: URL?
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Select Custom Date Range")
                    .font(.headline)
                    .padding(.horizontal)
                
                VStack(spacing: 16) {
                    HStack {
                        Text("Start Date:")
                            .frame(width: 80, alignment: .leading)
                        DatePicker("", selection: $startDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Text("End Date:")
                            .frame(width: 80, alignment: .leading)
                        DatePicker("", selection: $endDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                    }
                    .padding(.horizontal)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
            }
            
            Button(action: exportCustomData) {
                HStack {
                    if isExporting {
                        ProgressView()
                            .scaleEffect(0.8)
                            .padding(.trailing, 4)
                    } else {
                        Image(systemName: "square.and.arrow.up")
                            .padding(.trailing, 4)
                    }
                    Text(isExporting ? "Exporting..." : "Export to CSV")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(startDate <= endDate ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(isExporting || startDate > endDate)
            .padding(.horizontal)
            
            if !exportStatus.isEmpty {
                Text(exportStatus)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding(.top)
    }
    
    private func exportCustomData() {
        guard startDate <= endDate else { return }
        
        isExporting = true
        exportStatus = "Fetching health data..."
        
        healthKitManager.fetchHealthDataForDateRange(startDate: startDate, endDate: endDate) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.exportStatus = "Generating CSV file..."
                    self.generateCSV(from: data)
                case .failure(let error):
                    self.exportStatus = "Export failed: \(error.localizedDescription)"
                    self.isExporting = false
                }
            }
        }
    }
    
    private func generateCSV(from data: [HealthDataEntry]) {
        let csvHeader = "Date,Steps,Heart Rate (BPM),Active Energy (cal),Exercise Time (min),Stand Minutes,HRV (ms),Walking Distance (km),Swimming Distance (km)\n"
        
        let csvContent = data.map { entry in
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let dateString = formatter.string(from: entry.date)
            
            return "\(dateString),\(entry.stepCount),\(entry.heartRate),\(Int(entry.activeEnergyBurned)),\(Int(entry.exerciseTime)),\(Int(entry.standMinutes)),\(Int(entry.heartRateVariability)),\(String(format: "%.2f", entry.walkingRunningDistance)),\(String(format: "%.2f", entry.swimmingDistance))"
        }.joined(separator: "\n")
        
        let fullCSV = csvHeader + csvContent
        
        let fileName = "VitalPulse_Custom_\(formatDate(startDate))_to_\(formatDate(endDate)).csv"
        
        do {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsPath.appendingPathComponent(fileName)
            
            try fullCSV.write(to: fileURL, atomically: true, encoding: .utf8)
            
            self.csvFileURL = fileURL
            self.exportStatus = "Export successful! \(data.count) days exported."
            
            // File URL is set and will automatically trigger the sheet
        } catch {
            self.exportStatus = "Failed to save CSV file: \(error.localizedDescription)"
        }
        
        self.isExporting = false
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ExportView()
}