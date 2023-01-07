//
//  Math.swift
//  FieldFab
//
//  Created by Robert Sale on 12/31/22.
//  Copyright © 2022 Robert Sale. All rights reserved.
//

import Foundation
import Accelerate
import SceneKit

struct Math {
    struct Quad: ExpressibleByArrayLiteral {
        
        typealias V3 = SIMD3<Float>
        typealias ArrayLiteralElement = V3
        init(arrayLiteral elements: V3...) {
            v0 = elements[0]
            v1 = elements[1]
            v2 = elements[2]
            v3 = elements[3]
        }
        init(_ arr: [V3]) {
            v0 = arr[0]
            v1 = arr[1]
            v2 = arr[2]
            v3 = arr[3]
        }
        let v0: V3
        let v1: V3
        let v2: V3
        let v3: V3
        
        var arr: [V3] { [v0, v1, v2, v3] }
        
        subscript(_ idx: Int) -> V3 {
            switch idx % 4 {
            case 0: return v0
            case 1: return v1
            case 2: return v2
            default: return v3
            }
        }
        
        init(_ v0: V3, _ v1: V3, _ v2: V3, _ v3: V3) {
            self.v0 = v0
            self.v1 = v1
            self.v2 = v2
            self.v3 = v3
        }
    }
    
    struct Euler {
        var data: SIMD3<Float>
        enum Order { case XYZ, YXZ, ZXY, ZYX, YZX, XZY }
        var order: Order
        init(data: SIMD3<Float>, order: Order) {
            self.data = data
            self.order = order
        }
    }
    
    struct Spherical {
        typealias V3 = SIMD3<Float>
        var data: V3
        var radius: Float { get { data.x } set { data.x = newValue } }
        var theta: Float { get { data.y } set { data.y = newValue } }
        var phi: Float { get { data.z } set { data.z = newValue } }
        
        mutating func makeSafe() {
            let EPS: Float = 0.000001
            phi = max(EPS, min(Float.pi - EPS, phi))
        }
        init(radius r: Float, theta t: Float, phi p: Float) {
            data = V3(r, t, p)
        }
        init(from: V3) {
            let length = simd_length(from)
            data = V3()
            radius = length
            if length != 0 {
                theta = atan2(from.x, from.z)
                phi = acos(min(-1, max(1, (from.y / length))))
            }
        }
        init() {
            data = V3()
        }
    }
    
    struct BlockGeometryBuilder {
        var quads: [Quad] = []
        var texSize: SIMD2<Double> = .init(1.0, 1.0)
        
        enum UVMode {
            case stretchXY, stretchX, stretchY, sizeToWorldXY, sizeToWorldX
        }
        var uvMode = UVMode.stretchXY
        init(quads: [Quad] = [], texSize: SIMD2<Double> = .init(1.0, 1.0), uvMode: UVMode = UVMode.stretchXY) {
            self.texSize = texSize
            self.uvMode = uvMode
            self.quads = quads
        }
        mutating func addQuad(_ quad: Quad) { self.quads.append(quad) }
        mutating func addQuad(_ quads: [Quad]) { self.quads.append(contentsOf: quads) }
        
        func getGeometryParts() -> GeometryComplete {
            typealias V2 = SIMD2<Double>
            typealias V3 = SIMD3<Float>
            var positions: [V3] = []
            var normals: [V3] = []
            var tcoords: [V2] = []
            var faceIndices: [UInt16] = []
            
            for quad in quads {
                let nvf1 = V3.getNormal(quad.v0, quad.v1, quad.v2)
                let nvf2 = V3.getNormal(quad.v0, quad.v2, quad.v3)
                
                var uv0 = V2()
                var uv1 = V2()
                var uv2 = V2()
                var uv3 = V2()
                
                let zero = Double(0)
                
                switch self.uvMode {
                case .sizeToWorldX:
                    let longestUEdge = Double( max( simd_length(quad.v1 - quad.v0), simd_length(quad.v2 - quad.v3) ) )
                    let longestVEdge = Double( max( simd_length(quad.v1 - quad.v2), simd_length(quad.v0 - quad.v3) ) )
                    uv0 = V2(longestUEdge, longestVEdge)
                    uv1 = V2(zero, longestVEdge)
                    uv2 = V2(zero, zero)
                    uv3 = V2(longestUEdge, zero)
                case .sizeToWorldXY:
                    let v2v0 = quad.v0 - quad.v2
                    let v2v1 = quad.v1 - quad.v2
                    let v2v3 = quad.v3 - quad.v2
                    
                    let v2v0Mag = Double(simd_length(v2v0))
                    let v2v1Mag = Double(simd_length(v2v1))
                    let v2v3Mag = Double(simd_length(v2v3))
                    
                    let v0angle = Double(v2v3.angle(to: v2v0))
                    let v1angle = Double(v2v3.angle(to: v2v1))
                    
                    uv0 = V2(cos(v0angle) * v2v0Mag, sin(v0angle) * v2v0Mag)
                    uv1 = V2(cos(v1angle) * v2v1Mag, sin(v1angle) * v2v1Mag)
                    uv2 = V2(zero, zero)
                    uv3 = V2(v2v3Mag, zero)
                case .stretchXY:
                    uv0 = V2(1, 1)
                    uv1 = V2(0, 1)
                    uv2 = V2(0, 0)
                    uv3 = V2(1, 0)
                default:
                    uv0 = V2(1, 1)
                    uv1 = V2(0, 1)
                    uv2 = V2(0, 0)
                    uv3 = V2(1, 0)
                }
                
                let v0norm = nvf1 + nvf2
                let v2norm = nvf1 + nvf2
                
                positions.append(quad.v0)
                normals.append(v0norm.normal())
                tcoords.append(uv0)
                
                positions.append(quad.v1)
                normals.append(nvf1.normal())
                tcoords.append(uv1)
                
                positions.append(quad.v2)
                normals.append(v2norm.normal())
                tcoords.append(uv2)
                
                positions.append(quad.v3)
                normals.append(nvf2.normal())
                tcoords.append(uv3)
                
                faceIndices.append(UInt16(positions.count-4))
                faceIndices.append(UInt16(positions.count-3))
                faceIndices.append(UInt16(positions.count-2))
                
                faceIndices.append(UInt16(positions.count-4))
                faceIndices.append(UInt16(positions.count-2))
                faceIndices.append(UInt16(positions.count-1))
            }
            return GeometryComplete(vertices: positions, normals: normals, tcoords: tcoords, faceIndices: faceIndices)
        }
    }
    
    struct GeometryComplete: Equatable {
        typealias Source = SCNGeometrySource
        typealias Element = SCNGeometryElement
        typealias Geometry = SCNGeometry
        typealias V2 = SIMD2<Double>
        typealias V3 = SIMD3<Float>
        let vertices: [V3]
        let normals: [V3]
        let tcoords: [V2]
        let faceIndices: [UInt16]
        init(vertices verts: [V3], normals norms: [V3], tcoords tc: [V2], faceIndices faceInd: [UInt16]) {
            vertices = verts
            normals = norms
            tcoords = tc
            faceIndices = faceInd
        }
        var geometry: Geometry {
            let vertS = Source(vertices: vertices.scn)
            let normS = Source(normals: normals.scn)
            let tcoordS = Source(textureCoordinates: tcoords.cgpoints)
            let element = Element(indices: faceIndices, primitiveType: .triangles)
            return SCNGeometry(sources: [vertS, normS, tcoordS], elements: [element])
        }
        func toNode(name: String) -> SCNNode {
            let node = SCNNode(geometry: geometry)
            node.name = name
            return node
        }
    }
}
