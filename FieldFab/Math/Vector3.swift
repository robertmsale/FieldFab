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

extension CGPoint {
    enum Axis {
        case x
        case y
        case xy
    }
    
    func toFloat2() -> Float2 { return Float2(x: self.x, y: self.y) }
    
    func flip(_ axis: Axis = .xy) -> CGPoint {
        switch axis {
            case .x: return CGPoint(x: -self.x, y: self.y)
            case .y: return CGPoint(x: self.x, y: -self.y)
            default: return CGPoint(x: -self.x, y: -self.y)
        }
    }
    
    func addScalar(scale s: CGFloat) -> CGPoint {
        return CGPoint(x: self.x + s, y: self.y + s)
    }
    func addScalar(_ s: CGFloat) -> CGPoint { self.addScalar(scale: s) }
    
    func addScaledVector(vector v: CGPoint, scale s: CGFloat) -> CGPoint {
        return CGPoint(x: self.x + v.x * s, y: self.y + v.y * s)
    }
    func addScaledVector(_ v: CGPoint, _ s: CGFloat) -> CGPoint { self.addScaledVector(vector: v, scale: s) }
    
    func subScalar(scale s: CGFloat) -> CGPoint {
        return CGPoint(x: self.x - s, y: self.x - s)
    }
    func subScalar(_ s: CGFloat) -> CGPoint { self.subScalar(scale: s) }
    
    func multiplyScalar(scale s: CGFloat) -> CGPoint {
        return CGPoint(x: self.x * s, y: self.y * s)
    }
    func multiplyScalar(_ s: CGFloat) -> CGPoint { self.multiplyScalar(scale: s) }
    
    func divideScalar(scale s: CGFloat) -> CGPoint {
        return CGPoint(x: self.x / s, y: self.y / s)
    }
    func divideScalar(_ s: CGFloat) -> CGPoint { self.divideScalar(scale: s) }
    
    func translate(x: CGFloat) -> CGPoint { CGPoint(x: self.x + x, y: self.y) }
    func translate(y: CGFloat) -> CGPoint { CGPoint(x: self.x, y: self.y + y) }
    func translate(_ v: CGPoint) -> CGPoint {
        return CGPoint(x: self.x + v.x, y: self.y + v.y)
    }
    
    func distance(_ to: CGPoint) -> CGFloat { sqrt(self.distanceSquared(to)) }
    
    func distanceSquared(_ to: CGPoint) -> CGFloat {
        let dx = self.x.distance(to: to.x)
        let dy = self.y.distance(to: to.y)
        return dx * dx + dy * dy
    }
    
    func rotate(degrees: CGFloat, origin: CGPoint = CGPoint(x: 0.0, y: 0.0)) -> CGPoint {
        let n = self.translate(origin.flip())
        let theta = Math.degToRad(degrees: degrees)
        let cs = cos(theta)
        let sn = sin(theta)
        let dx = n.x * cs - n.y * sn
        let dy = n.x * sn - n.y * cs
        return CGPoint(x: dx, y: dy).translate(origin)
    }
    func rotate(_ d: CGFloat, origin: CGPoint = CGPoint(x: 0.0, y: 0.0)) -> CGPoint { self.rotate(degrees: d, origin: origin) }
    
    func floor() -> CGPoint {
        return CGPoint(x: Math.floor(self.x), y: Math.floor(self.y))
    }
    
    func ceil() -> CGPoint {
        return CGPoint(x: Math.ceil(self.x), y: Math.ceil(self.y))
    }
    
    func zero(_ axis: Axis) -> CGPoint {
        var x = self.x
        var y = self.y
        switch axis {
            case .x: x = 0.0
            case .y: y = 0.0
            default: break
        }
        return CGPoint(x: x, y: y)
    }
    
    static func + (left: CGPoint, right: CGPoint) -> CGPoint { CGPoint(x: left.x + right.x, y: left.y + right.y) }
    static func - (left: CGPoint, right: CGPoint) -> CGPoint { CGPoint(x: left.x - right.x, y: left.y - right.y) }
    static func * (left: CGPoint, right: CGPoint) -> CGPoint { CGPoint(x: left.x * right.x, y: left.y * right.y) }
    static func / (left: CGPoint, right: CGPoint) -> CGPoint { CGPoint(x: left.x / right.x, y: left.y / right.y) }
}

extension SCNVector3 {
    enum Axis {
        case x
        case y
        case z
    }
    
    func toFloat3() -> Float3 { return Float3(x: self.x, y: self.y, z: self.z) }
    
    func addScalar(scale s: CGFloat) -> SCNVector3 {
        return SCNVector3(CGFloat(self.x) + s, CGFloat(self.y) + s, CGFloat(self.z) + s)
    }
    func addScalar(_ s: CGFloat) -> SCNVector3 { self.addScalar(scale: s) }
    
    func subScalar(scale s: CGFloat) -> SCNVector3 {
        return SCNVector3(CGFloat(self.x) - s, CGFloat(self.y) - s, CGFloat(self.z) - s)
    }
    func subScalar(_ s: CGFloat) -> SCNVector3 { self.subScalar(scale: s) }
    
    func multiplyScalar(scale s: CGFloat) -> SCNVector3 {
        return SCNVector3(CGFloat(self.x) * s, CGFloat(self.y) * s, CGFloat(self.z) * s)
    }
    func multiplyScalar(_ s: CGFloat) -> SCNVector3 { self.multiplyScalar(scale: s) }
    
    func divideScalar(scale s: CGFloat) -> SCNVector3 {
        return SCNVector3(CGFloat(self.x) / s, CGFloat(self.y) / s, CGFloat(self.z) / s)
    }
    
    func translate(x: CGFloat) -> SCNVector3 { SCNVector3(self.x + Float(x), self.y, self.z) }
    func translate(y: CGFloat) -> SCNVector3 { SCNVector3(self.x, self.y + Float(y), self.z) }
    func translate(z: CGFloat) -> SCNVector3 { SCNVector3(self.x, self.y, self.z + Float(z)) }
    func translate(_ v: SCNVector3) -> SCNVector3 { SCNVector3(self.x + v.x, self.y + v.y, self.z + v.z) }
    
    func floor() -> SCNVector3 {
        SCNVector3(Math.floor(self.x), Math.floor(self.y), Math.floor(self.z))
    }
    
    func ceil() -> SCNVector3 {
        SCNVector3(Math.ceil(self.x), Math.ceil(self.y), Math.ceil(self.z))
    }
    
    func zero(_ axis: Axis...) -> SCNVector3 {
        var x = self.x
        var y = self.y
        var z = self.z
        for i in axis {
            switch i {
                case .x: x = 0.0
                case .y: y = 0.0
                case .z: z = 0.0
            }
        }
        return SCNVector3(x, y, z)
    }
    
    func distance(_ to: SCNVector3) -> CGFloat {
        return CGFloat(sqrt(self.distanceSquared(to)))
    }
    
    func distanceSquared(_ to: SCNVector3) -> CGFloat {
        let dx = self.x.distance(to: to.x)
        let dy = self.y.distance(to: to.y)
        let dz = self.z.distance(to: to.z)
        return CGFloat(dx * dx + dy * dy + dz * dz)
    }
    
    func negated() -> SCNVector3 {
        return self.multiplyScalar(-1.0)
    }
    mutating func negate() { self = negated() }
    
    func length() -> CGFloat {
        return sqrt(self.x * self.x + self.y * self.y + self.z * self.z).cg
    }
    
    func normalized() -> SCNVector3 {
        let len = self.length()
        if len > 0 { return self.divideScalar(scale: len) }
        else { return SCNVector3(0.0, 0.0, 0.0) }
    }
    mutating func normalize() { self = self.normalized() }
    
    func dot(_ v: SCNVector3) -> CGFloat {
        return (self.x * v.x + self.y * v.y + self.z * v.z).cg
    }
    
    func cross(_ v: SCNVector3) -> SCNVector3 {
        return SCNVector3(
            self.y * v.z - self.z * v.y,
            self.z * v.x - self.x * v.z,
            self.x * v.y - self.y * v.x
        )
    }
    
    func toString() -> String { return "SCNVector3(x: \(self.x), y: \(self.y), z: \(self.z)" }
    
    func angle(_ v: SCNVector3) -> CGFloat {
        let dp = self.dot(v)
        let magP = self.length() * v.length()
        return acos(dp / magP)
    }
    
    mutating func constrain(_ min: SCNVector3, _ max: SCNVector3) {
        if self.x < min.x { self.x = min.x }
        if self.x > max.x { self.x = max.x }
        
        if self.y < min.y { self.y = min.y }
        if self.y > max.y { self.y = max.y }
    
        if self.z < min.z { self.z = min.z }
        if self.z > max.z { self.z = max.z }
    }
    
    static func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3(left.x + right.x, left.y + right.y, left.z + right.z)
    }
    static func + (left: SCNVector3, right: CGFloat) -> SCNVector3 {
        return left + SCNVector3(right, right, right)
    }
    
    static func - (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3(left.x - right.x, left.y - right.y, left.z - right.z)
    }
    static func - (left: SCNVector3, right: CGFloat) -> SCNVector3 {
        return left - SCNVector3(right, right, right)
    }
    
    static func * (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3(left.x * right.x, left.y * right.y, left.z * right.z)
    }
    static func * (left: SCNVector3, right: CGFloat) -> SCNVector3 {
        return left * SCNVector3(right, right, right)
    }
    
    static func / (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3(left.x / right.x, left.y / right.y, left.z / right.z)
    }
    static func / (left: SCNVector3, right: CGFloat) -> SCNVector3 {
        return left / SCNVector3(right, right, right)
    }
    
    static func += (left: inout SCNVector3, right: SCNVector3) {
        left = left + right
    }
    static func += (left: inout SCNVector3, right: CGFloat) {
        left = left + right
    }
    
    static func -= (left: inout SCNVector3, right: SCNVector3) {
        left = left - right
    }
    static func -= (left: inout SCNVector3, right: CGFloat) {
        left = left - right
    }
    
    static func *= (left: inout SCNVector3, right: SCNVector3) {
        left = left * right
    }
    static func *= (left: inout SCNVector3, right: CGFloat) {
        left = left * right
    }
    
    static func /= (left: inout SCNVector3, right: SCNVector3) {
        left = left / right
    }
    static func /= (left: inout SCNVector3, right: CGFloat) {
        left = left / right
    }
}

extension Float {
    public var cg: CGFloat { get { CGFloat(self) } set(v) { self = Float(v) } }
}

extension CGFloat {
    public var f: Float { get { Float(self) } set(v) { self = CGFloat(v) } }
}

struct Float3 {
    var x: Float
    var y: Float
    var z: Float
    
    init(x: Float, y: Float, z: Float) {
        self.x = x
        self.y = y
        self.z = z
    }
    init () {
        self.x = 0.0
        self.y = 0.0
        self.z = 0.0
    }
}

struct Float2 {
    var x: Float
    var y: Float
    
    init(s: Float, t: Float) {
        self.x = s
        self.y = t
    }
    init(x: CGFloat, y: CGFloat) { self.init(s: Float(x), t: Float(y)) }
    init () {
        self.x = 0.0
        self.y = 0.0
    }
}

struct CGPointExtension_Previews: PreviewProvider {
    static var previews: some View {
        
        return Text("Ayyyy")
    }
}
