//
//  CGPointExtension.swift
//  FieldFab
//
//  Created by Robert Sale on 9/7/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI
import SceneKit

enum V3ToV2 {
    case xy
    case zy
}

struct Vector2 {
    public var x: CGFloat
    public var y: CGFloat
    
    init<T: BinaryFloatingPoint> (x: T, y: T) {
        self.x = CGFloat(x)
        self.y = CGFloat(y)
    }
    init<T: BinaryFloatingPoint> (_ x: T, _ y: T) {
        self.init(x: x, y: y)
    }
    init () {
        self.init(x: 0.0, y: 0.0)
    }
    init (vector: Vector3, extract: V3ToV2) {
        switch extract {
            case .xy:
                self.init(x: vector.x, y: vector.y)
            case .zy:
                self.init(x: vector.z, y: vector.y)
        }
    }
    init (_ v: Vector3, _ e: V3ToV2) {
        self.init(vector: v, extract: e)
    }
    
    mutating func addScalar<T: BinaryFloatingPoint>(scale s: T) {
        self.x = self.x + CGFloat(s)
        self.y = self.y + CGFloat(s)
    }
    
    mutating func addScaledVector<T: BinaryFloatingPoint>(vector v: Vector2, scale s: T) {
        self.x += v.x * CGFloat(s)
        self.y += v.y * CGFloat(s)
    }
    
    mutating func subScalar<T: BinaryFloatingPoint>(scale s: T) {
        self.x -= CGFloat(s)
        self.y -= CGFloat(s)
    }
    
    mutating func multiplyScalar<T: BinaryFloatingPoint>(scale s: T) {
        self.x *= CGFloat(s)
        self.y *= CGFloat(s)
    }
    
    mutating func divideScalar<T: BinaryFloatingPoint>(scale s: T) {
        self.x /= CGFloat(s)
        self.y /= CGFloat(s)
    }
    
    mutating func translate<T: BinaryFloatingPoint>(x: T) {
        self.x += CGFloat(x)
    }
    mutating func translate<T: BinaryFloatingPoint>(y: T) {
        self.y += CGFloat(y)
    }
    mutating func translate(_ v: Vector2) {
        self.x += v.x
        self.y += v.y
    }
    
    mutating func rotate<T: BinaryFloatingPoint>(degrees: T, origin: Vector2 = Vector2(0.0, 0.0)) {
        self.translate(-origin)
        let theta = MathUtils.degToRad(degrees: CGFloat(degrees))
        let cs = cos(theta)
        let sn = sin(theta)
        let dx = self.x * cs - self.y * sn
        let dy = self.x * sn - self.y * cs
        self.x = dx
        self.y = dy
        self.translate(origin)
    }
    mutating func rotate<T: BinaryFloatingPoint>(_ degrees: T, origin: Vector2 = Vector2(0.0, 0.0)) {
        self.rotate(degrees: degrees, origin: origin)
    }
    
    mutating func floor() {
        self.x = MathUtils.floor(x: self.x)
        self.y = MathUtils.floor(x: self.y)
    }
    
    mutating func ceil() {
        self.x = MathUtils.ceil(x: self.x)
        self.y = MathUtils.ceil(x: self.y)
    }
    
    func distanceSquared(to v: Vector2) -> CGFloat {
        let dx = self.x.distance(to: v.x)
        let dy = self.y.distance(to: v.y)
        return dx * dx + dy * dy
    }
    
    func distance(to v: Vector2) -> CGFloat {
        return sqrt(self.distanceSquared(to: v))
    }
    
    static func + (left: Vector2, right: Vector2) -> Vector2 {
        return Vector2(left.x + right.x, left.y + right.y)
    }
    
    static func - (left: Vector2, right: Vector2) -> Vector2 {
        return Vector2(left.x - right.x, left.y - right.y)
    }
    
    static func * (left: Vector2, right: Vector2) -> Vector2 {
        return Vector2(left.x * right.x, left.y - right.y)
    }
    
    static func / (left: Vector2, right: Vector2) -> Vector2 {
        return Vector2(left.x / right.x, left.y / right.y)
    }
    
    static func += (left: inout Vector2, right: Vector2) {
        left = left + right
    }
    
    static func +=<T: BinaryFloatingPoint> (left: inout Vector2, right: T) {
        left.addScalar(scale: right)
    }
    
    static func -= (left: inout Vector2, right: Vector2) {
        left = left - right
    }
    
    static func -=<T: BinaryFloatingPoint> (left: inout Vector2, right: T) {
        left.subScalar(scale: right)
    }
    
    static func *= (left: inout Vector2, right: Vector2) {
        left = left * right
    }
    
    static func *=<T: BinaryFloatingPoint> (left: inout Vector2, right: T) {
        left.multiplyScalar(scale: right)
    }
    
    static func /= (left: inout Vector2, right: Vector2) {
        left = left / right
    }
    
    static func /=<T: BinaryFloatingPoint> (left: inout Vector2, right: T) {
        left.divideScalar(scale: right)
    }
    
    static prefix func - (vector: Vector2) -> Vector2 {
        return Vector2(x: -vector.x, y: -vector.y)
    }
}

struct Vector3 {
    public var x: CGFloat
    public var y: CGFloat
    public var z: CGFloat
    
    init() {
        self.x = 0.0
        self.y = 0.0
        self.z = 0.0
    }
    
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
    mutating func translate<T: BinaryFloatingPoint>(x: T) {
        self.x += CGFloat(x)
    }
    mutating func translate<T: BinaryFloatingPoint>(y: T) {
        self.y += CGFloat(y)
    }
    mutating func translate<T: BinaryFloatingPoint>(z: T) {
        self.z += CGFloat(z)
    }
    mutating func translate(_ v: Vector3) {
        self.x += v.x
        self.y += v.y
        self.z += v.z
    }
    
    func lengthSquared() -> CGFloat {
        return self.x * self.x + self.y * self.y + self.z * self.z
    }
    
    func length() -> CGFloat {
        return sqrt(self.lengthSquared())
    }
    
    mutating func applyQuaternion(_ q: Quaternion) {
        var ix = q.w * self.x
        ix += q.y * self.z
        ix -= q.z * self.y
        
        var iy = q.w * self.y
        iy += q.z * self.x
        iy -= q.x * self.z
        
        var iz = q.w * self.z
        iz += q.x * self.y
        iz -= q.y * self.x
        
        var iw = -q.x * self.x
        iw -= q.y * self.y
        iw -= q.z * self.z
        
        self.x = ix * q.w
        self.x += iw * -q.x
        self.x += iy * -q.z
        self.x -= iz * -q.y
        
        self.y = iy * q.w
        self.y += iw * -q.y
        self.y += iz * -q.x
        self.y -= iz * -q.z
        
        self.z = iz * q.w
        self.z += iw * -q.z
        self.z += ix * -q.y
        self.z -= iy * -q.x
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
    
    func toSCNV() -> SCNVector3 {
        return SCNVector3(self.x, self.y, self.z)
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
    
    subscript(axis: String) -> CGFloat {
        get {
            switch axis {
                case "x": return self.x
                case "y": return self.y
                case "z": return self.z
                default: return 0.0
            }
        } set (v) {
            switch axis {
                case "x": self.x = v
                case "y": self.y = v
                case "z": self.z = v
                default: return
            }
        }
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
        let bl = Vector2(2, 2)
        let br = Vector2(2, 1)
        
        return Text("\(bl.distance(to: br))")
    }
}
