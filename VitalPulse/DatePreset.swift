//
//  DatePreset.swift
//  VitalPulse
//
//  Created by Panos Kontopoulos on 21/9/25.
//

import Foundation

enum DatePreset: String, CaseIterable {
    case today = "Today"
    case yesterday = "Yesterday"
    case thisWeek = "This Week"
    case lastWeek = "Last Week"
    case thisMonth = "This Month"
    case lastMonth = "Last Month"
    case thisYear = "This Year"
    case lastYear = "Last Year"
    case last7Days = "Last 7 Days"
    case last14Days = "Last 14 Days"
    case last30Days = "Last 30 Days"
    case last365Days = "Last 365 Days"
    
    func dateRange() -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .today:
            let startOfDay = calendar.startOfDay(for: now)
            return (start: startOfDay, end: now)
            
        case .yesterday:
            let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
            let startOfYesterday = calendar.startOfDay(for: yesterday)
            let endOfYesterday = calendar.date(byAdding: .day, value: 1, to: startOfYesterday)!
            return (start: startOfYesterday, end: endOfYesterday)
            
        case .thisWeek:
            let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)!.start
            return (start: startOfWeek, end: now)
            
        case .lastWeek:
            let lastWeekStart = calendar.date(byAdding: .weekOfYear, value: -1, to: now)!
            let weekInterval = calendar.dateInterval(of: .weekOfYear, for: lastWeekStart)!
            return (start: weekInterval.start, end: weekInterval.end)
            
        case .thisMonth:
            let startOfMonth = calendar.dateInterval(of: .month, for: now)!.start
            return (start: startOfMonth, end: now)
            
        case .lastMonth:
            let lastMonthStart = calendar.date(byAdding: .month, value: -1, to: now)!
            let monthInterval = calendar.dateInterval(of: .month, for: lastMonthStart)!
            return (start: monthInterval.start, end: monthInterval.end)
            
        case .thisYear:
            let startOfYear = calendar.dateInterval(of: .year, for: now)!.start
            return (start: startOfYear, end: now)
            
        case .lastYear:
            let lastYearStart = calendar.date(byAdding: .year, value: -1, to: now)!
            let yearInterval = calendar.dateInterval(of: .year, for: lastYearStart)!
            return (start: yearInterval.start, end: yearInterval.end)
            
        case .last7Days:
            let startDate = calendar.date(byAdding: .day, value: -7, to: now)!
            return (start: calendar.startOfDay(for: startDate), end: now)
            
        case .last14Days:
            let startDate = calendar.date(byAdding: .day, value: -14, to: now)!
            return (start: calendar.startOfDay(for: startDate), end: now)
            
        case .last30Days:
            let startDate = calendar.date(byAdding: .day, value: -30, to: now)!
            return (start: calendar.startOfDay(for: startDate), end: now)
            
        case .last365Days:
            let startDate = calendar.date(byAdding: .day, value: -365, to: now)!
            return (start: calendar.startOfDay(for: startDate), end: now)
        }
    }
    
    var icon: String {
        switch self {
        case .today:
            return "calendar.circle"
        case .yesterday:
            return "calendar.circle.fill"
        case .thisWeek, .lastWeek:
            return "calendar.badge.clock"
        case .thisMonth, .lastMonth:
            return "calendar"
        case .thisYear, .lastYear:
            return "calendar.badge.plus"
        case .last7Days, .last14Days, .last30Days, .last365Days:
            return "clock.arrow.circlepath"
        }
    }
}