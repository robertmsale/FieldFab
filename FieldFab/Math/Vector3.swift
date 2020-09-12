//
//  CGPointExtension.swift
//  FieldFab
//
//  Created by Robert Sale on 9/7/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI
import SceneKit

//      Base Structure
struct Vector3 {
    public var x: CGFloat
    public var y: CGFloat
    public var z: CGFloat
    
    init<T: BinaryFloatingPoint>(x: T, y: T, z: T) {
        self.x = CGFloat(x)
        self.y = CGFloat(y)
        self.z = CGFloat(z)
    }
    init<T: BinaryFloatingPoint>(_ x: T, _ y: T, _ z: T) {
        self.x = CGFloat(x)
        self.y = CGFloat(y)
        self.z = CGFloat(z)
    }
    
    mutating func addScalar<T: BinaryFloatingPoint>(scale s: T) {
        self.x = self.x + CGFloat(s)
        self.y = self.y + CGFloat(s)
        self.z = self.z + CGFloat(s)
    }
    
    mutating func addScaledVector<T: BinaryFloatingPoint>(vector v: Vector3, scale s: T) {
        self.x += v.x * CGFloat(s)
        self.y += v.y * CGFloat(s)
        self.z += v.z * CGFloat(s)
    }
    
    mutating func subScalar<T: BinaryFloatingPoint>(scale s: T) {
        self.x -= CGFloat(s)
        self.y -= CGFloat(s)
        self.z -= CGFloat(s)
    }
    
    mutating func multiplyScalar<T: BinaryFloatingPoint>(scale s: T) {
        self.x *= CGFloat(s)
        self.y *= CGFloat(s)
        self.z *= CGFloat(s)
    }
    
    mutating func divideScalar<T: BinaryFloatingPoint>(scale s: T) {
        self.x /= CGFloat(s)
        self.y /= CGFloat(s)
        self.z /= CGFloat(s)
    }
    
    mutating func floor() {
        self.x = MathUtils.floor(x: self.x)
        self.y = MathUtils.floor(x: self.y)
        self.z = MathUtils.floor(x: self.z)
    }
    
    mutating func ceil() {
        self.x = MathUtils.ceil(x: self.x)
        self.y = MathUtils.ceil(x: self.y)
        self.z = MathUtils.ceil(x: self.z)
    }
    
    func distanceSquared(to v: Vector3) -> CGFloat {
        let dx = self.x.distance(to: v.x)
        let dy = self.y.distance(to: v.y)
        let dz = self.z.distance(to: v.z)
        return dx * dx + dy * dy + dz * dz
    }
    
    func distance(to v: Vector3) -> CGFloat {
        return sqrt(self.distanceSquared(to: v))
    }
    
    func toSCNV(_ v: Vector3) -> SCNVector3 {
        return SCNVector3(v.x, v.y, v.z)
    }
    
    static func + (left: Vector3, right: Vector3) -> Vector3 {
        return Vector3(left.x + right.x, left.y + right.y, left.z + right.z)
    }
    
    static func - (left: Vector3, right: Vector3) -> Vector3 {
        return Vector3(left.x - right.x, left.y - right.y, left.z - right.z)
    }
    
    static func * (left: Vector3, right: Vector3) -> Vector3 {
        return Vector3(left.x * right.x, left.y - right.y, left.z - right.z)
    }
    
    static func / (left: Vector3, right: Vector3) -> Vector3 {
        return Vector3(left.x / right.x, left.y / right.y, left.z / right.z)
    }
    
    static func += (left: inout Vector3, right: Vector3) {
        left = left + right
    }
    
    static func +=<T: BinaryFloatingPoint> (left: inout Vector3, right: T) {
        left.addScalar(scale: right)
    }
    
    static func -= (left: inout Vector3, right: Vector3) {
        left = left - right
    }
    
    static func -=<T: BinaryFloatingPoint> (left: inout Vector3, right: T) {
        left.subScalar(scale: right)
    }
    
    static func *= (left: inout Vector3, right: Vector3) {
        left = left * right
    }
    
    static func *=<T: BinaryFloatingPoint> (left: inout Vector3, right: T) {
        left.multiplyScalar(scale: right)
    }
    
    static func /= (left: inout Vector3, right: Vector3) {
        left = left / right
    }
    
    static func /=<T: BinaryFloatingPoint> (left: inout Vector3, right: T) {
        left.divideScalar(scale: right)
    }
}

//      Equitable

extension Vector3: Equatable {
    static func == (left: Vector3, right: Vector3) -> Bool {
        return (left.x == right.x) && (left.y == right.y) && (left.z == right.z)
    }
}

struct CGPointExtension_Previews: PreviewProvider {
    static var previews: some View {
        let bl = Vector3(-16.5 / 2, 50.0, -10.0 / 2)
        let br = Vector3(16.5 / 2, 20.0, -10.0 / 2)
        
        return Text("\(bl.distance(to: br))")
    }
}
