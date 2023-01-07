//
//  DuctTransitionsSettingsView.swift
//  FieldFab
//
//  Created by Robert Sale on 12/30/22.
//  Copyright © 2022 Robert Sale. All rights reserved.
//

import SwiftUI
import SceneKit
import StringFix
#if DEBUG
@_exported import HotSwiftUI
#endif

enum LightingMethod: Int, CaseIterable, Identifiable {
    case physicallyBased, blinn, phong, constant, lambert, shadowOnly
    var scn: SCNMaterial.LightingModel {
        switch self {
        case .physicallyBased: return .physicallyBased
        case .blinn: return .blinn
        case .constant: return .constant
        case .lambert: return .lambert
        case .phong: return .phong
        case .shadowOnly: return .shadowOnly
        }
    }
    var localizedString: String {
        switch self {
        case .physicallyBased:
            return "Physically Based"
        case .blinn:
            return "Blinn"
        case .constant:
            return "Constant"
        case .lambert:
            return "Lambert"
        case .phong:
            return "Phong"
        case .shadowOnly:
            return "Shadow Only"
        }
    }
    var id: Int { self.rawValue }
}

enum DuctTexture: String, CaseIterable, Identifiable {
    case galvanized = "galvanized", stainless = "metal"
    var localizedString: String {
        let rv = self.rawValue
        return rv[0].uppercased() + rv[1...]
    }
    var id: String { self.rawValue }
}

enum BackgroundType: Int, CaseIterable, Identifiable {
    case image, color
    var localizedString: String {
        switch self {
        case .image: return "Image"
        case .color: return "Color"
        }
    }
    var id: Int { self.rawValue }
}

enum BackgroundImage: String, CaseIterable, Identifiable {
    case shop = "Shop", workshop = "Workshop"
    var id: String { self.rawValue }
}

extension DuctTransition {
    enum AppStorageKeys: String {
        case texture,
             crossBrake,
             lighting,
             energySaver,
             showHelpers,
             showDebugInfo,
             bgType,
             bgR,
             bgG,
             bgB,
             bgImage
    }
}

extension AppStorage where Value == String {init(wrappedValue: Value, _ key: DuctTransition.AppStorageKeys, store: UserDefaults? = nil){self.init(wrappedValue: wrappedValue, key.rawValue, store: store)}}
extension AppStorage where Value == Int {init(wrappedValue: Value, _ key: DuctTransition.AppStorageKeys, store: UserDefaults? = nil){self.init(wrappedValue: wrappedValue, key.rawValue, store: store)}}
extension AppStorage where Value == Bool {init(wrappedValue: Value, _ key: DuctTransition.AppStorageKeys, store: UserDefaults? = nil){self.init(wrappedValue: wrappedValue, key.rawValue, store: store)}}
extension AppStorage where Value == Double {init(wrappedValue: Value, _ key: DuctTransition.AppStorageKeys, store: UserDefaults? = nil){self.init(wrappedValue: wrappedValue, key.rawValue, store: store)}}
extension AppStorage where Value == URL {init(wrappedValue: Value, _ key: DuctTransition.AppStorageKeys, store: UserDefaults? = nil){self.init(wrappedValue: wrappedValue, key.rawValue, store: store)}}
extension AppStorage where Value == Data {init(wrappedValue: Value, _ key: DuctTransition.AppStorageKeys, store: UserDefaults? = nil){self.init(wrappedValue: wrappedValue, key.rawValue, store: store)}}
extension AppStorage where Value : RawRepresentable, Value.RawValue == Int {init(wrappedValue: Value, _ key: DuctTransition.AppStorageKeys, store: UserDefaults? = nil){self.init(wrappedValue: wrappedValue, key.rawValue, store: store)}}
extension AppStorage where Value : RawRepresentable, Value.RawValue == String {init(wrappedValue: Value, _ key: DuctTransition.AppStorageKeys, store: UserDefaults? = nil){self.init(wrappedValue: wrappedValue, key.rawValue, store: store)}}


extension DuctTransition {
    struct SettingsView: View {
        typealias Key = AppStorageKeys
        @AppStorage(Key.texture) var texture: String = "galvanized"
        @AppStorage(Key.crossBrake) var crossBrake: Bool = true
        @AppStorage(Key.lighting) var lighting: LightingMethod = .physicallyBased
        @AppStorage(Key.energySaver) var energySaver: Bool = false
        @AppStorage(Key.showHelpers) var showHelpers: Bool = false
        @AppStorage(Key.showDebugInfo) var showDebugInfo: Bool = false
        @AppStorage(Key.bgType) var bgType: BackgroundType = .image
        @AppStorage(Key.bgR) var bgR: Double = 0.0
        @AppStorage(Key.bgG) var bgG: Double = 0.0
        @AppStorage(Key.bgB) var bgB: Double = 1.0
        @AppStorage(Key.bgImage) var bgImage: BackgroundImage = .shop
        
        func genSubText<Content: View>(message: String, @ViewBuilder content: () -> Content) -> some View {
            VStack {
                content()
                Text(message)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.gray)
            }
        }
        
        var body: some View {
            Form {
                Section("Helpful Features") {
                    genSubText(message: "Colors the faces of the ductwork so you always know which side you're looking at. Useful if your background is not an image or you rotate your duct in AR view so much you forget which face is the front.") {
                        Toggle("Show Helpers", isOn: $showHelpers)
                        Text("Front face = Green").font(.footnote).foregroundColor(Color.green)
                    }
                }
                Section("Quality") {
                    Picker("Texture", selection: $texture) {
                        ForEach(DuctTexture.allCases) { tex in
                            Text(tex.localizedString).tag(tex)
                        }
                    }
                    genSubText(message: "Physically Based is the best quality") {
                        Picker("Lighing Model", selection: $lighting) {
                            ForEach(LightingMethod.allCases) { lm in
                                Text(lm.localizedString).tag(lm)
                            }
                        }
                    }
                    genSubText(message: "Gives the ductwork a crossbrake appearance") {
                        Toggle("Crossbrake", isOn: $crossBrake)
                    }
                }
                Section("Performance") {
                    genSubText(message: "Improves performance by limiting GPU calls to only when necessary. May affect buttery smoothness of rendering. If show debug info is enabled you may notice 0 FPS in the 3D view with this enabled.") {
                        Toggle("Energy Saver", isOn: $energySaver)
                    }
                }
                Section("Preferences") {
                    Picker("Background Type", selection: $bgType) {
                        ForEach(BackgroundType.allCases) { t in
                            Text(t.localizedString).tag(t)
                        }
                    }
                    switch bgType {
                    case .image:
                        Picker("Background Image", selection: $bgImage) {
                            ForEach(BackgroundImage.allCases) { bg in
                                Text(bg.rawValue).tag(bg)
                            }
                        }
                    case .color:
                        ColorPicker("Background Color", selection: Binding(get: { Color(red: bgR, green: bgG, blue: bgG) }, set: { v in
                            let cg = v.cgColor
                            bgR = Double(cg?.components?[0] ?? 0.0)
                            bgG = Double(cg?.components?[1] ?? 0.0)
                            bgB = Double(cg?.components?[2] ?? 1.0)
                        }))
                    }
                }
                Section("Debugging") {
                    genSubText(message: "For fun, you can see how hard your device is working to render the procedurally generated ductwork. I can guarantee your device is barely breaking a sweat.") {
                        Toggle("Show Debug Info", isOn: $showDebugInfo)
                    }
                }
            }
            #if DEBUG
            .eraseToAnyView()
            #endif
        }
        #if DEBUG
        @ObservedObject var iO = injectionObserver
        #endif
    }
}

