//
//  Function.swift
//  FieldFab
//
//  Created by Robert Sale on 9/7/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI

struct ND {
    var n: Int
    var d: Int

    init(_ n: Int, _ d: Int) {
        self.n = n
        self.d = d
    }
}

enum FractionStepAmount: CGFloat {
    case whole = 1.0
    case half = 0.5
    case quarter = 0.25
    case eighth = 0.125
    case sixteenth = 0.0625
    case thirtysecond = 0.03125
}

struct Fraction {
    static private var sm: CGFloat = 0.03125
    private var _original: CGFloat
    var roundTo: CGFloat
    var parts: ND {
        get {
            return Math.extractND(self.original)
        }
    }
    var whole: Int {
        get {
            return Int(self.original - self.original.truncatingRemainder(dividingBy: 1.0))
        }
    }
    var original: CGFloat {
        get { return self._original }
        set (v) {
            self._original = Math.roundNumber(v, roundTo: self.roundTo)
        }
    }
    var isFraction: Bool { get { return self.parts.d > 1 } }

    enum MutDir {
        case increment
        case decrement
    }

    mutating func mutate(_ amt: FractionStepAmount, _ direction: MutDir) {
        if direction == .increment { self._original += amt.rawValue } else { self._original -= amt.rawValue }
    }

    func text(_ fmt: String = "n/d") -> String {
        var stringBuilder = ""
        for (_, v) in fmt.enumerated() {
            switch v {
            case "n": stringBuilder += "\(self.parts.d > 1 ? self.parts.n.description : "")"
            case "d": stringBuilder += "\(self.parts.d > 1 ? self.parts.d.description : "")"
            case "w": stringBuilder += "\(self.whole == 0 ? "" : self.whole.description)"
            case "/": stringBuilder += "\(self.parts.d > 1 ? "/" : "")"
            case " ": stringBuilder += "\(self.parts.d > 1 ? " " : "")"
            case "o": stringBuilder += "\(self.original)"
            default: stringBuilder += "\(v)"
            }
        }
        return stringBuilder
    }

    init<T: BinaryFloatingPoint>(_ x: T, roundTo: CGFloat = 0.03125) {
        let rounded = Math.roundNumber(CGFloat(x), roundTo: roundTo)
        self._original = rounded
        self.roundTo = roundTo
    }

}

struct Fraction_Previews: PreviewProvider {
    static var previews: some View {
        let derp = [
            Fraction(12.5),
            Fraction(16.25),
            Fraction(11.0625),
            Fraction(12.3333333, roundTo: 0.5),
            Fraction(12.74)
        ]
        return VStack {
            ForEach(Range(0...4), content: { val in
                Text(derp[val].text("w n/d\""))
            })
        }
    }
}
