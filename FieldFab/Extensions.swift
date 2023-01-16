//
//  Extensions.swift
//  FieldFab
//
//  Created by Robert Sale on 12/31/22.
//  Copyright © 2022 Robert Sale. All rights reserved.
//

import Foundation
import CoreGraphics
import SceneKit
import SwiftUI
import simd
import StringFix

protocol SIMDType {
    func cross(with v: Self) -> Self
    func dot(with v: Self) -> Float
    func normal() -> Self
}
protocol SIMDRepresentable {
    associatedtype Scalar: SIMDScalar
    associatedtype SIMDT: SIMD<Scalar>
    var simd: SIMDT { get set }
}

extension Float {
    func convert(to: DuctTransition.MeasurementUnit, from: DuctTransition.MeasurementUnit) -> Float {
        return Float(Measurement<UnitLength>(value: Double(self), unit: from.actualUnit).converted(to: to.actualUnit).value)
    }
}
extension Double {
    func convert(to: DuctTransition.MeasurementUnit, from: DuctTransition.MeasurementUnit) -> Double {
        return Measurement<UnitLength>(value: self, unit: from.actualUnit).converted(to: to.actualUnit).value
    }
}

extension CGPoint: SIMDRepresentable {
    typealias Scalar = Double
    typealias SIMDT = SIMD2<Scalar>
    var simd: SIMDT { get {SIMDT(x, y)} set(v){x=v.x;y=v.y}  }
    func normal() -> Self { simd.normal().cgpoint }
}
extension Array where Element == CGPoint {
    var simd: [SIMD2<Double>] { map { $0.simd } }
}
extension CGSize: SIMDRepresentable {
    typealias Scalar = Double
    typealias SIMDT = SIMD2<Scalar>
    var simd: SIMDT { get {SIMDT(width, height)} set(v){width=v.x;height=v.y} }
    func normal() -> Self { simd.normal().cgsize }
}
extension Array where Element == CGSize {
    var simd: [SIMD2<Double>] { map { $0.simd } }
}
extension SCNVector3 {
    typealias SIMDT = SIMD3<Float>
    var simd: SIMDT { get {SIMDT(x, y, z)} set(v) {x=v.x; y=v.y; z=v.z} }
    
    func cross(with v: SCNVector3) -> SCNVector3 { simd.cross(with: v.simd).scn }
    func dot(with v: SCNVector3) -> Float { simd.dot(with: v.simd) }
    func normal() -> SCNVector3 { simd.normal().scn }
}
extension Array where Element == SCNVector3 {
    var simd: [SIMD3<Float>] { map { $0.simd } }
}
extension SCNVector4 {
    var simd: SIMD4<Float> { SIMD4(x, y, z, w) }
}

extension SIMD2<Double> {
    var cgpoint: CGPoint { CGPoint(x: x, y: y) }
    var cgsize: CGSize { CGSize(width: x, height: y) }
    func normal() -> Self { simd_normalize(self) }
    func lerp(_ v: Self, alpha: Double) -> Self {
        var rv = self
        let a = Self(repeating: alpha)
        rv += (v - self) * a
        return rv
    }
}
extension Array where Element == SIMD2<Double> {
    var cgpoints: [CGPoint] { map { $0.cgpoint } }
    var cgsizes: [CGSize] { map { $0.cgsize } }
}

extension SIMD4<Float> {
    func normal() -> Self { simd_normalize(self) }
    init(euler e: Math.Euler) {
        let c1 = cos(e.data.x / 2)
        let c2 = cos(e.data.y / 2)
        let c3 = cos(e.data.z / 2)

        let s1 = sin(e.data.x / 2)
        let s2 = sin(e.data.y / 2)
        let s3 = sin(e.data.z / 2)

        switch e.order {
            case .XYZ:
                let x = s1 * c2 * c3 + c1 * s2 * s3
                let y = c1 * s2 * s3 - s1 * c2 * s3
                let z = c1 * c2 * s3 + s1 * s2 * c3
                let w = c1 * c2 * c3 - s1 * s2 * s3
                self.init(x, y, z, w)
            case .YXZ:
                let x = s1 * c2 * c3 + c1 * s2 * s3
                let y = c1 * s2 * c3 - s1 * c2 * s3
                let z = c1 * c2 * s3 - s1 * s2 * c3
                let w = c1 * c2 * c3 + s1 * s2 * s3
                self.init(x, y, z, w)
            case .ZXY:
                let x = s1 * c2 * c3 - c1 * s2 * s3
                let y = c1 * s2 * c3 + s1 * c2 * s3
                let z = c1 * c2 * s3 + s1 * s2 * c3
                let w = c1 * c2 * c3 - s1 * s2 * s3
                self.init(x, y, z, w)
            case .ZYX:
                let x = s1 * c2 * c3 - c1 * s2 * s3
                let y = c1 * s2 * c3 + s1 * c2 * s3
                let z = c1 * c2 * s3 - s1 * s2 * c3
                let w = c1 * c2 * c3 + s1 * s2 * s3
                self.init(x, y, z, w)
            case .YZX:
                let x = s1 * c2 * c3 + c1 * s2 * s3
                let y = c1 * s2 * c3 + s1 * c2 * s3
                let z = c1 * c2 * s3 - s1 * s2 * c3
                let w = c1 * c2 * c3 - s1 * s2 * s3
                self.init(x, y, z, w)
            case .XZY:
                let x = s1 * c2 * c3 - c1 * s2 * s3
                let y = c1 * s2 * c3 - s1 * c2 * s3
                let z = c1 * c2 * s3 + s1 * s2 * c3
                let w = c1 * c2 * c3 + s1 * s2 * s3
                self.init(x, y, z, w)
        }
    }
    
    init(axis: SIMD3<Float>, angle: Float) {
        let half = angle / 2
        let s = sin(half)
        self.init(axis.x * s, axis.y * s, axis.z * s, cos(half))
    }
    
    init(from: SIMD3<Float>, to: SIMD3<Float>) {
        let EPS: Float = 0.000001
        var v = Self(0, 0, 0, 1)
        
        var r = from.dot(with: to) + 1
        
        if (r < EPS) {
            r = 0
            if abs(from.x) > abs(from.z) {
                v.x = -from.y; v.y = from.x; v.z = 0; v.w = r
            } else {
                v.x = 0; v.y = -from.z; v.z = from.y; v.w = r
            }
        } else {
            v.x = from.y * to.z - from.z * to.y
            v.y = from.z * to.x - from.x * to.z
            v.z = from.x * to.y - from.y * to.x
            v.w = r
        }
//        let norm = v.normal()
        self.init(v.x, v.y, v.z, v.w)
    }
    
    func slerp(q: Self, t: Float) -> Self {
        var cpy = self
        if t == 0 { return cpy }
        if t == 1 { return q }

        var cosHalfTheta = simd_reduce_add(cpy * q)

        if ( cosHalfTheta < 0 ) {
            cpy = -q
            cosHalfTheta = -cosHalfTheta
        } else {
            cpy = q
        }

        if ( cosHalfTheta >= 1.0 ) { return cpy }
        let sqrSinHalfTheta = 1.0 - cosHalfTheta * cosHalfTheta
        let EPS = Float.ulpOfOne
        if sqrSinHalfTheta <= EPS {

            let s = 1 - t;
            cpy = (cpy * s) + (cpy * t)

            return cpy.normal()
        }

        let sinHalfTheta = sqrt( sqrSinHalfTheta )
        let halfTheta = atan2( sinHalfTheta, cosHalfTheta )
        let ratioA = sin( ( 1 - t ) * halfTheta ) / sinHalfTheta
        let ratioB = sin( t * halfTheta ) / sinHalfTheta

        cpy = (cpy * ratioA) + (cpy * ratioB)
        
        return cpy
    }
    func angle(to: Self) -> Float {
        return 2 * acos(Swift.abs( Swift.min(1.0, Swift.max(-1.0, simd_dot(self, to) )) ))
    }
}

extension SIMD3<Float>: SIMDType {
    var scn: SCNVector3 { SCNVector3(x, y, z) }
    
    var xy: SIMD2<Double> { .init(Double(x), Double(y)) }
    var zy: SIMD2<Double> { .init(Double(z), Double(y)) }
    
    mutating func set(quat q: SIMD4<Float>) {
        var a: Float, b: Float, c: Float, d: Float = 0
        a = q.w * x; b = q.y * y; c = q.z * y
        let ix = a + b - c
        a = q.w * y; b = q.z * x; c = q.x * z
        let iy = a + b - c
        a = q.w * z; b = q.x * y; c = q.y * x
        let iz = a + b - c
        a = -q.x * x; b = q.y * y; c = q.z * z
        let iw = a - b - c
        a = ix * q.w; b = iw * -q.x; c = iy * -q.z; d = iz * -q.y
        x = a + b + c - d
        a = iy * q.w; b = iw * -q.y; c = iz * -q.x; d = ix * -q.z
        y = a + b + c - d
        a = iz * q.w; b = iw * -q.z; c = iz * -q.y; d = iy * -q.x
        z = a + b + c - d
    }
    mutating func set(axis: Self, angle: Float) {
        set(quat: SIMD4<Float>(axis: axis, angle: angle))
    }
    mutating func set(euler e: Math.Euler) { set(quat: SIMD4<Float>(euler: e)) }
    mutating func set(spherical s: Math.Spherical) {
        let sinPhiRadius: Float = sin(s.phi) * s.radius
        self = Self(sinPhiRadius, cos(s.phi), sinPhiRadius) * Self(sin(s.theta), s.radius, cos(s.theta))
    }
    
    func lerp(_ v: Self, alpha: Float) -> Self {
        var rv = self
        let a = Self(repeating: alpha)
        rv += (v - self) * a
        return rv
    }
    func cross(with v: Self) -> Self { return simd_cross(self, v) }
    func dot(with v: Self) -> Float { return simd_dot(self, v) }
    func normal() -> Self { simd_normalize(self) }
    func project(on v: Self) -> Self {
        let d = simd_length_squared(v)
        if d == 0 { return Self() }
        
        let scalar = v.dot(with: self) / d
        return self * scalar
    }
    func angle(to: Self) -> Float {
        let d = sqrt(simd_length(self) * simd_length(to))
        if d == 0 { return Float.pi / 2 }
        let theta = dot(with: to) / d
        return acos(Swift.min(-1, Swift.max(theta, 1)))
    }
    static func getNormal(_ v0: Self, _ v1: Self, _ v2: Self) -> Self {
        let edgev0v1 = v1 - v0
        let edgev1v2 = v2 - v1
        return edgev0v1.cross(with: edgev1v2)
    }
}
extension Array where Element == SIMD3<Float> {
    var scn: [SCNVector3] { map { $0.scn } }
}
extension SIMD4<Float> {
    var scn: SCNVector4 { SCNVector4(x, y, z, w) }
}

protocol AppStorageExtensionProtocol {
    associatedtype UnderlyingValue
    init(wrappedValue: UnderlyingValue, _ key: String, store: UserDefaults?)
}

extension Binding {
    static func blank(_ v: Value) -> Binding<Value> {
        return Binding(get: { v }, set: { _ in })
    }
}

extension Array where Element == DuctTransition.Tab? {
    subscript(_ face: DuctTransition.Face, _ edge: DuctTransition.TabEdge) -> Element {
        get {
            let idx = face.rawValue * 4 + edge.rawValue
            return self[idx]
        } set(v) {
            let idx = face.rawValue * 4 + edge.rawValue
            self[idx] = v
        }
    }
    subscript(_ face: DuctTransition.Face) -> Array<Element> {
        get {
            let idx = face.rawValue * 4
            return [self[idx], self[idx + 1], self[idx + 2], self[idx + 3]]
        }
    }
}
