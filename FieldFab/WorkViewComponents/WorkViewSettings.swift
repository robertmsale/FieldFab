//
//  WorkViewSettings.swift
//  FieldFab
//
//  Created by Robert Sale on 12/26/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI
import StringFix

struct WorkSettingsView: View {
    @Binding var data: Duct
    @EnvironmentObject var state: AppState
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Duct Data")) {
                    HStack {
                        Text("Session Name")
                        TextField("", text: Binding<String>(get: {state.currentWork?.data.name ?? ""}, set: {(v: String) in
                            state.currentWork?.data.name = v.replacingOccurrences(of: " ", with: "")
                        })).keyboardType(.namePhonePad)
                    }
//                    Toggle("Show Helpers", isOn: $state.showHelpers)
                }
                RendererSettings()
                Section(header: Text("Sharing")) {
                    Button(action: {
                        state.shareURL = state.currentWork?.data.toURL()
                    }, label: {Text("Share Ductwork")})
                }
            }
        }.navigationBarItems(trailing:
            HStack {
                Button(action: {
                    state.sheetsShown.about = true
                }, label: {Text("About")})
                Spacer()
                Button(action: {
                    state.sheetsShown.helpWeb = true
                }, label: {Image(systemName: "questionmark.circle")})
            }
        )
    }
}

#if DEBUG
struct WorkViewSettings_Previews: PreviewProvider {
    static var previews: some View {
//        WorkViewSettings()
        Text("Ayyyy")
    }
}
#endif
