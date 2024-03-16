//
//  SettingScreen.swift
//  Toothy
//
//  Created by Kruize Christensen on 3/15/24.
//

import SwiftUI

struct SettingsScreen: View {
    @AppStorage("teethBrushingPermission") var teethBrushingPermission = true
    @AppStorage("otherTeethBrushingPermission") var otherTeethBrushingPermission = true

    var body: some View {
        VStack {
            Toggle(isOn: $teethBrushingPermission) {
                Text("Teeth Brushing Apple Health")
            }
            .toggleStyle(SwitchToggleStyle(tint: .red))
            .padding()

            Toggle(isOn: $otherTeethBrushingPermission) {
                Text("Other Teeth Brushing Option")
            }
            .toggleStyle(SwitchToggleStyle(tint: .red))
            .padding()
        }
    }
}
