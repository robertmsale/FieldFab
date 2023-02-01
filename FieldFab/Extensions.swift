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
import SIMDExtensions

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

extension SIMD3<Float> {
    var xy: SIMD2<Double> { .init(Double(x), Double(y)) }
    var zy: SIMD2<Double> { .init(Double(z), Double(y)) }
    func angle(to: Self) -> Float {
        let d = sqrt(simd_length(self) * simd_length(to))
        if d == 0 { return Float.pi / 2 }
        let theta = dot(with: to) / d
        return Foundation.acos(Swift.min(-1, Swift.max(theta, 1)))
    }
    static func getNormal(_ v0: Self, _ v1: Self, _ v2: Self) -> Self {
        let edgev0v1 = v1 - v0
        let edgev1v2 = v2 - v1
        return edgev0v1.cross(with: edgev1v2)
    }
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

extension SCNVector3 {
    typealias SIMDT = SIMD3<Float>
    var simd: SIMDT { get {SIMDT(x, y, z)} set(v) {x=v.x; y=v.y; z=v.z} }
    
    mutating func set(spherical s: Math.Spherical) {
        let sinPhiRadius = sin(s.phi) * s.radius
        x = sinPhiRadius * sin(s.theta)
        y = cos(s.phi) * s.radius
        z = sinPhiRadius * cos(s.theta)
    }
    
    func cross(with v: SCNVector3) -> SCNVector3 { simd.cross(with: v.simd).asSCNV3 }
    func dot(with v: SCNVector3) -> Float { simd.dot(with: v.simd) }
    func normal() -> SCNVector3 { simd.normalized.asSCNV3 }
}
extension SCNVector4 {
    var simd: SIMD4<Float> { SIMD4(x, y, z, w) }
}

extension SIMD2<Double> {
    var cgpoint: CGPoint { CGPoint(x: x, y: y) }
    var cgsize: CGSize { CGSize(width: x, height: y) }
    func lerp(_ v: Self, alpha: Double) -> Self {
        var rv = self
        let a = Self(repeating: alpha)
        rv += (v - self) * a
        return rv
    }
    enum Axis {
        case x(Double)
        case y(Double)
    }
    func translate(_ along: Axis...) -> Self {
        var rv = self
        for axis in along {
            switch axis {
            case .x(let x): rv += Self(x: x, y: 0)
            case .y(let y): rv += Self(x: 0, y: y)
            }
        }
        return rv
    }
}
extension Array where Element == SIMD2<Double> {
    var cgpoints: [CGPoint] { map { $0.asCGPoint } }
    var cgsizes: [CGSize] { map { $0.asCGSize } }
}

extension Array where Element == SIMD3<Float> {
    var scn: [SCNVector3] { map { $0.asSCNV3 } }
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

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
    
        return ceil(boundingBox.height)
    }

    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)

        return ceil(boundingBox.width)
    }
}

extension BinaryFloatingPoint {
    var rad: Self { self * Self.pi / 180 }
    var deg: Self { self * 180 / Self.pi }
    var f: Float { Float(self) }
    var d: Double { Double(self) }
    var cg: CGFloat { CGFloat(self) }
}
extension BinaryInteger {
    var f: Float { Float(self) }
    var d: Double { Double(self) }
    var cg: CGFloat { CGFloat(self) }
}


