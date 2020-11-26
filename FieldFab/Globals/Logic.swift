//
//  Logic.swift
//  FieldFab
//
//  Created by Robert Sale on 9/5/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import Combine
import SwiftUI
import SceneKit

enum AppLogicField {
    case width
    case depth
    case length
    case offsetX
    case offsetY
    case tWidth
    case tDepth
    case isTransition
}

class LoadSharedDimensions: ObservableObject {
    @Published var dimensions: DimensionsData = DimensionsData()
}

class AppLogic: ObservableObject {
    // /////////////////////////////////////// //
    //              Measurements               //
    // /////////////////////////////////////// //
    @Published var width: Fraction {
        didSet {
            if !self.isTransition {
                self.tWidth.original = self.width.original
                UserDefaults.standard.set(self.tWidth.original, forKey: "tWidth")
            }
            UserDefaults.standard.set(self.width.original, forKey: "width")
            self.updateDuct()
        }
    }
    @Published var depth: Fraction {
        didSet {
            if !self.isTransition {
                self.tDepth.original = self.depth.original
                UserDefaults.standard.set(self.tDepth.original, forKey: "tDepth")
            }
            UserDefaults.standard.set(self.depth.original, forKey: "depth")
            self.updateDuct()
        }
    }
    @Published var length: Fraction { didSet {
        UserDefaults.standard.set(self.length.original, forKey: "length")
        self.updateDuct()
    } }
    @Published var offsetX: Fraction { didSet {
        UserDefaults.standard.set(self.offsetX.original, forKey: "offsetX")
        self.updateDuct()
    } }
    @Published var offsetY: Fraction { didSet {
        UserDefaults.standard.set(self.offsetY.original, forKey: "offsetY")
        self.updateDuct()
    } }
    @Published var tWidth: Fraction { didSet {
        UserDefaults.standard.set(self.tWidth.original, forKey: "tWidth")
        self.updateDuct()
    } }
    @Published var tDepth: Fraction { didSet {
        UserDefaults.standard.set(self.tDepth.original, forKey: "tDepth")
        self.updateDuct()
    } }
    @Published var isTransition: Bool { didSet {
        UserDefaults.standard.set(self.isTransition, forKey: "isTransition")
        self.updateDuct()
    } }
    @Published var sessionName: String { didSet {
        UserDefaults.standard.set(self.sessionName, forKey: "sessionName")
    }}
    // /////////////////////////////////////// //
    //              Stepper Stuff              //
    // /////////////////////////////////////// //
    @Published var roundTo: CGFloat { didSet {
        UserDefaults.standard.set(self.roundTo, forKey: "roundTo")
        self.duct.updateMeasurements(self.roundTo)
    } }
    @Published var increments: FractionStepAmount
    
    // /////////////////////////////////////// //
    //                3D Data                  //
    // /////////////////////////////////////// //
    @Published var duct: Ductwork
    @Published var tabs: TabsData { didSet {
        do {
            UserDefaults.standard.set(
                String(data: try JSONEncoder().encode(tabs), encoding: .utf8), forKey: "tabs")
        } catch { print("Problem encoding tabs to JSON") }
        self.updateDuct()
    }}
    
    // /////////////////////////////////////// //
    //                 Events                  //
    // /////////////////////////////////////// //
    @Published var threeDMeasurementsDidChange: Bool = false
    @Published var arMeasurementsDidChange: Bool = false
    @Published var arViewReset: Bool = false
    @Published var tabSideSelected: TabSide = .top
    @Published var shareSheetContent: [Any]?
    // /////////////////////////////////////// //
    //              Sheet Visible              //
    // /////////////////////////////////////// //
    @Published var shareSheetShown: Bool = false
    @Published var threeDMenuShown: Bool = false
    @Published var helpViewShown: Bool = false
    @Published var helpWebViewShown: Bool = false
    @Published var aboutViewShown: Bool = false
    @Published var threeDViewHelpersShown: Bool = false
    @Published var arMenuSheetShown: Bool = false
    @Published var loadSharedSheetShown: Bool = false
    @Published var loadDuctworkViewShown: Bool = false
    @Published var advancedSettingsSheetShown: Bool = false
    // /////////////////////////////////////// //
    //               3D View Data              //
    // /////////////////////////////////////// //
    @Published var selectorWheelSelection: SelectorWheelSelection = .width
    @Published var selectedSide = DuctFace.front
    @Published var selectedRoundTo = PickerRoundTo.sixteenth {
        didSet {
            roundTo = selectedRoundTo.rawValue
        }
    }
    @Published var selectedTabSide: TabSide = .top
    @Published var selectedTabType: TabType = .none {
        didSet {
            tabs[selectedSide][selectedTabSide][1] = selectedTabType
        }
    }
    @Published var selectedTabLength: TabLength = .none {
        didSet {
            tabs[selectedSide][selectedTabSide][1.0] = selectedTabLength
        }
    }
    // /////////////////////////////////////// //
    //             AR Sheet Data               //
    // /////////////////////////////////////// //
    @Published var arViewHelpersShown: Bool = false
    @Published var arViewFlowDirection: FlowDirection = .up
    @Published var arDuctPosition: SCNVector3 = SCNVector3(0, 0, 0) { didSet { print("position: \(arDuctPosition)") }}
    @Published var arDuctRotation: Float = 0.0 { didSet { print("rotation: \(arDuctRotation)") }}

    var url: URL {
        get {
            var url = "fieldfab://load?width=\(self.width.original.description)&"
            url += "length=\(self.length.original.description)&"
            url += "depth=\(self.depth.original.description)&"
            url += "offsetX=\(self.offsetX.original.description)&"
            url += "offsetY=\(self.offsetY.original.description)&"
            url += "tWidth=\(self.tWidth.original.description)&"
            url += "tDepth=\(self.tDepth.original.description)&"
            url += "isTransition=\(self.isTransition.description)&"
            url += "name=\(self.sessionName)&"
            url += "tabs=\(self.tabs.toURL())"
            return URL(string: url)!
        }
    }
    
    // /////////////////////////////////////// //
    //                  Misc                   //
    // /////////////////////////////////////// //
    @Published var experimentalFeaturesEnabled: Set<ExperimentalFeatures> {
        didSet {
            UserDefaults.standard.setValue(experimentalFeaturesEnabled.map({f in f.rawValue}), forKey: "experimentalFeaturesEnabled")
        }
    }
    @Published var threeDObjectHitPopupShown: Bool = false
    @Published var threeDObjectHit: SceneObject = .front
    @Published var texture: String = UserDefaults.standard.object(forKey: "texture") as? String ?? "metal" {
        didSet {
            UserDefaults.standard.set(texture, forKey: "texture")
        }
    }
    
    // /////////////////////////////////////// //
    //                Functions                //
    // /////////////////////////////////////// //
    func makeSideFlat(side: DuctSides) {
        switch side {
        case .front:
            offsetY = Fraction((depth.original - tDepth.original) / 2, roundTo: roundTo)
        case .back:
            offsetY = Fraction(-((depth.original - tDepth.original) / 2), roundTo: roundTo)
        case .right:
            offsetX = Fraction((width.original - tWidth.original) / 2, roundTo: roundTo)
        case .left:
            offsetX = Fraction(-((width.original - tWidth.original) / 2), roundTo: roundTo)
        }
    }

    func updateDuct() {
        self.duct.update(
            self.length.original,
            self.width.original,
            self.depth.original,
            self.offsetX.original,
            self.offsetY.original,
            self.tWidth.original,
            self.tDepth.original,
            self.roundTo)
        threeDMeasurementsDidChange = true
        arMeasurementsDidChange = true
    }

    init() {
        let d = WD()
        self.roundTo = d.rT
        self.selectedRoundTo = PickerRoundTo(rawValue: d.rT) ?? PickerRoundTo.sixteenth
        self.width = Fraction(d.w, roundTo: d.rT)
        self.depth = Fraction(d.d, roundTo: d.rT)
        self.length = Fraction(d.l, roundTo: d.rT)
        self.offsetX = Fraction(d.oX, roundTo: d.rT)
        self.offsetY = Fraction(d.oY, roundTo: d.rT)
        self.tWidth = Fraction(d.tW, roundTo: d.rT)
        self.tDepth = Fraction(d.tD, roundTo: d.rT)
        self.isTransition = d.iT
        self.increments = d.i
        self.duct = Ductwork(d.l, d.w, d.d, d.oX, d.oY, d.tW, d.tD, d.rT)
        self.sessionName = d.s
        self.tabs = d.t
        experimentalFeaturesEnabled = d.e
        selectedTabType = d.t.front.top[1]
        selectedTabLength = d.t.front.top[1.0]
    }

    func toggleTransition() {
        if self.isTransition {
            self.tWidth.original = self.width.original
            self.tDepth.original = self.depth.original
        }
    }
}

struct WD {
    var w: CGFloat
    var d: CGFloat
    var l: CGFloat
    var oX: CGFloat
    var oY: CGFloat
    var tW: CGFloat
    var tD: CGFloat
    var iT: Bool
    var rT: CGFloat
    var i: FractionStepAmount
    var s: String
    var t: TabsData
    var e: Set<ExperimentalFeatures>

    init() {
        self.w = UserDefaults.standard.object(forKey: "width") as? CGFloat ?? 16.0
        self.d = UserDefaults.standard.object(forKey: "depth") as? CGFloat ?? 20.0
        self.l = UserDefaults.standard.object(forKey: "length") as? CGFloat ?? 5.0
        self.oX = UserDefaults.standard.object(forKey: "offsetX") as? CGFloat ?? -1.0
        self.oY = UserDefaults.standard.object(forKey: "offsetY") as? CGFloat ?? 1.0
        self.tW = UserDefaults.standard.object(forKey: "tWidth") as? CGFloat ?? 20.0
        self.tD = UserDefaults.standard.object(forKey: "tDepth") as? CGFloat ?? 21.0
        self.iT = UserDefaults.standard.object(forKey: "isTransition") as? Bool ?? true
        self.rT = UserDefaults.standard.object(forKey: "roundTo") as? CGFloat ?? 0.0625
        self.i = FractionStepAmount.quarter
        self.s = UserDefaults.standard.object(forKey: "sessionName") as? String ?? "Ductwork"
        let features = UserDefaults.standard.object(forKey: "experimentalFeaturesEnabled") as? [Int] ?? []
        e = Set(features.map({f in ExperimentalFeatures.init(rawValue: f)!}))
        do {
            let jsd = (UserDefaults.standard.object(forKey: "tabs") as? String ?? "")
            print(jsd)
            let decoder = JSONDecoder()
            let data = jsd.data(using: .utf8)
            self.t = try decoder.decode(TabsData.self, from: data ?? Data())
        } catch {
            print("Could not decode Tabs user defaults from JSON")
            self.t = TabsData()
        }
    }
}
