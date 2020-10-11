//
//  GeometryBuilder.swift
//  FieldFab
//
//  Created by Robert Sale on 9/26/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SceneKit

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

    func getGeometry() -> SCNGeometry {

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
                let longestUEdge = max( (quad.v1-quad.v0).length(), (quad.v2-quad.v3).length() )
                let longestVEdge = max( (quad.v1-quad.v2).length(), (quad.v0-quad.v3).length() )
                uv0 = CGPoint(x: longestUEdge, y: longestVEdge)
                uv1 = CGPoint(x: zero, y: longestVEdge)
                uv2 = CGPoint(x: zero, y: zero)
                uv3 = CGPoint(x: longestUEdge, y: zero)
            case .sizeToWorldXY:
                let v2v0 = quad.v0 - quad.v2
                let v2v1 = quad.v1 - quad.v2
                let v2v3 = quad.v3 - quad.v2

                let v2v0Mag = v2v0.length()
                let v2v1Mag = v2v1.length()
                let v2v3Mag = v2v3.length()

                let v0angle = v2v3.angle(v2v0)
                let v1angle = v2v3.angle(v2v1)

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

            let v0norm = nvf1 + nvf2
            let v2norm = nvf1 + nvf2

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

        let vertSource = SCNGeometrySource(vertices: positions)

        let normalSource = SCNGeometrySource(normals: normals)

        let tcoordSource = SCNGeometrySource(textureCoordinates: tcoords)

        let element = SCNGeometryElement(indices: faceIndices, primitiveType: .triangles)

        return SCNGeometry(sources: [vertSource, normalSource, tcoordSource], elements: [element])
    }
}
