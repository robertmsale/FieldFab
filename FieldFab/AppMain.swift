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
    let appstate = AppState()
    
    var body: some Scene {
        WindowGroup {
            AppView()
                .environmentObject(appstate)
                .onOpenURL(perform: { url in
                    if url.scheme == "fieldfab" {
                        var params: [String: String] = [:]
                        URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.forEach {params[$0.name] = $0.value}
                        var data = DuctData()
                        data.name = params["name"] ?? ""
                        data.tabs = .init(url: params["tabs"] ?? "")
                        let nf = NumberFormatter()
                        let units: UnitLength = {
                            guard let units = params["units"] else { return .inches }
                            switch units {
                                case "inches": return .inches
                                case "feet": return .feet
                                case "meters": return .meters
                                case "centimeters": return .centimeters
                                case "millimeters": return .millimeters
                                default: return .inches
                            }
                        }()
                        data.width      = .init(value: Measurement<UnitLength>(value: nf.number(from: params["width"]   ?? "10")?.floatValue.d ?? 10, unit: units))
                        data.depth      = .init(value: Measurement<UnitLength>(value: nf.number(from: params["depth"]   ?? "10")?.floatValue.d ?? 10, unit: units))
                        data.length     = .init(value: Measurement<UnitLength>(value: nf.number(from: params["length"]  ?? "10")?.floatValue.d ?? 10, unit: units))
                        data.offsetx    = .init(value: Measurement<UnitLength>(value: nf.number(from: params["offsetX"] ?? "10")?.floatValue.d ?? 10, unit: units))
                        data.offsety    = .init(value: Measurement<UnitLength>(value: nf.number(from: params["offsetY"] ?? "10")?.floatValue.d ?? 10, unit: units))
                        data.twidth     = .init(value: Measurement<UnitLength>(value: nf.number(from: params["tWidth"]  ?? "10")?.floatValue.d ?? 10, unit: units))
                        data.tdepth     = .init(value: Measurement<UnitLength>(value: nf.number(from: params["tDepth"]  ?? "10")?.floatValue.d ?? 10, unit: units))
                        data.type       = DuctData.DType.init(rawValue: params["type"] ?? "") ?? .fourpiece
                        appstate.ductData.append(data)
                        appstate.currentWork = Duct(data: data)
                        appstate.navSelection = data.id
                    }
                })
        }
    }
}
