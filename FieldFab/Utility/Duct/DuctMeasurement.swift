//
//  DuctMeasurement.swift
//  FieldFab
//
//  Created by Robert Sale on 12/24/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import Foundation
import Accelerate

struct DuctMeasurement: Codable {
    static let GAUGE: Float = 0.00079375
    var value: Measurement<UnitLength>
    var rendered3D: Float { value.converted(to: .meters).value.f }
    var rendered2D: CGFloat { value.converted(to: .meters).value.cg }
    private var _isNegative: Bool
    var isNegative: Bool {
        get { return _isNegative }
        set(v) {
            if v {
                if value.value > 0 { value.value = -value.value }
            } else {
                if value.value < 0 { value.value = -value.value }
            }
            _isNegative = v
        }
    }
    init(value: Measurement<UnitLength>) {
        self.value = value
        if value.value < 0 { _isNegative = true } else { _isNegative = false }
    }
    var maxFrac: Int {
        switch value.unit {
            case .inches:           return 4
            case .feet:             return 2
            case .meters:           return 3
            case .centimeters:      return 1
            case .millimeters:      return 0
            default:                return 1
        }
    }
    var maxInt: Int {
        switch value.unit {
            case .inches:           return 2
            case .feet:             return 1
            case .meters:           return 1
            case .centimeters:      return 3
            case .millimeters:      return 4
            default:                return 1
        }
    }
    private func formatter() -> NumberFormatter {
        let nf = NumberFormatter()
        nf.alwaysShowsDecimalSeparator = true
        nf.maximumIntegerDigits = maxInt
        nf.maximumFractionDigits = maxFrac
        return nf
    }
    func sanatize(newval: inout Double) {
        switch value.unit {
            case .inches:       newval = newval.clamp(min: -60,     max: 60     )
            case .feet:         newval = newval.clamp(min: -5,      max: 5      )
            case .meters:       newval = newval.clamp(min: -1.828,  max: 1.828  )
            case .centimeters:  newval = newval.clamp(min: -182.8,  max: 182.8  )
            case .millimeters:  newval = newval.clamp(min: -1828,   max: 1828   )
            default: newval = 0
        }
    }
    
    var wholeDigits: [Int] {
        get {
            let vstr = formatter().string(from: NSNumber(value: abs(value.value)))
            let def = "\(Array(repeating: Character("0"), count: 4).reduce("", {$0 + "\($1)"}))"
            let defsub = def[def.startIndex...]
            let defres = Array(repeating: 0, count: 4)
            var res = vstr?.split(separator: ".")[0, defsub].map {$0.wholeNumberValue ?? 0} ?? defres
            if res.count < maxInt { res.insert(contentsOf: Array(repeating: 0, count: maxInt - res.count), at: 0) }
            return res
        } set(v) {
            let vstr = formatter().string(from: NSNumber(value: abs(value.value)))
            let def = "\(Array(repeating: Character("0"), count: maxInt).reduce("", {$0 + "\($1)"}))"
            let defsub = def[def.startIndex...]
            var newval = Double("0.\(vstr?.split(separator: ".")[1, defsub] ?? defsub)") ?? 0.0
            var i = 1
            for j in v.reversed() {
                newval += j.d * i.d
                i *= 10
            }
            sanatize(newval: &newval)
            value.value = isNegative ? -newval : newval
        }
    }
    var fracDigits: [Int] {
        get {
            let vstr = formatter().string(from: NSNumber(value: value.value))
            let def = Array(repeating: Character("0"), count: 4).reduce("", {$0 + "\($1)"})
            let defsub = def[def.startIndex...]
            let defres = Array(repeating: 0, count: 4)
            let split = vstr?.split(separator: ".")
            if split?.count ?? 1 > 1 {
                var res = split?[1, defsub].map({$0.wholeNumberValue ?? 0}) ?? defres
                if res.count < 4 { res.append(contentsOf: Array(repeating: 0, count: 4 - res.count)) }
                return res
            }
            return defres
        } set(v) {
            var newval = value.value.rounded(.towardZero)
            var i = 0.1
            for j in v {
                newval += j.d * i
                i /= 10
            }
            sanatize(newval: &newval)
            value.value = isNegative ? -newval : newval
        }
    }
}
