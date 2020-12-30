//
//  SettingsSheet.swift
//  FieldFab
//
//  Created by Robert Sale on 12/19/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI

struct RendererSettings: View {
    @EnvironmentObject var state: AppState
    var body: some View {
        Section(header: Text("Renderer")) {
            HStack {
                Text("Texture")
                Spacer()
                Picker("", selection: $state.material, content: {
                    Text("Galvanized").tag("galvanized")
                    Text("Stainless").tag("metal")
                }).pickerStyle(SegmentedPickerStyle())
            }
            VStack {
                HStack {
                    Text("Lighting Method")
                    Spacer()
                    Picker("", selection: $state.lightingModel, content: {
                        ForEach(LightingModel.allCases) {l in
                            Text(l.rawValue).tag(l)
                        }
                    })//.pickerStyle(MenuPickerStyle())
                }
                Text("Physically Based is recommended for highest quality").font(.caption).foregroundColor(Color.gray)
                Text("Other settings may improve performance").font(.caption).foregroundColor(Color.gray)
            }
            VStack {
                Toggle(isOn: $state.showDebugInfo, label: {
                    Text("Show Debug Info")
                })
                Text("Displays useful metrics such as rendering FPS").font(.caption).foregroundColor(Color.gray)
            }
            Toggle("Show helpers", isOn: $state.showHelpers)
            VStack {
                HStack {
                    Text("Background")
                    Spacer()
                    Picker("\(state.sceneBGTexture == nil ? "Color" : "Image")", selection: Binding<Int>(get: {
                        state.sceneBGTexture == nil ? 0 : 1
                    }, set: {
                        if $0 == 0 { state.sceneBGTexture = nil }
                        else { state.sceneBGTexture = "TestBG" }
                    }), content: {
                        Text("Color").tag(0)
                        Text("Image").tag(1)
                    })//.pickerStyle(MenuPickerStyle())
                }
                if state.sceneBGTexture == nil {
                    ColorPicker("Background Color", selection: Binding<Color>(get: {
                        Color(state.sceneBGColor)
                    }, set: {
                        state.sceneBGColor = $0.cgColor ?? CGColor(red: 0, green: 0, blue: 1, alpha: 1)
                    }))
                }
            }
            VStack {
                Toggle("Energy Saver", isOn: $state.energySaver)
                Text("Turns off anti-aliasing and reduces GPU calls to only when necessary (Energy savings can be seen with debug info enabled)").font(.caption)
            }
        }
    }
}

struct SettingsPage: View {
    @EnvironmentObject var state: AppState
    var body: some View {
        Form {
            Section(header: Text("Defaults")) {
                HStack {
                    Text("Units of Measurement")
                    Spacer()
                    Picker("\(state.defaultUnits.string)", selection: $state.defaultUnits, content: {
                        ForEach(MeasurementUnits.allCases, content: {a in
                            Text(a.string).tag(a)
                        })
                    }).pickerStyle(MenuPickerStyle())
                }
            }
            RendererSettings()
        }
        .navigationBarTitle("Settings")
        .navigationBarItems(trailing:
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

struct SettingsPage_Previews: PreviewProvider {
    static var previews: some View {
        let appstate = AppState()
        return SettingsPage().environmentObject(appstate)
    }
}
