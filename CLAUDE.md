# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

VitalPulse is a SwiftUI iOS app that displays health metrics from HealthKit including:
- Step count
- Heart rate
- Active energy burned
- Exercise time
- Stand minutes
- Heart rate variability (HRV)
- Sleep time

## Architecture

The app follows a simple SwiftUI MVVM pattern:

- **VitalPulseApp.swift**: Main app entry point
- **ContentView.swift**: Main UI displaying health metrics using `HealthMetricCard` components
- **HealthKitManager.swift**: ObservableObject that handles all HealthKit integration, data fetching, and authorization

### HealthKit Integration

The `HealthKitManager` class:
- Manages HealthKit authorization for step count, heart rate, active energy burned, exercise time, stand minutes, heart rate variability, and sleep analysis
- Fetches daily health data using HKStatisticsQuery and HKSampleQuery (HKCategorySample for sleep data)
- Updates @Published properties that automatically refresh the UI
- Includes comprehensive error handling and logging

### UI Components

- `HealthMetricCard`: Reusable card component displaying health metrics with icons and colors
- All health data displays "No data" when values are unavailable
- Manual refresh capability via "Refresh Data" button

## Build Commands

```bash
# Build for any iOS device
xcodebuild -project VitalPulse.xcodeproj -scheme VitalPulse -configuration Debug build

# Build for specific iOS simulator
xcodebuild -project VitalPulse.xcodeproj -scheme VitalPulse -configuration Debug -destination 'platform=iOS Simulator,arch=arm64,id=SIMULATOR_ID' build

# Syntax check Swift files
swiftc -parse VitalPulse/HealthKitManager.swift
swiftc -parse VitalPulse/ContentView.swift
```

## HealthKit Requirements

- HealthKit entitlements are configured in `VitalPulse.entitlements`
- The app requires iOS device with HealthKit support (not available in simulator for real data)
- Authorization is requested for: stepCount, heartRate, activeEnergyBurned, appleExerciseTime, appleStandTime, heartRateVariabilitySDNN, sleepAnalysis

## Development Notes

- Health data queries are scoped to the current day (start of day to now), except sleep data which queries from 6 PM yesterday to 2 PM today to capture last night's sleep
- All HealthKit operations are performed asynchronously with main thread UI updates
- Sleep data uses HKCategorySample and filters for actual sleep stages only (asleepUnspecified, asleepCore, asleepDeep, asleepREM) excluding "In Bed" and "Awake" time to match Health app totals
- Heart Rate Variability uses the latest available SDNN measurement in milliseconds
- The app includes extensive console logging for debugging HealthKit operations