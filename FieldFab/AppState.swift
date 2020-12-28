//
//  AppState.swift
//  FieldFab
//
//  Created by Robert Sale on 12/10/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI
import Disk
import SceneKit

struct ND { let n: Int; let d: Int }
extension Measurement where UnitType: UnitLength {
    var asInchFrac: ND? {
        if self.unit != .inches { return ND(n: 0, d: 0) }
        let num = self.value.rounded(toNearest: 0.0625)
        let floor = num.floor
        var nd: ND!
        switch num - floor {
            case let x where x > 0.0624 && x < 0.0626: nd = ND(n: 1, d: 16)
            case let x where x > 0.1249 && x < 0.1251: nd = ND(n: 1, d: 8)
            case let x where x > 0.1874 && x < 0.1876: nd = ND(n: 3, d: 16)
            case let x where x > 0.2499 && x < 0.2501: nd = ND(n: 1, d: 4)
            case let x where x > 0.3124 && x < 0.3126: nd = ND(n: 5, d: 16)
            case let x where x > 0.3749 && x < 0.3751: nd = ND(n: 3, d: 8)
            case let x where x > 0.4374 && x < 0.4376: nd = ND(n: 7, d: 16)
            case let x where x > 0.4999 && x < 0.5001: nd = ND(n: 1, d: 2)
            case let x where x > 0.5624 && x < 0.5626: nd = ND(n: 9, d: 16)
            case let x where x > 0.6249 && x < 0.6251: nd = ND(n: 5, d: 8)
            case let x where x > 0.6874 && x < 0.6876: nd = ND(n: 11, d: 16)
            case let x where x > 0.7499 && x < 0.7501: nd = ND(n: 3, d: 4)
            case let x where x > 0.8124 && x < 0.8126: nd = ND(n: 13, d: 16)
            case let x where x > 0.8749 && x < 0.8751: nd = ND(n: 7, d: 8)
            case let x where x > 0.9374 && x < 0.9376: nd = ND(n: 15, d: 16)
            default: break
        }
        return nd
    }
    var asElement: AnyView {
        let numf = NumberFormatter()
        switch self.unit {
            case .feet:
                numf.maximumFractionDigits = 1
                return AnyView(Text("\(numf.string(from: NSNumber(value: self.value)) ?? "")'"))
            case .inches:
                let inf = self.asInchFrac
                numf.maximumFractionDigits = 0
                return AnyView(HStack(alignment: .top, spacing: 0) {
                    Text("\(numf.string(from: NSNumber(value: value)) ?? "")")
                    if inf != nil {
                        Text("\(inf!.n)/\(inf!.d)").font(.footnote)
                    }
                    Text("\"")
                })
            case .meters:
                numf.maximumFractionDigits = 3
                return AnyView(Text("\(numf.string(from: NSNumber(value: self.value)) ?? "")m"))
            case .centimeters:
                numf.maximumFractionDigits = 1
                return AnyView(Text("\(numf.string(from: NSNumber(value: self.value)) ?? "")cm"))
            case .millimeters:
                return AnyView(Text("\(Int(self.value))mm"))
            default: return AnyView(Text("\(self.value) \(self.unit.symbol)"))
        }
    }
}

struct SheetShownState: Codable {
    var share = false
    var tdMenu = false
    var help = false
    var helpWeb = false
    var about = false
    var arMenu = false
    var shared = false
    var load = false
    var advancedSettings = false
}

struct EventState {
    struct Scene {
        var renderChanged = false
        var bgChanged = false
        var textureChanged = false
        var measurementsChanged = false
        var tabsChanged = false
        var energySaverChanged = false
        var helpersChanged = false
        var drawerChanged = false
    }
    enum Keys { case renderer, bg, texture, measurements, tabs, energy, helpers, drawer }
    var scene = Scene()
    var ar = Scene()
    mutating func change(_ value: Keys) {
        switch value {
            case .renderer: scene.renderChanged = true; ar.renderChanged = true
            case .bg: scene.bgChanged = true; ar.bgChanged = true
            case .texture: scene.textureChanged = true; ar.textureChanged = true
            case .measurements: scene.measurementsChanged = true; ar.measurementsChanged = true
            case .tabs: scene.tabsChanged = true; ar.tabsChanged = true
            case .energy: scene.energySaverChanged = true; ar.energySaverChanged = true
            case .helpers: scene.helpersChanged = true; ar.helpersChanged = true
            case .drawer: scene.drawerChanged = true; ar.drawerChanged = true
        }
    }
    var arViewReset = false
    enum FlowDirection: Int { case up, down, left, right }
    var flowDirection: FlowDirection = {
        return FlowDirection(rawValue: UserDefaults.standard.object(forKey: "flowDirection") as? Int ?? 0) ?? .up
    }() { didSet {
        UserDefaults.standard.setValue(flowDirection.rawValue, forKey: "flowDirection")
    }}
}

enum MeasurementUnits: Int, Codable, Identifiable, CaseIterable {
    case inch, feet, meters, millimeters, centimeters
    var id: Int { self.rawValue }
    var unit: UnitLength {
        switch self {
            case .inch: return .inches
            case .feet: return .feet
            case .meters: return .meters
            case .centimeters: return .centimeters
            case .millimeters: return .millimeters
        }
    }
    var string: String {
        switch self {
            case .inch: return "Inches"
            case .feet: return "Feet"
            case .meters: return "Meters"
            case .centimeters: return "Centimeters"
            case .millimeters: return "Millimeters"
        }
    }
}

final class AppState: ObservableObject {
    @Published var sheetsShown = SheetShownState()
    @Published var events = EventState()
    @Published var ductData: [DuctData] = {
        let defaultData = [
            DuctData(
                name: "16x20-to-20x20",
                id: UUID(),
                created: Date(),
                width: DuctMeasurement(value: .init(value: 16, unit: .inches)),
                depth: DuctMeasurement(value: .init(value: 20, unit: .inches)),
                length: DuctMeasurement(value: .init(value: 6, unit: .inches)),
                offsetx: DuctMeasurement(value: .init(value: 0, unit: .inches)),
                offsety: DuctMeasurement(value: .init(value: 0, unit: .inches)),
                twidth: DuctMeasurement(value: .init(value: 20, unit: .inches)),
                tdepth: DuctMeasurement(value: .init(value: 20, unit: .inches)),
                type: .fourpiece,
                tabs: DuctTabContainer()),
            DuctData(
                name: "16x20-to-20x20-w-offset",
                id: UUID(),
                created: Date(),
                width: DuctMeasurement(value: .init(value: 16, unit: .inches)),
                depth: DuctMeasurement(value: .init(value: 20, unit: .inches)),
                length: DuctMeasurement(value: .init(value: 8, unit: .inches)),
                offsetx: DuctMeasurement(value: .init(value: 2, unit: .inches)),
                offsety: DuctMeasurement(value: .init(value: 1, unit: .inches)),
                twidth: DuctMeasurement(value: .init(value: 20, unit: .inches)),
                tdepth: DuctMeasurement(value: .init(value: 20, unit: .inches)),
                type: .fourpiece,
                tabs: DuctTabContainer())
        ]
        do {
            let data = try Disk.retrieve("duct-data.json", from: .caches, as: [DuctData].self)
            if data.count == 0 {
                try Disk.save(defaultData, to: .caches, as: "duct-data.json")
                return defaultData
            }
            return data
        } catch {
            try! Disk.save(defaultData, to: .caches, as: "duct-data.json")
            return defaultData
        }
    }() { didSet {
    do {
        try Disk.save(ductData, to: .caches, as: "duct-data.json")
    } catch {}
}}
    @Published var currentPage: String?
    @Published var defaultUnits: MeasurementUnits = {
        if let du = UserDefaults.standard.object(forKey: "defaultUnits") as? Int {
            return MeasurementUnits(rawValue: du) ?? .inch
        } else {
            return .inch
        }
    }() { didSet { UserDefaults.standard.setValue(defaultUnits.rawValue, forKey: "defaultUnits") } }
    @Published var defaultName: String = {
        return UserDefaults.standard.object(forKey: "defaultName") as? String ?? ""
        
    }() { didSet { UserDefaults.standard.setValue(defaultName, forKey: "defaultName")}}
    @Published var material: String = {
        return UserDefaults.standard.object(forKey: "material") as? String ?? "galvanized"
    }() { didSet {
        UserDefaults.standard.setValue(material, forKey: "material")
        events.change(.texture)
    }}
    @Published var lightingModel: LightingModel = {
        return LightingModel(rawValue: UserDefaults.standard.object(forKey: "lightingModel") as? String ?? "Physically Based") ?? .physicallyBased
    }() { didSet {
        UserDefaults.standard.setValue(lightingModel.rawValue, forKey: "lightingModel")
        events.change(.texture)
    }}
    @Published var showDebugInfo: Bool = {
        UserDefaults.standard.object(forKey: "showDebugInfo") as? Bool ?? false
    }() { didSet { UserDefaults.standard.setValue(showDebugInfo, forKey: "showDebugInfo")}}
    @Published var showHelpers: Bool = {
        UserDefaults.standard.object(forKey: "showHelpers") as? Bool ?? false
    }() { didSet {
        UserDefaults.standard.setValue(showHelpers, forKey: "showHelpers")
        events.change(.helpers)
    }}
    @Published var navSelection: UUID? { willSet(v) {
        currentWork = Duct(data: ductData.first(where: {$0.id == v}) ?? DuctData())
    }}
    @Published var popupSaveSuccessful = false
    @Published var workViewTab: Int = {
        UserDefaults.standard.object(forKey: "workViewTab") as? Int ?? 0
    }() { didSet { UserDefaults.standard.setValue(workViewTab, forKey: "workViewTab")}}
    @Published var currentWork: Duct? { willSet(v) {
        if currentWork == nil { return }
        if let nd = v {
            for i in DuctData.MeasureKeys.allCases { if nd.data[i].value != currentWork!.data[i].value { events.change(.measurements) }}
            if nd.data.tabs != currentWork!.data.tabs { events.change(.tabs) }
        }
    }}
    @Published var currentWorkTab: Int = 0
    @Published var sceneBGColor: CGColor = {
        let colors = UserDefaults.standard.object(forKey: "sceneBGColor") as? Array<CGFloat> ?? [0,0,1,1]
        return CGColor(red: colors[0], green: colors[1], blue: colors[2], alpha: colors[3])
    }() { didSet {
        UserDefaults.standard.setValue(sceneBGColor.components, forKey: "sceneBGColor")
        events.change(.bg)
    }}
    @Published var sceneBGTexture: String? = {
        UserDefaults.standard.object(forKey: "sceneBGTexture") as? String
    }() { didSet {
        UserDefaults.standard.setValue(sceneBGTexture, forKey: "sceneBGTexture")
        events.change(.bg)
    }}
    @Published var energySaver: Bool = {
        UserDefaults.standard.object(forKey: "energySaver") as? Bool ?? false
    }() {
        didSet {
            UserDefaults.standard.setValue(energySaver, forKey: "energySaver")
            events.change(.energy)
        }
    }
    @Published var work3DDrawerShown: Bool = false { didSet { if work3DDrawerShown { events.change(.drawer) }}}
    @Published var work3DMeasurementSelected: DuctData.MeasureKeys = .width { didSet { events.change(.drawer) }}
    @Published var arDuctEuler: SCNVector3 = SCNVector3(0, 0, 0)
    @Published var arDuctRotation: SCNQuaternion = SCNQuaternion(0, 0, 0, 1).normalized()
    @Published var ductCameraQuat: SCNQuaternion = SCNQuaternion(0, 0, 0, 1).normalized()
    @Published var cameraOrientation: SCNQuaternion = SCNQuaternion(0, 0, 0, 1)
    @Published var ductSceneHitTest: String?
    enum TranslationMode { case xz, y }
    enum FlowDirection {
        case up, down, left, right
        var text: String {
            switch self {
                case .up: return "Upflow"
                case .down: return "Downflow"
                case .left: return "Leftflow"
                case .right: return "Rightflow"
            }
        }
    }
    @Published var flowDirection: FlowDirection = .up
    @Published var translationMode: TranslationMode = .xz
    @Published var shareURL: String?
    @Published var showHitTestTipsAgain: Bool = {
        UserDefaults.standard.object(forKey: "showHitTestTipsAgain") as? Bool ?? true
    }() { didSet {
        UserDefaults.standard.setValue(showHitTestTipsAgain, forKey: "showHitTestTipsAgain")
    }}
    @Published var showHitTestTips: Bool = true
}

enum LightingModel: String, CaseIterable, Identifiable {
    case physicallyBased = "Physically Based"
    case blinn = "Blinn"
    case constant = "Constant"
    case lambert = "Lambert"
    case phong = "Phong"
    case shadowOnly = "Shadow Only"
    var id: String { self.rawValue }
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
}
