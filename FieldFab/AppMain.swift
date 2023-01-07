//
//  AppMain.swift
//  FieldFab
//
//  Created by Robert Sale on 12/10/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI

@main
struct FieldFabApp: App {
    static let loadMethod: ModuleLoadMethod = .development
    let appState = AppState()
    let ductTransitionModuleState = DuctTransition.ModuleState()

    init() {
        #if DEBUG
        var injectionBundlePath = "/Application/InjectionIII.app/Contents/Resources"
        #if targetEnvironment(macCatalyst)
        injectionBundlePath = "\(injectionBundlePath)/macOSInjection.bundle"
        #elseif os(iOS)
        injectionBundlePath = "\(injectionBundlePath)/iOSInjection.bundle"
        #endif
        Bundle(path: injectionBundlePath)?.load()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            AppView()
                .environmentObject(appState)
                .environmentObject(ductTransitionModuleState)
                .onOpenURL(perform: { url in
                    if url.scheme == "fieldfab" {
                        appState.currentModule = AppView.AvailableModules.ductTransition
                        var params: [String: String] = [:]
                        URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.forEach {params[$0.name] = $0.value}
                        
                        let urle = params["encoded"]
                        let b64 = urle?.removingPercentEncoding ?? ""
                        guard let data = Data(base64Encoded: b64) else { return }
                        let decoder = JSONDecoder()
                        if let decoded = try? decoder.decode(DuctTransition.DuctData.self, from: data) {
                            if appState.navPath.count > 0 { appState.navPath.removeLast(appState.navPath.count) }
                            Task(priority: .background) {
                                appState.navPath.append(decoded)
                            }
                        }
                    }
                })
        }
    }
}
