//
//  DistanceUnit.swift
//  FieldFab
//
//  Created by Robert Sale on 10/25/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI

//enum DistanceUnitMode: Int, CaseIterable, Identifiable {
//    case metric
//    case sae
//    var id: Int { self.rawValue }
//}

struct DistanceUnit<T: BinaryFloatingPoint> {
    var _value: T
    var type: DistanceUnitType
    
    init(_ val: T, type t: DistanceUnitType = .inch) {
        _value = val
        type = t
    }
}

enum DistanceUnitReturnType {
    case inch(Fraction)
}

enum DistanceUnitType: Int, CaseIterable, Identifiable {
    case inch
    case feet
//    case yard
//    case meter
    case centimeter
    case millimeter
    
    var id: Int { self.rawValue }
    
    func convert<T: BinaryFloatingPoint>(_ val: T, to: DistanceUnitType) -> T {
        switch self {
            case .inch:
                switch to {
                    case .feet: return val / 12
//                    case .yard: return val / 36
//                    case .meter: return val / 39.37
                    case .centimeter: return val * 2.54
                    case .millimeter: return val * 25.4
                    default: return val
                }
            case .feet:
                switch to {
                    case .inch: return val * 12
//                    case .yard: return val / 3
//                    case .meter: return val / 3.281
                    case .centimeter: return val * 30.48
                    case .millimeter: return val * 305
                    default: return val
                }
//            case .yard:
//                switch to {
//                    case .inch: return val * 36
//                    case .feet: return val * 3
//                    case .meter: return val / 1.094
//                    case .centimeter: return val * 91.44
//                    case .millimeter: return val * 914
//                    default: return val
//                }
//            case .meter:
//                switch to {
//                    case .inch: return val * 39.37
//                    case .feet: return val * 3.281
//                    case .yard: return val * 1.094
//                    case .centimeter: return val * 100
//                    case .millimeter: return val * 1000
//                    default: return val
//                }
            case .centimeter:
                switch to {
                    case .inch: return val / 2.54
                    case .feet: return val / 30.48
//                    case .yard: return val / 91.44
//                    case .meter: return val * 0.001
                    case .millimeter: return val * 10
                    default: return val
                }
            case .millimeter:
                switch to {
                    case .inch: return val / 25.4
                    case .feet: return val / 305
//                    case .yard: return val / 914
//                    case .meter: return val * 0.0001
                    case .centimeter: return val * 0.1
                    default: return val
                }
        }
    }
}
