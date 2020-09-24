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
    
    init(_ n: Int, _ d: Int) {
        self.n = n
        self.d = d
    }
}

enum FractionRound: Int {
    case thirtySecond = 0
    case sixteenth = 1
    case eighth = 2
    case quarter = 3
    case half = 4
}

struct Fraction {
    static private var sm: CGFloat = 0.03125
    private var _original: CGFloat
    var roundTo: CGFloat
    var parts: ND {
        get {
            return MathUtils.extractND(self.original)
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
            self._original = MathUtils.roundNumber(v, roundTo: self.roundTo)
        }
    }
    var isFraction: Bool { get { return self.parts.d > 1} }
    
    func text(_ fmt: String = "n/d") -> String {
        var stringBuilder = ""
        for (_, v) in fmt.enumerated() {
            switch v {
                case "n": stringBuilder += "\(self.parts.d > 1 ? self.parts.n.description : "")"
                case "d": stringBuilder += "\(self.parts.d > 1 ? self.parts.d.description : "")"
                case "w": stringBuilder += "\(self.whole)"
                case "/": stringBuilder += "\(self.parts.d > 1 ? "/" : "")"
                case " ": stringBuilder += "\(self.parts.d > 1 ? " " : "")"
                case "o": stringBuilder += "\(self.original)"
                default: stringBuilder += "\(v)"
            }
        }
        return stringBuilder
    }
    
    init<T: BinaryFloatingPoint>(_ x: T, roundTo: CGFloat = 0.03125) {
        let rounded = MathUtils.roundNumber(CGFloat(x), roundTo: roundTo)
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
            Fraction(12.74),
        ]
        return VStack {
            ForEach(Range(0...4), content: { val in
                Text(derp[val].text("w n/d\""))
            })
        }
    }
}
