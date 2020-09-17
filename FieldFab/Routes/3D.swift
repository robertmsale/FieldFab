//
//  3D.swift
//  FieldFab
//
//  Created by Robert Sale on 9/11/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI
import SceneKit
import UIKit

struct ThreeD: View {
    var body: some View {
        GeometryReader {g in
            SceneView(geo: Binding.constant(g))
        }
    }
}

struct _D_Previews: PreviewProvider {
    static var previews: some View {
        ThreeD()
    }
}

struct SceneView: UIViewRepresentable {
    @Binding var geo: GeometryProxy
    @EnvironmentObject var aL: AppLogic
    typealias V3 = SCNVector3
    
    func sideFactory(_ el: [V3]) -> SCNGeometry {
        let vertices: [V3] = [
            el[0], el[1], el[2],
            el[0], el[2], el[3]
        ]
        let normalx = V3(
            (el[1].x - el[0].x) * (el[2].x - el[0].x),
            (el[1].y - el[0].y) * (el[2].y - el[0].y),
            (el[1].z - el[0].z) * (el[2].z - el[0].z))
        let normaly = V3(
            (el[0].x - el[2].x) * (el[1].x - el[2].x),
            (el[0].y - el[2].y) * (el[1].y - el[2].y),
            (el[0].z - el[2].z) * (el[1].z - el[2].z))
        let normals: [V3] = [
            normalx,
            normalx,
            normalx,
            normalx,
            normalx,
            normalx
        ]
        let texMap = [
            CGPoint(x: 0.0, y: 0.0),
            CGPoint(x: 0.0, y: 1.0),
            CGPoint(x: 1.0, y: 1.0),
            CGPoint(x: 1.0, y: 0.0),
        ]
        let indices: [UInt16] = [
            0, 1, 2,
            3, 4, 5,
            5, 4, 3,
            2, 1, 0
        ]
        let t = SCNGeometrySource(textureCoordinates: [
            texMap[0], texMap[1], texMap[2],
            texMap[0], texMap[2], texMap[3]
        ])
        let n = SCNGeometrySource(normals: normals)
        let source = SCNGeometrySource(vertices: vertices)
        let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        let geo = SCNGeometry(sources: [source, n, t], elements: [element])
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "sheetmetal")
        material.normal.contents = UIImage(named: "sheetmetal-normal")
        geo.materials = [material]
        
        return geo
    }
    
    func makeSideArray(_ quad: Quad) -> [SCNGeometry] {
        return [
            self.sideFactory([
                quad.front.bl.toSCNV(),
                quad.front.br.toSCNV(),
                quad.front.tr.toSCNV(),
                quad.front.tl.toSCNV()
            ]),
            self.sideFactory([
                quad.back.br.toSCNV(),
                quad.back.bl.toSCNV(),
                quad.back.tl.toSCNV(),
                quad.back.tr.toSCNV()
            ]),
            self.sideFactory([
                quad.front.br.toSCNV(),
                quad.back.br.toSCNV(),
                quad.back.tr.toSCNV(),
                quad.front.tr.toSCNV()
            ]),
            self.sideFactory([
                quad.back.bl.toSCNV(),
                quad.front.bl.toSCNV(),
                quad.front.tl.toSCNV(),
                quad.back.tl.toSCNV()
            ])
        ]
    }
    
    func makeUIView(context: Context) -> SCNView {
        let bounding = min(self.geo.size.width, self.geo.size.height)
        let sceneView = SCNView(frame: CGRect(x: 0.0, y: 0.0, width: bounding, height: bounding))
        sceneView.allowsCameraControl = true
        sceneView.rendersContinuously = true
        guard let scene = SCNScene(named: "ductwork.scn", inDirectory: "main.scnassets")
            else { fatalError("Derp") }
        var quad = Quad.genQuadFromDimensions(
            length: self.aL.length.original,
            width: self.aL.width.original,
            depth: self.aL.depth.original,
            offsetX: self.aL.offsetX.original,
            offsetY: self.aL.offsetY.original,
            tWidth: self.aL.tWidth.original,
            tDepth: self.aL.tDepth.original)
        
        var faces = self.makeSideArray(quad)
        
        for item in faces {
            scene.rootNode.addChildNode(SCNNode(geometry: item))
        }
        
        Quad.convertToBounding(&quad)
        faces = self.makeSideArray(quad)
        
        for item in faces {
            item.firstMaterial?.fillMode = .lines
            item.firstMaterial?.diffuse.contents = Color.red
            scene.rootNode.addChildNode(SCNNode(geometry: item))
        }
        
        sceneView.scene = scene
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        
    }
}
