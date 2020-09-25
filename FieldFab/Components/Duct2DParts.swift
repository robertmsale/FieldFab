////
////  Duct2DParts.swift
////  FieldFab
////
////  Created by Robert Sale on 9/20/20.
////  Copyright © 2020 Robert Sale. All rights reserved.
////
//
//import SwiftUI
//
//struct Duct2DParts {
//    public var front: Polygon2
//    public var left: Polygon2
//    public var right: Polygon2
//    public var back: Polygon2
//}
//
//protocol DuctTransform {
//    var magnitude: CGFloat { get }
//    func applyTransform(parts: Duct2DParts) -> Duct2DParts
//}
//struct DuctTranslate: DuctTransform {
//    enum Axis2D {
//        case x
//        case y
//        case xy
//    }
//    public var axis: Axis2D
//    public var magnitude: CGFloat
//    init(_ a: Axis2D, _ m: CGFloat) {
//        self.axis = a
//        self.magnitude = m
//    }
//
//    func applyTransform(parts: Duct2DParts) -> Duct2DParts {
//        var newParts = parts
//        newParts.front.translate(Vector2(
//            self.axis == .x || self.axis == .xy ? self.magnitude : 0.0,
//            self.axis == .y || self.axis == .xy ? self.magnitude : 0.0
//        ))
//        newParts.left.translate(Vector2(
//            self.axis == .x || self.axis == .xy ? self.magnitude : 0.0,
//            self.axis == .y || self.axis == .xy ? self.magnitude : 0.0
//        ))
//        newParts.right.translate(Vector2(
//            self.axis == .x || self.axis == .xy ? self.magnitude : 0.0,
//            self.axis == .y || self.axis == .xy ? self.magnitude : 0.0
//        ))
//        newParts.back.translate(Vector2(
//            self.axis == .x || self.axis == .xy ? self.magnitude : 0.0,
//            self.axis == .y || self.axis == .xy ? self.magnitude : 0.0
//        ))
//    }
//}
//struct DuctScale: DuctTransform {
//    public var magnitude: CGFloat
//    init (_ m: CGFloat) {
//        self.magnitude = m
//    }
//
//    func applyTransform(parts: Duct2DParts) -> Duct2DParts {
//        var newParts = parts
//        newParts.front.scale(self.magnitude)
//        newParts.back.scale(self.magnitude)
//        newParts.left.scale(self.magnitude)
//        newParts.right.scale(self.magnitude)
//        return newParts
//    }
//}
//struct DuctRotate: DuctTransform {
//    public var magnitude: CGFloat
//    public var origin: Vector2?
//    init (_ m: CGFloat, _ o: Vector2?) {
//        self.magnitude = m
//        self.origin = o
//    }
//
//    func applyTransform(parts: Duct2DParts) -> Duct2DParts {
//        var newParts = parts
//        newParts.front.rotate(self.magnitude, origin: self.origin ?? Vector2(0.0, 0.0))
//        return newParts
//    }
//}
//
//struct Duct2D {
//    public var parts: Duct2DParts
//    public var transforms: Dictionary<String, [DuctTransform]>
//
//    init (l: CGFloat, w: CGFloat, d: CGFloat, oX: CGFloat, oY: CGFloat, tW: CGFloat, tD: CGFloat) {
//        var faces2d: [String: Vector2] = [:]
//        var faces3d: [String: Vector3] = [:]
//
//
//        let front = Polygon2([
//            Vector2(-w / 2, -l / 2),
//            Vector2(w / 2, -l / 2),
//            Vector2(tW / 2 + oX, l / 2),
//            Vector2(-(tW / 2 - oX), l / 2)
//        ], derivedFrom: [
//            Vector3(-w / 2, -l / 2, d / 2),
//            Vector3(w / 2, -l / 2, d / 2),
//            Vector3(tW / 2 + oX, l / 2, tD / 2 + oY),
//            Vector3(-(tW / 2 - oX), l / 2, tD / 2 + oY)
//        ])
//        let right = Polygon2([
//            Vector2(d / 2, -l / 2),
//            Vector2(
//        ])
//    }
//}
