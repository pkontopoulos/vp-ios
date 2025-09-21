import HealthKit
import Foundation
import Combine

class HealthKitManager: ObservableObject {
    private let healthStore = HKHealthStore()
    
    @Published var stepCount: Int = 0
    @Published var heartRate: Double = 0
    @Published var activeEnergyBurned: Double = 0
    @Published var exerciseTime: Double = 0
    @Published var standMinutes: Double = 0
    @Published var heartRateVariability: Double = 0
    @Published var sleepTime: Double = 0
    @Published var isAuthorized: Bool = false
    
    init() {
        checkHealthKitAuthorization()
    }
    
    private func checkHealthKitAuthorization() {
        print("🏥 Checking HealthKit authorization...")
        guard HKHealthStore.isHealthDataAvailable() else {
            print("❌ HealthKit is not available on this device")
            return
        }
        
        print("✅ HealthKit is available, requesting access...")
        requestHealthKitAccess()
    }
    
    private func requestHealthKitAccess() {
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!,
            HKObjectType.quantityType(forIdentifier: .appleStandTime)!,
            HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
        ]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            print("🔐 HealthKit authorization result: \(success)")
            DispatchQueue.main.async {
                self.isAuthorized = success
                if success {
                    print("✅ Authorization granted, fetching data...")
                    self.fetchHealthData()
                } else {
                    print("❌ Authorization denied")
                }
                if let error = error {
                    print("HealthKit authorization error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func fetchHealthData() {
        fetchStepCount()
        fetchLatestHeartRate()
        fetchActiveEnergyBurned()
        fetchExerciseTime()
        fetchStandMinutes()
        fetchHeartRateVariability()
        fetchSleepTime()
    }
    
    private func fetchStepCount() {
        guard let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) else { return }
        
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )
        
        let query = HKStatisticsQuery(
            quantityType: stepType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                print("Failed to fetch step count: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            DispatchQueue.main.async {
                self.stepCount = Int(sum.doubleValue(for: HKUnit.count()))
            }
        }
        
        healthStore.execute(query)
    }
    
    private func fetchLatestHeartRate() {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else { return }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(
            sampleType: heartRateType,
            predicate: nil,
            limit: 1,
            sortDescriptors: [sortDescriptor]
        ) { _, samples, error in
            guard let sample = samples?.first as? HKQuantitySample else {
                print("Failed to fetch heart rate: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            DispatchQueue.main.async {
                self.heartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            }
        }
        
        healthStore.execute(query)
    }
    
    private func fetchActiveEnergyBurned() {
        guard let activeEnergyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else { return }
        
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )
        
        let query = HKStatisticsQuery(
            quantityType: activeEnergyType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                print("Failed to fetch active energy burned: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            DispatchQueue.main.async {
                self.activeEnergyBurned = sum.doubleValue(for: HKUnit.kilocalorie())
            }
        }
        
        healthStore.execute(query)
    }
    
    private func fetchExerciseTime() {
        guard let exerciseTimeType = HKObjectType.quantityType(forIdentifier: .appleExerciseTime) else { return }
        
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )
        
        let query = HKStatisticsQuery(
            quantityType: exerciseTimeType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                print("Failed to fetch exercise time: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            DispatchQueue.main.async {
                self.exerciseTime = sum.doubleValue(for: HKUnit.minute())
            }
        }
        
        healthStore.execute(query)
    }
    
    private func fetchStandMinutes() {
        guard let standTimeType = HKObjectType.quantityType(forIdentifier: .appleStandTime) else { return }
        
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )
        
        let query = HKStatisticsQuery(
            quantityType: standTimeType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                print("Failed to fetch stand minutes: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            DispatchQueue.main.async {
                self.standMinutes = sum.doubleValue(for: HKUnit.minute())
            }
        }
        
        healthStore.execute(query)
    }
    
    private func fetchHeartRateVariability() {
        guard let hrvType = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else { return }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(
            sampleType: hrvType,
            predicate: nil,
            limit: 1,
            sortDescriptors: [sortDescriptor]
        ) { _, samples, error in
            guard let sample = samples?.first as? HKQuantitySample else {
                print("Failed to fetch heart rate variability: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            DispatchQueue.main.async {
                self.heartRateVariability = sample.quantity.doubleValue(for: HKUnit.secondUnit(with: .milli))
            }
        }
        
        healthStore.execute(query)
    }
    
    private func fetchSleepTime() {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return }
        
        let calendar = Calendar.current
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        
        // Get sleep data from 6 PM yesterday to 2 PM today to capture last night's sleep
        let startOfYesterday = calendar.startOfDay(for: calendar.date(byAdding: .day, value: -1, to: now)!)
        let sleepWindowStart = calendar.date(byAdding: .hour, value: 18, to: startOfYesterday)! // 6 PM yesterday
        let sleepWindowEnd = calendar.date(byAdding: .hour, value: 14, to: startOfToday)! // 2 PM today
        
        print("🌙 Fetching sleep data from \(sleepWindowStart) to \(sleepWindowEnd)")
        
        let predicate = HKQuery.predicateForSamples(
            withStart: sleepWindowStart,
            end: sleepWindowEnd,
            options: .strictStartDate
        )
        
        let query = HKSampleQuery(
            sampleType: sleepType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: nil
        ) { _, samples, error in
            guard let samples = samples as? [HKCategorySample] else {
                print("Failed to fetch sleep time: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            print("📊 Found \(samples.count) sleep samples in the specified window")
            for sample in samples {
                let duration = sample.endDate.timeIntervalSince(sample.startDate) / 3600.0
                let stage = self.sleepStageDescription(for: sample.value)
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM dd HH:mm"
                print("Sleep stage: \(stage), Duration: \(String(format: "%.2f", duration)) hours, From: \(formatter.string(from: sample.startDate)) to \(formatter.string(from: sample.endDate))")
            }
            
            let sleepSamples = samples.filter { sample in
                sample.value == HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue ||
                sample.value == HKCategoryValueSleepAnalysis.asleepCore.rawValue ||
                sample.value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue ||
                sample.value == HKCategoryValueSleepAnalysis.asleepREM.rawValue
            }
            
            let totalSleepTime = sleepSamples.reduce(0.0) { total, sample in
                total + sample.endDate.timeIntervalSince(sample.startDate)
            }
            
            print("💤 Total sleep time calculated: \(String(format: "%.2f", totalSleepTime / 3600.0)) hours from \(sleepSamples.count) sleep stages")
            
            DispatchQueue.main.async {
                self.sleepTime = totalSleepTime / 3600.0 // Convert to hours
            }
        }
        
        healthStore.execute(query)
    }
    
    private func sleepStageDescription(for value: Int) -> String {
        switch value {
        case HKCategoryValueSleepAnalysis.inBed.rawValue:
            return "In Bed"
        case HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue:
            return "Asleep (Unspecified)"
        case HKCategoryValueSleepAnalysis.awake.rawValue:
            return "Awake"
        case HKCategoryValueSleepAnalysis.asleepCore.rawValue:
            return "Core Sleep"
        case HKCategoryValueSleepAnalysis.asleepDeep.rawValue:
            return "Deep Sleep"
        case HKCategoryValueSleepAnalysis.asleepREM.rawValue:
            return "REM Sleep"
        default:
            return "Unknown (\(value))"
        }
    }
}
