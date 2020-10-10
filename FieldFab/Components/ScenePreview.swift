//
//  ScenePreview.swift
//  FieldFab
//
//  Created by Robert Sale on 10/2/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI
import SceneKit

struct ThreeDPreview: View {
    var dimensions: Dimensions
    @Binding var shown: Bool
    @Environment(\.colorScheme) var cs
    
    var body: some View {
        GeometryReader { g in
            ZStack {
                ScenePreview(geo: g, dimensions: dimensions, shown: $shown)
                Button(action: {
                    shown = false
                }, label: {
                    Text("Close Preview")
                })
                .padding(.all, 8)
                .background(VisualEffectView(effect: UIBlurEffect(style: .light)))
                .cornerRadius(15)
                .position(x: g.size.width / 2, y: g.size.height - 25)
            }
        }
    }
}

struct ScenePreview: UIViewRepresentable {
    var geo: GeometryProxy
    var dimensions: Dimensions
    @Binding var shown: Bool
    
    func makeUIView(context: Context) -> some UIView {
        let sceneView = SCNView(frame: CGRect(x: 0, y: 0, width: geo.size.width, height: geo.size.height))
        sceneView.allowsCameraControl = true
        sceneView.rendersContinuously = true
        guard let scene = SCNScene(named: "ductwork.scn", inDirectory: "main.scnassets")
        else { fatalError("Derp") }
        let v3D = Ductwork.getVertices3D(
            dimensions.length,
            dimensions.width,
            dimensions.depth,
            dimensions.offsetX,
            dimensions.offsetY,
            dimensions.tWidth,
            dimensions.tDepth)
        
        let camera = SCNCamera()
        camera.fieldOfView = 90
        let camNode = SCNNode()
        var maxXZ: Float = 0.0
        for (_, v) in v3D {
            maxXZ = maxXZ < max(v.x, v.z) ? max(v.x, v.z) : maxXZ
        }
        camNode.worldPosition = SCNVector3(0, 0, maxXZ * 2)
        camNode.name = "camera"
        camNode.camera = camera
        scene.rootNode.addChildNode(camNode)
        
        let node = Ductwork.getQuadGeoFromFile(dimensions)
        
        for v in node {
            scene.rootNode.addChildNode(v)
        }
        
        sceneView.scene = scene
        return sceneView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        if !shown { uiView.removeFromSuperview() }
    }
}

#if DEBUG
struct ScenePreview_Previews: PreviewProvider {
    static var previews: some View {
        StatefulPreviewWrapper(true) {
            ThreeDPreview(
                dimensions: Dimensions(
                    l: 5,
                    w: 30,
                    d: 20,
                    oX: 1,
                    oY: 0,
                    iT: true,
                    tW: 20,
                    tD: 16),
                shown: $0)
                .frame(width: 350, height: 200)
        }
    }
}
#endif
