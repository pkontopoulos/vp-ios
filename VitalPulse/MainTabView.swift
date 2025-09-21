//
//  MainTabView.swift
//  VitalPulse
//
//  Created by Panos Kontopoulos on 21/9/25.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            TodayMetricsView()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Today's Metrics")
                }
            
            ExportView()
                .tabItem {
                    Image(systemName: "square.and.arrow.up")
                    Text("Export")
                }
        }
    }
}

#Preview {
    MainTabView()
}