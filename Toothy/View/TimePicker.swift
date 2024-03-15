//
//  TimePicker.swift
//  Toothy
//
//  Created by Kruize Christensen on 3/15/24.
//

import SwiftUI

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
