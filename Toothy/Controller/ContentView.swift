//
//  ContentView.swift
//  Toothy
//
//  Created by Kruize Christensen on 3/13/24.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    @StateObject private var timerModel = BrushingTimerModel()
    @State private var minutes: Int = 2
    @State private var seconds: Int = 0
    @State private var showLogTimeAlert: Bool = false
    @State private var showSettingsScreen: Bool = false
    @State private var progress: Float = 1.0
    @State private var authenticated = false
    @State private var trigger = false

    let allTypes: Set<HKSampleType> = [HKSampleType.categoryType(forIdentifier: .toothbrushingEvent)!]

    @State var healthStore = HKHealthStore()
    @State var authorized = false

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    if timerModel.isTimerRunning {
                        Text(timeString(time: timerModel.timeLeft))
                            .font(.title)
                            .padding(.bottom, 20)
                    } else {
                        TimePicker(minutes: $minutes, seconds: $seconds)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 100)

                Spacer()

                VStack {
                    ProgressBar(progress: $progress)
                        .frame(width: 160.0, height: 160.0)
                        .padding(20.0)

                    Button(action: {
                        if timerModel.isTimerRunning {
                            timerModel.stopTimer()
                        } else {
                            timerModel.startTimer(minutes: minutes, seconds: seconds)
                        }
                    }) {
                        Text(timerModel.isTimerRunning ? "Stop" : "Start")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 100)
            }
            .navigationBarItems(trailing:
                Button(action: {
                    showSettingsScreen = true
                }) {
                    Image(systemName: "gearshape")
                }
            )
            .onReceive(timer) { _ in
                if timerModel.isTimerRunning && timerModel.timeLeft > 0 {
                    timerModel.timeLeft -= 1
                    progress = calculateProgress()
                } else if timerModel.timeLeft == 0 {
                    timerModel.stopTimer()
                    showLogTimeAlert = true
                }
            }
            .alert(isPresented: $showLogTimeAlert) {
                Alert(
                    title: Text("Log Brushing Time"),
                    message: Text("Do you want to log this time for brushing teeth in Apple Health?"),
                    primaryButton: .default(Text("Yes")) {
                        timerModel.resetTimer()
                        timerModel.saveBrushingTime(minutes: minutes, seconds: seconds)
                    },
                    secondaryButton: .cancel(Text("No")) {
                        timerModel.resetTimer()
                    }
                )
            }
            .sheet(isPresented: $showSettingsScreen) {
                SettingsScreen()
            }
            .onAppear {
                // Check if Health data is available
                if HKHealthStore.isHealthDataAvailable() {
                    // Enable the trigger to initiate the health data access request
                    trigger.toggle()
                }
            }
            .onAppear {
                requestAuthorization()
            }
        }
    }

    func timeString(time: Int) -> String {
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func calculateProgress() -> Float {
        return Float(timerModel.timeLeft) / Float(timerModel.totalTime)
    }

    func requestAuthorization() {
        if HKHealthStore.isHealthDataAvailable() {
            let allTypes = Set([HKSampleType.categoryType(forIdentifier: .toothbrushingEvent)!])
            healthStore.requestAuthorization(toShare: allTypes, read: allTypes) { (success, error) in
                DispatchQueue.main.async {
                    if success {
                        authorized = true
                    } else {
                        print("Authorization failed: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }
            }
        }
    }
}

#Preview {
        ContentView()
}
