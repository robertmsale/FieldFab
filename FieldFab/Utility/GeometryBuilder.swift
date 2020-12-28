//
//  GeometryBuilder.swift
//  FieldFab
//
//  Created by Robert Sale on 9/26/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SceneKit
import VectorExtensions

struct GeometryBuilder {
    var quads: [Quad]
    var texSize: CGPoint

    enum UVModeType {
        case stretchXY, stretchX, stretchY, sizeToWorldXY, sizeToWorldX
    }
    var uvMode = UVModeType.stretchXY

    init() {
        self.uvMode = .stretchXY

        self.quads = []
        self.texSize = CGPoint(x: 1.0, y: 1.0)
    }
    init(quads: [Quad], uvMode: UVModeType = .stretchXY) {
        self.uvMode = uvMode
        self.quads = quads
        self.texSize = CGPoint(x: 1.0, y: 1.0)
    }

    mutating func addQuad(quad: Quad) { self.quads.append(quad) }

    func getGeometryParts() -> GeometryComplete {
        
        var positions: [SCNVector3] = []
        var normals: [SCNVector3] = []
        var tcoords: [CGPoint] = []
        var faceIndices: [UInt16] = []

        for quad in quads {
            let nvf1 = SCNUtils.getNormal(quad.v0, quad.v1, quad.v2)
            let nvf2 = SCNUtils.getNormal(quad.v0, quad.v2, quad.v3)

            var uv0 = CGPoint()
            var uv1 = CGPoint()
            var uv2 = CGPoint()
            var uv3 = CGPoint()

            let zero = CGFloat(0)

            switch self.uvMode {
            case .sizeToWorldX:
                let longestUEdge = max((quad.v1.subbed(quad.v0)).length, (quad.v2.subbed(quad.v3)).length).cg
                let longestVEdge = max((quad.v1.subbed(quad.v2)).length, (quad.v0.subbed(quad.v3)).length).cg
                uv0 = CGPoint(x: longestUEdge, y: longestVEdge)
                uv1 = CGPoint(x: zero, y: longestVEdge)
                uv2 = CGPoint(x: zero, y: zero)
                uv3 = CGPoint(x: longestUEdge, y: zero)
            case .sizeToWorldXY:
                let v2v0 = quad.v0.subbed(quad.v2)
                let v2v1 = quad.v1.subbed(quad.v2)
                let v2v3 = quad.v3.subbed(quad.v2)

                let v2v0Mag = v2v0.length.cg
                let v2v1Mag = v2v1.length.cg
                let v2v3Mag = v2v3.length.cg

                let v0angle = v2v3.angle(to: v2v0).cg
                let v1angle = v2v3.angle(to: v2v1).cg

                uv0 = CGPoint(x: cos(v0angle) * v2v0Mag, y: sin(v0angle) * v2v0Mag)
                uv1 = CGPoint(x: cos(v1angle) * v2v1Mag, y: sin(v1angle) * v2v1Mag)
                uv2 = CGPoint(x: zero, y: zero)
                uv3 = CGPoint(x: v2v3Mag, y: zero)
            case .stretchXY:
                uv0 = CGPoint(x: 1, y: 1)
                uv1 = CGPoint(x: 0, y: 1)
                uv2 = CGPoint(x: 0, y: 0)
                uv3 = CGPoint(x: 1, y: 0)
            default:
                uv0 = CGPoint(x: 1, y: 1)
                uv1 = CGPoint(x: 0, y: 1)
                uv2 = CGPoint(x: 0, y: 0)
                uv3 = CGPoint(x: 1, y: 0)
            }

            let v0norm = nvf1.added(nvf2)
            let v2norm = nvf1.added(nvf2)

            positions.append(quad.v0)
            normals.append(v0norm.normalized())
            tcoords.append(uv0)

            positions.append(quad.v1)
            normals.append(nvf1.normalized())
            tcoords.append(uv1)

            positions.append(quad.v2)
            normals.append(v2norm.normalized())
            tcoords.append(uv2)

            positions.append(quad.v3)
            normals.append(nvf2.normalized())
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
    
    func getGeometry() -> SCNGeometry {
        let complete = getGeometryParts()

        let vertSource = SCNGeometrySource(vertices: complete.vertices)

        let normalSource = SCNGeometrySource(normals: complete.normals)

        let tcoordSource = SCNGeometrySource(textureCoordinates: complete.tcoords)

        let element = SCNGeometryElement(indices: complete.faceIndices, primitiveType: .triangles)

        return SCNGeometry(sources: [vertSource, normalSource, tcoordSource], elements: [element])
    }
}

struct GeometryComplete: Equatable {
    typealias Source = SCNGeometrySource
    typealias Element = SCNGeometryElement
    typealias Geometry = SCNGeometry
    let vertices: [SCNVector3]
    let normals: [SCNVector3]
    let tcoords: [CGPoint]
    let faceIndices: [UInt16]
    init(vertices verts: [SCNVector3], normals norms: [SCNVector3], tcoords tc: [CGPoint], faceIndices faceInd: [UInt16]) {
        vertices = verts
        normals = norms
        tcoords = tc
        faceIndices = faceInd
    }
    var geometry: Geometry {
        let vertS = Source(vertices: vertices)
        let normS = Source(normals: normals)
        let tcoordS = Source(textureCoordinates: tcoords)
        let element = Element(indices: faceIndices, primitiveType: .triangles)
        return SCNGeometry(sources: [vertS, normS, tcoordS], elements: [element])
    }
    func toNode(name: String) -> SCNNode {
        let node = SCNNode(geometry: geometry)
        node.name = name
        return node
    }
}
