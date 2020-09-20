//
//  Polygon.swift
//  FieldFab
//
//  Created by Robert Sale on 9/19/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI
import SceneKit

enum TriOrQuad {
    case tri
    case quad
}

struct Polygon2 {
    public var derivedFrom: [Vector3]?
    public var vertices: [Vector2]
    public var lines: [Line2] {
        get {
            var lines: [Line2] = []
            for i in 1...self.vertices.count - 1 {
                lines.append(Line2(start: self.vertices[i - 1], end: self.vertices[i]))
            }
            return lines
        }
    }
    public var bounding: Polygon2 {
        get {
            var minX: CGFloat = 0.0
            var minY: CGFloat = 0.0
            var maxX: CGFloat = 0.0
            var maxY: CGFloat = 0.0
            for vertex in self.vertices {
                switch vertex {
                    case let v where v.x < minX: minX = v.x
                    case let v where v.x > maxX: maxX = v.x
                    case let v where v.y < minY: minY = v.y
                    case let v where v.y > maxY: maxY = v.y
                    default: break
                }
            }
            return Polygon2([
                Vector2(minX, minY),
                Vector2(maxX, minY),
                Vector2(maxX, maxY),
                Vector2(minX, maxY)
            ])
        }
    }
    public var center: Vector2 {
        get {
            var minX: CGFloat = 0.0
            var minY: CGFloat = 0.0
            var maxX: CGFloat = 0.0
            var maxY: CGFloat = 0.0
            for vertex in self.vertices {
                switch vertex {
                    case let v where v.x < minX: minX = v.x
                    case let v where v.x > maxX: maxX = v.x
                    case let v where v.y < minY: minY = v.y
                    case let v where v.y > maxY: maxY = v.y
                    default: break
                }
            }
            return Vector2((minX + maxX) / 2, (minY + maxY) / 2)
        }
    }
    
    mutating func translate<T: BinaryFloatingPoint>(x: T) {
        for i in 0...self.vertices.count - 1 {
            self.vertices[i].translate(x: x)
        }
    }
    mutating func translate<T: BinaryFloatingPoint>(y: T) {
        for i in 0...self.vertices.count - 1 {
            self.vertices[i].translate(y: y)
        }
    }
    mutating func translate(_ v: Vector2) {
        for i in 0...self.vertices.count - 1 {
            self.vertices[i].translate(v)
        }
    }
    mutating func rotate<T: BinaryFloatingPoint>(degrees: T, origin: Vector2 = Vector2(0.0, 0.0)) {
        for i in 0...self.vertices.count - 1 {
            self.vertices[i].rotate(degrees, origin: origin)
        }
    }
    mutating func rotate<T: BinaryFloatingPoint>(_ degrees: T, origin: Vector2 = Vector2(0.0, 0.0)) {
        for i in 0...self.vertices.count - 1 {
            self.vertices[i].rotate(degrees, origin: origin)
        }
    }
    mutating func scale<T: BinaryFloatingPoint>(_ s: T) {
        for i in 0...self.vertices.count - 1 {
            self.vertices[i].addScalar(scale: s)
        }
    }
    
    init(vertices: [Vector2]) {
        self.vertices = vertices
    }
    init(_ v: [Vector2]) {
        self.vertices = v
    }
    init(_ v: [Vector2], derivedFrom: [Vector3]) {
        self.vertices = v
        self.derivedFrom = derivedFrom
    }
}

struct Polygon3 {
    typealias V3 = SCNVector3
    enum PolyPart {
        case tl
        case br
    }
    enum PolyDir {
        case inner
        case outer
    }
    public var polyPart: PolyPart
    public var polyDir: PolyDir
    public var vertices: [Vector3]
    public var normals: [V3] {
        get {
            let n = V3(
                (self.vertices[1].x - self.vertices[0].x) * (self.vertices[2].x - self.vertices[0].x),
                (self.vertices[1].y - self.vertices[0].y) * (self.vertices[2].y - self.vertices[0].y),
                (self.vertices[1].z - self.vertices[0].z) * (self.vertices[2].z - self.vertices[0].z)
            )
            return [n, n, n]
        }
    }
    public let texMap: [CGPoint] = [
        CGPoint(x: 0.0, y: 0.0),
        CGPoint(x: 1.0, y: 0.0),
        CGPoint(x: 1.0, y: 1.0),
        CGPoint(x: 0.0, y: 1.0)
    ]
    public var indices: [UInt16] {
        get {
            switch self.polyDir {
                case .inner:
                    return [2, 1, 0]
                case .outer:
                    return [0, 1, 2]
            }
        }
    }
    public var texSource: SCNGeometrySource {
        get {
            switch self.polyPart {
                case .br: return SCNGeometrySource(textureCoordinates: [
                    texMap[0], texMap[1], texMap[2]
                ])
                case .tl: return SCNGeometrySource(textureCoordinates: [
                    texMap[0], texMap[2], texMap[3]
                ])
            }
        }
    }
    public var normalSource: SCNGeometrySource {
        get { SCNGeometrySource(normals: self.normals) }
    }
    public var geoSource: SCNGeometrySource {
        get { SCNGeometrySource(vertices: [
            V3(self.vertices[0].x, self.vertices[0].y, self.vertices[0].z),
            V3(self.vertices[1].x, self.vertices[1].y, self.vertices[1].z),
            V3(self.vertices[2].x, self.vertices[2].y, self.vertices[2].z),
        ])}
    }
    public var element: SCNGeometryElement {
        get { SCNGeometryElement(indices: self.indices, primitiveType: .triangles) }
    }
    public var geo: SCNGeometry {
        get { SCNGeometry(sources: [self.geoSource, self.normalSource, self.texSource], elements: [self.element]) }
    }
    public var material: SCNMaterial
    
    init(vertices v: [Vector3], part p: PolyPart, direction d: PolyDir) {
        self.vertices = v
        self.polyPart = p
        self.polyDir = d
        self.material = SCNMaterial()
    }
}
