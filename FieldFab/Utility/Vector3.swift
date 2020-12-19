//
//  Vector3.swift
//  FieldFab
//
//  Created by Robert Sale on 12/18/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import VectorProtocol
import SceneKit
import Foundation

//struct Vector3: Vector {
//    typealias Axis = V3Axis
//    var x: Measurement<UnitLength>
//    var y: Measurement<UnitLength>
//    var z: Measurement<UnitLength>
//    var scn: SCNVector3 { get { return SCNVector3(x.converted(to: .meters).value, y.converted(to: .meters).value, z.converted(to: .meters).value) } }
//    subscript(axis: Axis) -> some BinaryFloatingPoint {
//        get {
//            switch axis {
//                case .x: return x.value
//                case .y: return y.value
//                case .z: return z.value
//            }
//        } set(v) {
//            switch axis {
//                case .x: x.value = Double(v)
//                case .y: y.value = Double(v)
//                case .z: z.value = Double(v)
//            }
//        }
//    }
//    mutating func convert(to: UnitLength) {
//        x.convert(to: to)
//        y.convert(to: to)
//        z.convert(to: to)
//    }
//}
