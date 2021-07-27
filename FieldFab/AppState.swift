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
        let floor = self.value.rounded(.towardZero)
        var nd: ND!
        switch abs(value.distance(to: floor)) {
            case let x where x > 0.03125 && x < 0.09375: nd = ND(n: 1, d: 16)
            case let x where x >= 0.09375 && x < 0.15625: nd = ND(n: 1, d: 8)
            case let x where x >= 0.15625 && x < 0.21875: nd = ND(n: 3, d: 16)
            case let x where x >= 0.21875 && x < 0.28125: nd = ND(n: 1, d: 4)
            case let x where x >= 0.28125 && x < 0.34375: nd = ND(n: 5, d: 16)
            case let x where x >= 0.34375 && x < 0.40625: nd = ND(n: 3, d: 8)
            case let x where x >= 0.40625 && x < 0.46875: nd = ND(n: 7, d: 16)
            case let x where x >= 0.46875 && x < 0.53125: nd = ND(n: 1, d: 2)
            case let x where x >= 0.53125 && x < 0.59375: nd = ND(n: 9, d: 16)
            case let x where x >= 0.59375 && x < 0.65625: nd = ND(n: 5, d: 8)
            case let x where x >= 0.65625 && x < 0.71875: nd = ND(n: 11, d: 16)
            case let x where x >= 0.71875 && x < 0.78125: nd = ND(n: 3, d: 4)
            case let x where x >= 0.78125 && x < 0.84375: nd = ND(n: 13, d: 16)
            case let x where x >= 0.84375 && x < 0.90625: nd = ND(n: 7, d: 8)
            case let x where x >= 0.90625 && x < 0.96875: nd = ND(n: 15, d: 16)
            case let x where x >= 0.96875: nd = ND(n: 1, d: 1)
            default: break
        }
        return nd
    }
    var asElement: AnyView {
        let numf = NumberFormatter()
//        numf.roundingMode = .down
        switch self.unit {
            case .feet:
                numf.maximumFractionDigits = 1
                return AnyView(Text("\(numf.string(from: NSNumber(value: self.value)) ?? "")'"))
            case .inches:
                let inf = self.asInchFrac
                numf.maximumFractionDigits = 0
                let w = inf?.d == 1 ? self.value.rounded(.awayFromZero) : self.value.rounded(.towardZero)
                return AnyView(HStack(alignment: .top, spacing: 0) {
                    if self.value != 0.0 {
                        Text("\(numf.string(from: NSNumber(value: w)) ?? "")")
                        if inf != nil && inf?.d != 1 {
                            Text("\(inf!.n)/\(inf!.d)").font(.footnote)
                        }
                        Text("\"")
                    }
                })
            case .meters:
                numf.maximumFractionDigits = 3
                return AnyView(
                    HStack {
                        if self.value != 0.0 {
                            Text("\(numf.string(from: NSNumber(value: self.value)) ?? "")m")
                        }
                    }
                )
            case .centimeters:
                numf.maximumFractionDigits = 1
                return AnyView(
                    HStack {
                        if self.value != 0 {
                            Text("\(numf.string(from: NSNumber(value: self.value)) ?? "")cm")
                        }
                    }
                )
            case .millimeters:
                return AnyView(
                    HStack {
                        if self.value != 0.0 {
                            Text("\(Int(self.value))mm")
                        }
                    }
                )
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
    var cameraHelp = false
    var arHelp = false
}

@propertyWrapper
struct PrevNext<T> {
    private var value: T
    var prev: T
    init(_ val: T) { value = val; prev = val }
    var wrappedValue: T {
        get { return value }
        set(v) { value = v }
    }
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
        var needsReset: Bool {
            renderChanged || bgChanged || textureChanged || measurementsChanged || tabsChanged || energySaverChanged || helpersChanged || drawerChanged
        }
    }
    struct ARScene {
        var renderChanged = false
//        var bgChanged = false
        var textureChanged = false
        var measurementsChanged = false
        var tabsChanged = false
        var energySaverChanged = false
        var helpersChanged = false
//        var drawerChanged = false
        var arViewReset = false
        var needsReset: Bool {
            renderChanged || textureChanged || measurementsChanged || tabsChanged || energySaverChanged || helpersChanged || arViewReset
        }
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
    mutating func changeDone(_ isAR: Bool) { if isAR { self = Self() } else { scene = Scene() } }
    enum FlowDirection: Int { case up, down, left, right }
    var arViewReset = false
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
    @Published var sceneEvents = EventState.Scene()
    @Published var arEvents = EventState.ARScene()
    @Published var ductData: [DuctData] = {
        let defaultData: [DuctData] = []
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
        sceneEvents.textureChanged = true
        arEvents.textureChanged = true
    }}
    @Published var lightingModel: LightingModel = {
        return LightingModel(rawValue: UserDefaults.standard.object(forKey: "lightingModel") as? String ?? "Physically Based") ?? .physicallyBased
    }() { didSet {
        UserDefaults.standard.setValue(lightingModel.rawValue, forKey: "lightingModel")
        sceneEvents.textureChanged = true
        arEvents.textureChanged = true
    }}
    @Published var showDebugInfo: Bool = {
        UserDefaults.standard.object(forKey: "showDebugInfo") as? Bool ?? false
    }() { didSet { UserDefaults.standard.setValue(showDebugInfo, forKey: "showDebugInfo")}}
    @Published var showHelpers: Bool = {
        UserDefaults.standard.object(forKey: "showHelpers") as? Bool ?? false
    }() { didSet {
        UserDefaults.standard.setValue(showHelpers, forKey: "showHelpers")
        sceneEvents.helpersChanged = true
        arEvents.helpersChanged = true
    }}
    @Published var navSelection: UUID? { willSet(v) {
        currentWork = Duct(data: ductData.first(where: {$0.id == v}) ?? DuctData())
    }}
    @Published var popupSaveSuccessful = false
    @Published var workViewTab: Int = {
        UserDefaults.standard.object(forKey: "workViewTab") as? Int ?? 0
    }() { didSet { UserDefaults.standard.setValue(workViewTab, forKey: "workViewTab")}}
    @Published var isSanatized: Bool = false
    @Published var currentWork: Duct? { willSet(v) {
        if currentWork == nil { return }
//        if v == nil { return }
//        if currentWork!.data.width.value.unit != v!.data.width.value.unit {
//            isSanatized = false
//        }
        if let nd = v {
            for i in DuctData.MeasureKeys.allCases { if nd.data[i].value != currentWork!.data[i].value {
                sceneEvents.measurementsChanged = true
                arEvents.measurementsChanged = true
            }}
            if nd.data.tabs != currentWork!.data.tabs && !sceneEvents.measurementsChanged {
                sceneEvents.tabsChanged = true
                arEvents.tabsChanged = true
            }
        }
    } didSet {
//        if currentWork == nil { return }
//        if !isSanatized {
//            isSanatized = true
//            for key in DuctData.MeasureKeys.allCases {
//                switch currentWork!.data[key].value.unit {
//                    case .inches: currentWork!.data[key].value.value = currentWork!.data[key].value.value.rounded(toNearest: 0.0625)
//                    case .feet: currentWork!.data[key].value.value = currentWork!.data[key].value.value.rounded(toNearest: 0.01)
//                    case .meters: currentWork!.data[key].value.value = currentWork!.data[key].value.value.rounded(toNearest: 0.0001)
//                    case .centimeters: currentWork!.data[key].value.value = currentWork!.data[key].value.value.rounded(toNearest: 0.1)
//                    case .millimeters: currentWork!.data[key].value.value = currentWork!.data[key].value.value.rounded(.down)
//                    default: break
//                }
//            }
//        }
    }}
    @Published var currentWorkTab: Int = 0
    @Published var sceneBGColor: CGColor = {
        let colors = UserDefaults.standard.object(forKey: "sceneBGColor") as? Array<CGFloat> ?? [0,0,1,1]
        return CGColor(red: colors[0], green: colors[1], blue: colors[2], alpha: colors[3])
    }() { didSet {
        UserDefaults.standard.setValue(sceneBGColor.components, forKey: "sceneBGColor")
        sceneEvents.bgChanged = true
    }}
    @Published var sceneBGTexture: String? = {
        UserDefaults.standard.object(forKey: "sceneBGTexture") as? String
    }() { didSet {
        UserDefaults.standard.setValue(sceneBGTexture, forKey: "sceneBGTexture")
        sceneEvents.bgChanged = true
    }}
    @Published var energySaver: Bool = {
        UserDefaults.standard.object(forKey: "energySaver") as? Bool ?? false
    }() {
        didSet {
            UserDefaults.standard.setValue(energySaver, forKey: "energySaver")
            sceneEvents.energySaverChanged = true
            arEvents.energySaverChanged = true
        }
    }
    @Published var work3DDrawerShown: Bool = false { didSet { if work3DDrawerShown { sceneEvents.drawerChanged = true }}}
    @Published var work3DMeasurementSelected: DuctData.MeasureKeys = .width { didSet { sceneEvents.drawerChanged = true }}
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
    @Published var showWorkShopTipsAgain: Bool = {
        UserDefaults.standard.object(forKey: "showWorkShopTipsAgain") as? Bool ?? true
    }() { didSet {
        UserDefaults.standard.setValue(showHitTestTipsAgain, forKey: "showWorkShopTipsAgain")
    }}
    @Published var selectedFace: DuctData.FaceAndAll = .front { didSet { print(selectedFace.rawValue)}}
    @Published var showWorkShopTips: Bool = true
    @Published var pdfDuct: Duct?
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
