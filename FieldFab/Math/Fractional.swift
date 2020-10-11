//
//  Fractional.swift
//  FieldFab
//
//  Created by Robert Sale on 10/1/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI

protocol Fractional {
    var original: CGFloat { get set }
}

extension Fractional {
    var whole: Int {
        get { return Math.getWhole(self.original) }
        set(v) {
            let round = CGFloat(Int(self.original))
            self.original = (self.original - round) + CGFloat(v)
        }
    }
    var parts: ND? {
        get {
            switch abs(self.original).truncatingRemainder(dividingBy: 1.0) {
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
            default: return nil
            }
        }
    }
    var isFraction: Bool { get { (self.parts?.d ?? 1) > 1 } }
}
