//
//  Logic.swift
//  FieldFab
//
//  Created by Robert Sale on 9/5/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import Combine
import SwiftUI

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

class AppLogic : ObservableObject {
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
    @Published var roundTo: CGFloat { didSet {
        UserDefaults.standard.set(self.roundTo, forKey: "roundTo")
        self.duct.updateMeasurements(self.roundTo)
        } }
    @Published var increments: FractionStepAmount
    @Published var duct: Ductwork
    
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
    }

    
    init() {
//        let ud = UserDefaults.standard
//        let rt = CGFloat(ud.double(forKey: "roundTo"))
//        self.roundTo = rt
//        self.width = Fraction(CGFloat(ud.double(forKey: "width")), roundTo: rt)
//        self.depth = Fraction(CGFloat(ud.double(forKey: "depth")), roundTo: rt)
//        self.length = Fraction(CGFloat(ud.double(forKey: "length")), roundTo: rt)
//        self.offsetX = Fraction(CGFloat(ud.double(forKey: "offsetX")), roundTo: rt)
//        self.offsetY = Fraction(CGFloat(ud.double(forKey: "offsetY")), roundTo: rt)
//        self.tWidth = Fraction(CGFloat(ud.double(forKey: "tWidth")), roundTo: rt)
//        self.tDepth = Fraction(CGFloat(ud.double(forKey: "tDepth")), roundTo: rt)
//        self.isTransition = ud.bool(forKey: "roundTo")
        let d = WD()
        self.roundTo = d.rT
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
    }
}
