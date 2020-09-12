//
//  3D.swift
//  FieldFab
//
//  Created by Robert Sale on 9/11/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI
import SceneKit

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
    
    func makeUIView(context: Context) -> SCNView {
        let bounding = min(self.geo.size.width, self.geo.size.height)
        let sceneView = SCNView(frame: CGRect(x: 0.0, y: 0.0, width: bounding, height: bounding))
        sceneView.allowsCameraControl = true
        sceneView.rendersContinuously = true
        guard let scene = SCNScene(named: "ductwork.scn", inDirectory: "main.scnassets")
            else { fatalError("Derp") }
        let quad = Quad.genQuadFromDimensions(
            length: self.aL.length.original,
            width: self.aL.width.original,
            depth: self.aL.depth.original,
            offsetX: self.aL.offsetX.original,
            offsetY: self.aL.offsetY.original,
            tWidth: self.aL.tWidth.original,
            tDepth: self.aL.tDepth.original)
        
        let vertices: [V3] = [
            V3(quad.front.bl.x, quad.front.bl.y, quad.front.bl.z),
            V3(quad.front.br.x, quad.front.br.y, quad.front.br.z),
            V3(quad.front.tr.x, quad.front.tr.y, quad.front.tr.z),
            V3(quad.front.tl.x, quad.front.tl.y, quad.front.tl.z),
            V3(quad.back.bl.x, quad.back.bl.y, quad.back.bl.z),
            V3(quad.back.br.x, quad.back.br.y, quad.back.br.z),
            V3(quad.back.tr.x, quad.back.tr.y, quad.back.tr.z),
            V3(quad.back.tl.x, quad.back.tl.y, quad.back.tl.z),
        ]
        
        let indices: [UInt16] = [
            0, 1, 2, // Front
            0, 2, 3,
            1, 5, 2, // Right
            5, 6, 2,
            5, 4, 7, // Back
            5, 7, 6,
            3, 2, 6, // Top
            3, 6, 7,
            4, 0, 3, // Left
            4, 3, 7,
            4, 5, 1, // Bottom
            4, 1, 0
        ]
        let ductSource = SCNGeometrySource(vertices: vertices)
        let ductNormals = SCNGeometrySource(normals: [
            (quad.back.bl * quad.front.tl),  // fbl
            V3(1.0, -1.0, 1.0),   // fbr
            V3(1.0, 1.0, 1.0),    // ftr
            V3(-1.0, 1.0, 1.0),   // ftl
            V3(-1.0, -1.0, -1.0), // bbl
            V3(1.0, -1.0, -1.0),  // bbr
            V3(1.0, 1.0, -1.0),   // btr
            V3(-1.0, 1.0, -1.0),  // btl
        ])
//            0, 1, 2,
//            2, 3, 0,
//            3, 4, 0,
//            4, 1, 0,
//            1, 5, 2,
//            2, 5, 3,
//            3, 5, 4,
//            4, 5, 1
        
        let ductElement = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        let ductGeometry = SCNGeometry(sources: [ductSource, ductNormals], elements: [ductElement])
//        ductGeometry.firstMaterial?.
        
//        let vertices: [SCNVector3] = [
//            SCNVector3(0, 1, 0),
//            SCNVector3(-0.5, 0, 0.5),
//            SCNVector3(0.5, 0, 0.5),
//            SCNVector3(0.5, 0, -0.5),
//            SCNVector3(-0.5, 0, -0.5),
//            SCNVector3(0, -1, 0),
//        ]
//
//        let source = SCNGeometrySource(vertices: vertices)
//
//         let indices: [UInt16] = [
//            0, 1, 2,
//            2, 3, 0,
//            3, 4, 0,
//            4, 1, 0,
//            1, 5, 2,
//            2, 5, 3,
//            3, 5, 4,
//            4, 5, 1
//        ]
//
//        let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
//        let geometry = SCNGeometry(sources: [source], elements: [element])
        
        let box = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
        
        scene.rootNode.addChildNode(
            SCNNode(geometry:
                ductGeometry
            )
        )
        
        sceneView.scene = scene
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        
    }
}
