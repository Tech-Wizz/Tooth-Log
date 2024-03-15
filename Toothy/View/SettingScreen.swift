//
//  SettingScreen.swift
//  Toothy
//
//  Created by Kruize Christensen on 3/15/24.
//

import SwiftUI

struct SettingsScreen: View {
    var body: some View {
        Toggle(isOn: .constant(true)) {
            Text("Teeth Brushing Apple Health")
        }
        .toggleStyle(SwitchToggleStyle(tint: .red))
        .padding()
    }
}

