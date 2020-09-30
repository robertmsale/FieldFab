//
//  MathUtils.swift
//  FieldFab
//
//  Created by Robert Sale on 9/7/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI

class MathUtils {
    static var DEGRAD: CGFloat = CGFloat.pi / 180
    static var RADDEG: CGFloat = 180 / CGFloat.pi
    
    static let INCREMENTS: Array<CGFloat> = [0.03125, 0.0625, 0.125, 0.25, 0.5]
    static let INCREMENTSTRINGS: Array<String> = ["1/32", "1/16", "1/8", "1/4", "1/2"]
    
    static func roundNumber(_ x: CGFloat, roundTo rT: CGFloat) -> CGFloat {
        let r = abs(x).truncatingRemainder(dividingBy: rT)
        if x < 0 {
            if r < (rT / 2) { return -(abs(x) - r) }
            else { return -(abs(x) + (rT - r))}
        } else if x == 0.0 {
            return 0.0
        } else {
            if r < (rT / 2) { return x - r }
            else { return x + (rT - r)}
        }
    }
    
    static func extractND(_ x: CGFloat) -> ND {
        switch abs(x).truncatingRemainder(dividingBy: 1.0) {
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
    
    static func getWhole(_ x: CGFloat) -> Int {
        return Int(x - x.truncatingRemainder(dividingBy: 1.0))
    }
    
    static func clamp( value v: CGFloat, min mi: CGFloat, max ma: CGFloat) -> CGFloat {
        return max( mi, min( ma, v ))
    }
    
    static func euclideanModulo(_ n: CGFloat, _ m: CGFloat) -> CGFloat {
        return ( (n.truncatingRemainder(dividingBy: m)) + m ).truncatingRemainder(dividingBy: m)
    }
    
    static func mapLinear(x: CGFloat, a1: CGFloat, a2: CGFloat, b1: CGFloat, b2: CGFloat ) -> CGFloat {
        return b1 + ( x - a1 ) * ( b2 - b1 ) / ( a2 - a1 )
    }
    
    static func lerp(x: CGFloat, y: CGFloat, t: CGFloat) -> CGFloat {
        return ( 1.0 - t ) * x + t * y
    }
    
    static func smoothstep(x: CGFloat, min mi: CGFloat, max ma: CGFloat) -> CGFloat {
        if x <= mi { return 0.0 }
        if x >= ma { return 1.0 }
        let dx = ( x - mi ) / ( ma - mi )
        return dx * dx * ( 3.0 - 2.0 * dx )
    }
    
    static func smootherstep(x: CGFloat, min mi: CGFloat, max ma: CGFloat) -> CGFloat {
        if x <= mi { return 0.0 }
        if x >= ma { return 1.0 }
        let dx = ( x - mi ) / ( ma - mi )
        return dx * dx * dx * ( dx * ( x * 6.0 - 15.0 ) + 10.0 )
    }
    
    static func floor<T: BinaryFloatingPoint> (_ x: T) -> T {
        return x - x.truncatingRemainder(dividingBy: 1.0)
    }
    
    static func ceil<T: BinaryFloatingPoint>(_ x: T) -> T {
        return x + (1.0 - x.truncatingRemainder(dividingBy: 1.0))
    }
    
    static func degToRad(degrees d: CGFloat) -> CGFloat {
        return d * MathUtils.DEGRAD
    }
    
    static func radToDeg(rads r: CGFloat) -> CGFloat {
        return r * MathUtils.RADDEG
    }
    
    static func invertDeg(_ d: CGFloat) -> CGFloat {
        if d > 180 { return abs(360 - d) }
        else { return 180 + d }
    }
    
    static func reduce(data: [CGFloat], completionHandler: (_ a: CGFloat, _ b: CGFloat) -> CGFloat) -> CGFloat {
        var reduced: CGFloat = 0.0
        for i in 0...data.count - 1 {
            if i == data.count - 1 {
                break
            }
            reduced = completionHandler(data[i], data[i + 1])
        }
        return reduced
    }
    
    static func setQuaternionFromProperEuler() {
        
    }
}

extension CGFloat {
    
    func toRad() -> CGFloat { return self * MathUtils.DEGRAD }
    func toDeg() -> CGFloat { return self * MathUtils.RADDEG }
    
    func toDouble() -> Double { return Double(self) }
    
    func floor() -> CGFloat { return MathUtils.floor(self) }
    func ceil() -> CGFloat { return MathUtils.ceil(self) }
    
    func toFraction(_ roundTo: CGFloat = 0.03125) -> Fraction {
        return Fraction(self, roundTo: roundTo)
    }
    
    func isLTZ() -> CGFloat? {
        if self <= 0.0 { return nil }
        else { return self }
    }
}

extension CGSize {
    public var center: CGPoint { get { CGPoint(x: self.width / 2, y: self.height / 2) } }
}
