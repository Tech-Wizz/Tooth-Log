//
//  ContentView.swift
//  Toothy
//
//  Created by Kruize Christensen on 3/13/24.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    @State private var progressValue: Float = 1.0
    @State private var totalTime: Int = 300 // 5 minutes
    @State private var timeLeft: Int = 300 // Initially, timeLeft is equal to totalTime
    @State private var isTimerRunning: Bool = false // Indicates if the timer is running
    @State private var minutes: Int = 2
    @State private var seconds: Int = 0
    @State private var showLogTimeAlert: Bool = false // Controls whether to show the alert
    @State private var showSettingsScreen: Bool = false // Controls whether to show the settings screen
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationView {
            VStack {
                if isTimerRunning {
                    Text(timeString(time: timeLeft))
                        .font(.title)
                        .padding(.bottom, 20)
                } else {
                    TimePicker(minutes: $minutes, seconds: $seconds)
                }
                
                ProgressBar(progress: $progressValue)
                    .frame(width: 160.0, height: 160.0)
                    .padding(20.0)
                
                Button(action: {
                    if isTimerRunning {
                        stopTimer()
                    } else {
                        startTimer()
                    }
                }) {
                    Text(isTimerRunning ? "Stop" : "Start")
                }
            }
            .navigationBarItems(trailing:
                Button(action: {
                    showSettingsScreen = true
                }) {
                    Image(systemName: "gearshape")
                }
            )
            .onReceive(timer) { _ in
                if self.isTimerRunning && self.timeLeft > 0 {
                    self.timeLeft -= 1
                    self.progressValue = Float(self.timeLeft) / Float(self.totalTime)
                } else if self.timeLeft == 0 {
                    stopTimer()
                    showLogTimeAlert = true
                }
            }
            .alert(isPresented: $showLogTimeAlert) {
                Alert(
                    title: Text("Log Brushing Time"),
                    message: Text("Do you want to log this time for brushing teeth in Apple Health?"),
                    primaryButton: .default(Text("Yes")) {
                        logTimeInHealth()
                        timeLeft = totalTime
                        resetTimer()
                    },
                    secondaryButton: .cancel(Text("No")) {
                        timeLeft = totalTime
                        resetTimer()
                    }
                )
            }
            .sheet(isPresented: $showSettingsScreen) {
                SettingsScreen()
            }
        }
    }
    
    func timeString(time: Int) -> String {
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func startTimer() {
        self.isTimerRunning = true
        self.totalTime = minutes * 60 + seconds
        self.timeLeft = totalTime
    }
    
    func stopTimer() {
        self.isTimerRunning = false
    }
    
    func resetTimer() {
        minutes = 2
        seconds = 0
        progressValue = 1.0
    }
    
    func logTimeInHealth() {
        print("Time logged in Apple Health")
        // Code to log time in Apple Health goes here
    }
}

struct ProgressBar: View {
    @Binding var progress: Float
    var color: Color = Color.green
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 20.0)
                .opacity(0.20)
                .foregroundColor(Color.gray)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(progress))
                .stroke(style: StrokeStyle(lineWidth: 12.0, lineCap: .round, lineJoin: .round))
                .foregroundColor(color)
                .rotationEffect(Angle(degrees: -90)) // orientation
                .animation(.easeInOut(duration: 0.2))
        }
    }
}

struct TimePicker: View {
    @Binding var minutes: Int
    @Binding var seconds: Int
    
    var body: some View {
        HStack {
            Picker(selection: $minutes, label: Text("Minutes")) {
                ForEach(0..<11) { minute in
                    Text("\(minute) min").tag(minute)
                }
            }
            .pickerStyle(WheelPickerStyle())
            
            Picker(selection: $seconds, label: Text("Seconds")) {
                ForEach(0..<60) { second in
                    Text("\(second) sec").tag(second)
                }
            }
            .pickerStyle(WheelPickerStyle())
        }
    }
}

struct SettingsScreen: View {
    var body: some View {
        Text("Settings Screen")
    }
}

#Preview {
    ContentView()
}
