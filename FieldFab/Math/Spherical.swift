//
//  Spherical.swift
//  FieldFab
//
//  Created by Robert Sale on 9/7/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI

//struct Spherical {
//    var radius: CGFloat
//    var phi: CGFloat
//    var theta: CGFloat
//    
//    init<T: BinaryFloatingPoint>(_ r: T, _ p: T, _ t: T) {
//        self.radius = CGFloat(r)
//        self.phi = CGFloat(p)
//        self.theta = CGFloat(t)
//    }
//    init<T: BinaryFloatingPoint>(radius r: T, phi p: T, theta t: T) {
//        self.radius = CGFloat(r)
//        self.phi = CGFloat(p)
//        self.theta = CGFloat(t)
//    }
//    init(from: Vector3) {
//        
//    }
//    
//    mutating func makeSafe() {
//        let EPS = CGFloat(0.000001)
//        self.phi = max( EPS, min( CGFloat.pi - EPS, self.phi ) )
//    }
//    
//    static func setFromCartesianCoords<T: BinaryFloatingPoint> (x: T, y: T, z: T) {
//        let radius = CGFloat(sqrt(x * x + y * y + z * z))
//        var theta: CGFloat = 0.0
//        var phi: CGFloat = 0.0
//        
//        if radius != 0.0 {
//            theta = atan2( CGFloat(x), CGFloat(y) )
//        }
//    }
//}
