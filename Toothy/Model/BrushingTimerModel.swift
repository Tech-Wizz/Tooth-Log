//
//  BrushingTimerModel.swift
//  Toothy
//
//  Created by Kruize Christensen on 3/15/24.
//

import HealthKit
import SwiftUI

class BrushingTimerModel: ObservableObject {
    let healthStore = HKHealthStore()

        @Published var totalTime: Int = 300 // 5 minutes
        @Published var timeLeft: Int = 300 // Initially, timeLeft is equal to totalTime
        @Published var isTimerRunning: Bool = false // Indicates if the timer is running
        @Published var isHealthKitAuthorized = false

        func startTimer(minutes: Int, seconds: Int) {
            // Start the timer
            self.isTimerRunning = true
            self.totalTime = minutes * 60 + seconds
            self.timeLeft = totalTime
        }

        func stopTimer() {
            // Stop the timer
            self.isTimerRunning = false
        }

        func resetTimer() {
            // Reset the timer
            self.isTimerRunning = false
            self.totalTime = 300
            self.timeLeft = 300
        }

        

        func requestAuthorization() {
            if HKHealthStore.isHealthDataAvailable() {
                let allTypes = Set([HKSampleType.categoryType(forIdentifier: .toothbrushingEvent)!])
                healthStore.requestAuthorization(toShare: allTypes, read: allTypes) { [weak self] (success, error) in
                    DispatchQueue.main.async {
                        if success {
                            self?.isHealthKitAuthorized = true
                        } else {
                            print("Authorization failed: \(error?.localizedDescription ?? "Unknown error")")
                        }
                    }
                }
            }
        }

        func saveBrushingTime(minutes: Int, seconds: Int) {
            let brushingType = HKCategoryType.categoryType(forIdentifier: .toothbrushingEvent)!
            let brushingValue = HKCategoryValue.notApplicable.rawValue // Use notApplicable for brushing time
            let startDate = Date()
            let durationInSeconds = Double(minutes * 60 + seconds) // Calculate duration from selected minutes and seconds
            let endDate = startDate.addingTimeInterval(durationInSeconds) // End time is start time + duration

            let brushingSample = HKCategorySample(type: brushingType, value: brushingValue, start: startDate, end: endDate)

            healthStore.save(brushingSample) { (success, error) in
                if let error = error {
                    print("Error saving brushing time to Apple Health: \(error.localizedDescription)")
                } else {
                    print("Brushing time saved successfully.")
                }
            }
        }
    }
