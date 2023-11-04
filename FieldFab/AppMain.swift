//
//  AppMain.swift
//  FieldFab
//
//  Created by Robert Sale on 12/10/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI
#if DEBUG
@_exported import HotSwiftUI
#endif

@main
struct FieldFabApp: App {
    /// This property is deprecated now that my app uses InjectionIII
    static let loadMethod: ModuleLoadMethod = .development
    static let appState = AppState()
    static let ductTransitionModuleState = DuctTransition.ModuleState()

    #if DEBUG
    init() {
        var injectionBundlePath = "/Application/InjectionIII.app/Contents/Resources"
//        #if targetEnvironment(macCatalyst)
//        injectionBundlePath = "\(injectionBundlePath)/macOSInjection.bundle"
//        #elseif os(iOS)
        injectionBundlePath = "\(injectionBundlePath)/iOSInjection.bundle"
//        #endif
        Bundle(path: injectionBundlePath)?.load()
    }
    #endif

    var body: some Scene {
        WindowGroup {
            AppView()
                .environmentObject(Self.appState)
                .environmentObject(Self.ductTransitionModuleState)
                .onOpenURL(perform: { url in
                    if url.scheme == "fieldfab" {
                        Self.appState.currentModule = AppView.AvailableModules.ductTransition
                        var params: [String: String] = [:]
                        URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.forEach {params[$0.name] = $0.value}
                        let urle = params["encoded"]
                        let b64 = urle?.removingPercentEncoding ?? ""
                        guard let data = Data(base64Encoded: b64) else { return }
                        let decoder = JSONDecoder()
                        if let decoded = try? decoder.decode(DuctTransition.DuctData.self, from: data) {
                            if Self.appState.navPath.count > 0 { Self.appState.navPath.removeLast(Self.appState.navPath.count) }
                            Task(priority: .background) {
                                Self.appState.navPath.append(decoded)
                            }
                        }
                    }
                })
            #if DEBUG
                .eraseToAnyView()
            #endif
        }
    }
}
