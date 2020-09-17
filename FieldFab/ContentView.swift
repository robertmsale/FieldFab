//
//  ContentView.swift
//  FieldFab
//
//  Created by Robert Sale on 9/4/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI
import ARKit
import UIKit

struct ContentView : View {
    var body: some View {
        TabView {
            TwoD()
                .tabItem {
                    Image(systemName: "view.2d").font(.title)
                }
            ThreeD()
                .tabItem {
                    Image(systemName: "view.3d").font(.title)
                }
            
            ARViewContainer()
                .tabItem {
                    Image(systemName: "camera.viewfinder").font(.title)
                }
            Controls()
                .tabItem {
                    Image(systemName: "gear").font(.title)
                }
        }
        .padding(0)
            // 
    }
}

struct ARViewContainer: UIViewRepresentable {
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
    
    func makeUIView(context: Context) -> ARSCNView {
        
        let arView = ARSCNView(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
        let scene = SCNScene()
        arView.session = ARSession()
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        var quad = Quad.genQuadFromDimensions(
            length: self.aL.length.original,
            width: self.aL.width.original,
            depth: self.aL.depth.original,
            offsetX: self.aL.offsetX.original,
            offsetY: self.aL.offsetY.original,
            tWidth: self.aL.tWidth.original,
            tDepth: self.aL.tDepth.original)
        
        Quad.convertToAR(&quad)
        
        var faces = self.makeSideArray(quad)
        print(quad)
        
        for item in faces {
            scene.rootNode.addChildNode(SCNNode(geometry: item))
        }
        
        arView.scene = scene
        
        
        return arView
        
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {
        
    }
    
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
