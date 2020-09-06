//
//  Logic.swift
//  FieldFab
//
//  Created by Robert Sale on 9/5/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import Combine
import SwiftUI
import Guitar

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

struct ND {
    var n: Int
    var d: Int
    
    init(_ n: Int, _ d: Int) {
        self.n = n
        self.d = d
    }
}

struct Fraction {
    static private var sm: Double = 0.03125
    private var _original: Double
    private var _asString: String
    var parts: ND {
        get {
            return Fraction.extractND(self.original)
        }
    }
    var whole: Int {
        get {
            return Int(self.original - self.original.truncatingRemainder(dividingBy: 1.0))
        }
    }
    var original: Double {
        get { return self._original }
        set (v) {
            self._original = Fraction.roundNumber(v)
            self._asString = "\(self._original)"
        }
    }
    var asString: String {
        get { return self._asString }
        set (v) {
            let reg = Guitar(pattern: "[-]{0,1}[0-9]{1,}[.]{0,1}[0-9]{1,}")
            if reg.test(string: v) {
                let num = Double(reg.evaluateForStrings(from: v)[0])!
                self._original = Fraction.roundNumber(num)
                self._asString = "\(self._original)"
            }
        }
    }
    
    static func roundNumber(_ x: Double) -> Double {
        let r = abs(x).truncatingRemainder(dividingBy: 0.03125)
        print(abs(x))
        print(r)
        if x < 0 {
            if r < 0.015625 { return -(abs(x) - r) }
            else { return -(abs(x) + (0.03125 - r))}
        } else if x == 0.0 {
            return 0.0
        } else {
            if r < 0.015625 { return x - r }
            else { return x + (0.03125 - r)}
        }
    }
    
    static func getWhole(_ x: Double) -> Int {
        return Int(x - x.truncatingRemainder(dividingBy: 1.0))
    }
    
    static func extractND(_ x: Double) -> ND {
        switch x.truncatingRemainder(dividingBy: 1.0) {
        case 0.03125: return ND(1, 32)
        case 0.0625: return ND(1, 16)
        case 0.09375: return ND(3, 32)
        case 0.125: return ND(1, 8)
        case 0.15625: return ND(5, 32)
        case 0.1875: return ND(3, 16)
        case 0.21875: return ND(7, 32)
        case 0.25: return ND(1, 4)
        case 0.28125: return ND(9, 32)
        case 0.3125: return ND(5, 16)
        case 0.34375: return ND(11, 32)
        case 0.375: return ND(3, 8)
        case 0.40625: return ND(13, 32)
        case 0.4375: return ND(7, 16)
        case 0.46875: return ND(15, 32)
        case 0.5: return ND(1, 2)
        case 0.53125: return ND(17, 32)
        case 0.5625: return ND(9, 16)
        case 0.59375: return ND(19, 32)
        case 0.625: return ND(5, 8)
        case 0.65625: return ND(21, 32)
        case 0.6875: return ND(11, 16)
        case 0.71875: return ND(23, 32)
        case 0.75: return ND(3, 4)
        case 0.78125: return ND(25, 32)
        case 0.8125: return ND(13, 16)
        case 0.84375: return ND(27, 32)
        case 0.875: return ND(7, 8)
        case 0.90625: return ND(29, 32)
        case 0.9375: return ND(15, 16)
        case 0.96875: return ND(31, 32)
        default: return ND(1, 1)
        }
    }
    
    init(_ x: Double) {
        let rounded = Fraction.roundNumber(x)
        self._original = rounded
        self._asString = "\(rounded)"
    }
}

class AppLogic : ObservableObject {
    @Published var width: Fraction
    @Published var depth: Fraction
    @Published var length: Fraction
    @Published var offsetX: Fraction
    @Published var offsetY: Fraction
    @Published var tWidth: Fraction
    @Published var tDepth: Fraction
    @Published var isTransition: Bool

    
    init() {
        self.width = Fraction(16.5)
        self.depth = Fraction(22.5)
        self.length = Fraction(10)
        self.offsetX = Fraction(0)
        self.offsetY = Fraction(0)
        self.tWidth = Fraction(16.5)
        self.tDepth = Fraction(22.5)
        self.isTransition = false
    }
    
    func mutate(x: Int, f: AppLogicField) {
        let v = x < 0 ? -0.03125 : 0.03125
        switch f {
        case .width:
            self.width.original = self.width.original + v
            if !self.isTransition { self.tWidth.original = self.width.original }
        case .depth:
            self.depth.original = self.depth.original + v
            if !self.isTransition { self.tDepth.original = self.depth.original }
        case .length:
            self.length.original = self.length.original + v
        case .offsetX:
            self.offsetX.original = self.offsetX.original + v
        case .offsetY:
            self.offsetY.original = self.offsetY.original + v
        case .tDepth:
            self.tDepth.original = self.tDepth.original + v
        case .tWidth:
            self.tWidth.original = self.tWidth.original + v
        default:
            return
        }
    }
    
    func mutateExact(x: Double, f: AppLogicField) {
        switch f {
        case .width:
            self.width.original = x
            if !self.isTransition { self.tWidth.original = x }
        case .depth:
            self.depth.original = x
            if !self.isTransition { self.tDepth.original = x }
        case .length:
            self.length.original = x
        case .offsetX:
            self.offsetX.original = x
        case .offsetY:
            self.offsetY.original = x
        case .tDepth:
            self.tDepth.original = x
        case .tWidth:
            self.tWidth.original = x
        default:
            return
        }
    }
    
    func toggleTransition() {
        if self.isTransition {
            self.isTransition = false
            self.tWidth.original = self.width.original
            self.tDepth.original = self.depth.original
        } else {
            self.isTransition = true
            
        }
    }
}
