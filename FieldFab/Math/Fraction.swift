//
//  Function.swift
//  FieldFab
//
//  Created by Robert Sale on 9/7/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI
import Guitar

struct ND {
    var n: Int
    var d: Int
    var sn: String {
        get {
            "\(self.n)"
        }
        set (v) {
            self.n = Int(v)!
        }
    }
    var sd: String {
        get {
            "\(self.d)"
        }
        set (v) {
            self.d = Int(v)!
        }
    }
    
    init(_ n: Int, _ d: Int) {
        self.n = n
        self.d = d
    }
}

struct Fraction {
    static private var sm: CGFloat = 0.03125
    private var _original: CGFloat
    private var _asStringNumeric: String
    private var _isEditingMode: Bool = false
    var isEditingMode: Bool {
        get { return self._isEditingMode }
        set (v) {
            self._isEditingMode = v
            if !v {
                let reg = Guitar(pattern: "[-]{0,1}[0-9]{1,}[.]{0,1}[0-9]{1,}")
                if reg.test(string: self.asStringNumeric) {
                    let num = Double(reg.evaluateForStrings(from: self.asStringNumeric)[0])!
                    self._original = Fraction.roundNumber(CGFloat(num))
                    self._asStringNumeric = "\(self.whole)"
                } else {
                    self._original = 0.0
                    self._asStringNumeric = "0"
                }
            }
        }
    }
    var parts: ND {
        get {
            return Fraction.extractND(self.original)
        }
        set (v) {}
    }
    var whole: Int {
        get {
            return Int(self.original - self.original.truncatingRemainder(dividingBy: 1.0))
        }
    }
    var original: CGFloat {
        get { return self._original }
        set (v) {
            self._original = Fraction.roundNumber(v)
            self._asStringNumeric = "\(self.whole)"
        }
    }
    var asStringNumeric: String {
        get { return self._asStringNumeric }
        set (v) {
            
            if v == "" { self._asStringNumeric = "0" }
            else if Guitar(pattern: "[-]{0,1}[^0-9.]").test(string: v) { return }
            else { self._asStringNumeric = v }
        }
    }
    var isFraction: Bool {
        get { return self.parts.d > 1}
    }
    var textParts: String {
        get { return self.isFraction ? " \(self.parts.n)/\(self.parts.d)\"" : "\"" }
    }
    
    static func roundNumber(_ x: CGFloat) -> CGFloat {
        let r = abs(x).truncatingRemainder(dividingBy: 0.03125)
//        print(abs(x))
//        print(r)
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
    
    static func getWhole(_ x: CGFloat) -> Int {
        return Int(x - x.truncatingRemainder(dividingBy: 1.0))
    }
    
    static func extractND(_ x: CGFloat) -> ND {
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
    
    init(_ x: CGFloat) {
        let rounded = Fraction.roundNumber(x)
        self._original = rounded
        self._asStringNumeric = "\(Fraction.getWhole(rounded))"
    }
}
