//
//  Spherical.swift
//  FieldFab
//
//  Created by Robert Sale on 9/7/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI
import SceneKit

struct Spherical {
    var radius: CGFloat
    var phi: CGFloat
    var theta: CGFloat
    
    init<T: BinaryFloatingPoint>(_ r: T, _ p: T, _ t: T) {
        self.radius = CGFloat(r)
        self.phi = CGFloat(p)
        self.theta = CGFloat(t)
    }
    init<T: BinaryFloatingPoint>(radius r: T, phi p: T, theta t: T) {
        self.radius = CGFloat(r)
        self.phi = CGFloat(p)
        self.theta = CGFloat(t)
    }
    init(_ v: SCNVector3) {
        self.radius = v.x.cg
        self.phi = v.y.cg
        self.theta = v.z.cg
    }
    
    mutating func makeSafe() {
        let EPS = CGFloat(0.000001)
        self.phi = max( EPS, min( CGFloat.pi - EPS, self.phi ) )
    }
    
    mutating func set<T: BinaryFloatingPoint> (x: T, y: T, z: T) {
        let xx = x * x
        let yy = y * y
        let zz = z * z
        let radius = CGFloat(sqrt(xx + yy + zz))
        var theta: CGFloat = 0.0
        var phi: CGFloat = 0.0
        
        if radius != 0.0 {
            theta = atan2( CGFloat(x), CGFloat(z) )
            phi = acos( Math.clamp(value: CGFloat(y) / radius, min: -1, max: 1 ) )
        }
        self.radius = radius
        self.theta = theta
        self.phi = phi
    }
    
    mutating func set(_ v: SCNVector3) {
        self.set(x: v.x.cg, y: v.y.cg, z: v.z.cg)
    }
}
