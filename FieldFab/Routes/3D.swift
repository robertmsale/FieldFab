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
    @State var helpVisible = false
    @State var sideTextShown = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader {g in
            ZStack{
                SceneView(geo: g, textShown: sideTextShown)
                Button(action: { self.helpVisible = true }, label: {
                    Image(systemName: "questionmark").font(.title)
                })
                .frame(width: 48.0, height: 48.0)
                .background(AppColors.ControlBG[colorScheme])
                .cornerRadius(45)
                .position(CGPoint(x: g.size.width - 32, y: g.size.height - 40))
                .zIndex(2.0)
                Button(action: { self.sideTextShown.toggle() }, label: {
                    Text(sideTextShown ? "Hide\nHelpers" : "Show\nHelpers")
                        .multilineTextAlignment(.center)
                        .padding()
                })
                .background(AppColors.ControlBG[colorScheme])
                .cornerRadius(15)
                .position(CGPoint(x: 62, y: g.size.height - 48))
                .zIndex(3)
                if helpVisible {
                    VisualEffectView(effect: UIBlurEffect(style: colorScheme == .dark ? .dark : .light)).zIndex(3.0)
                    CameraHelpView(g: g, visible: $helpVisible).zIndex(4.0)
                }
            }
        }
    }
}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView()
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = effect
    }
}

struct _D_Previews: PreviewProvider {
    static var previews: some View {
        let aL = AppLogic()
        aL.isTransition = true
        aL.width = Fraction(16)
        aL.depth = Fraction(20)
        aL.length = Fraction(5)
        aL.offsetX = Fraction(1)
        aL.offsetY = Fraction(1)
        aL.tWidth = Fraction(20)
        aL.tDepth = Fraction(16)
        return GeometryReader { g in
            ThreeD().environmentObject(aL)
        }
    }
}

struct SceneView: UIViewRepresentable {
    var geo: GeometryProxy
    var textShown: Bool
    @EnvironmentObject var aL: AppLogic
    typealias V3 = SCNVector3
    
    func makeUIView(context: Context) -> SCNView {
        let bounding = min(self.geo.size.width, self.geo.size.height)
        let sceneView = SCNView(frame: CGRect(x: 0.0, y: 0.0, width: bounding, height: bounding))
        
        sceneView.allowsCameraControl = true
        sceneView.rendersContinuously = true
        guard let scene = SCNScene(named: "ductwork.scn", inDirectory: "main.scnassets")
            else { fatalError("Derp") }
        
        let camera = SCNCamera()
        camera.fieldOfView = 90
        let camNode = SCNNode()
        var maxXZ: Float = 0.0
        for (_, v) in self.aL.duct.v3D {
            maxXZ = maxXZ < max(v.x, v.z) ? max(v.x, v.z) : maxXZ
        }
        camNode.worldPosition = SCNVector3(0.0, 0.0, max(self.aL.duct.b3D["ftr"]!.x,self.aL.duct.b3D["ftr"]!.z) * 4)
        camNode.name = "camera"
        camNode.camera = camera
        
        let geometryNode = self.aL.duct.getQuadGeometry(
            self.aL.offsetX.original,
            self.aL.offsetY.original,
            options: textShown ? [.sideTextShown] : [],
            tabs: Tabs())
        geometryNode.name = "duct"
        
        scene.rootNode.addChildNode(camNode)
        scene.rootNode.addChildNode(geometryNode)
        
        sceneView.scene = scene
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        uiView.scene?.rootNode.childNode(withName: "duct", recursively: false)?.removeFromParentNode()
        uiView.scene?.rootNode.childNode(withName: "camera", recursively: false)?.removeFromParentNode()
        
        let camera = SCNCamera()
        camera.fieldOfView = 90
        let camNode = SCNNode()
        var maxXZ: Float = 0.0
        for (_, v) in self.aL.duct.v3D {
            maxXZ = maxXZ < max(v.x, v.z) ? max(v.x, v.z) : maxXZ
        }
        camNode.worldPosition = SCNVector3(0.0, 0.0, maxXZ * 4)
        camNode.name = "camera"
        camNode.camera = camera
        
        let geometryNode = self.aL.duct.getQuadGeometry(
            self.aL.offsetX.original,
            self.aL.offsetY.original,
            options: textShown ? [.sideTextShown] : [],
            tabs: Tabs())
        geometryNode.name = "duct"
        
        uiView.scene?.rootNode.addChildNode(camNode)
        uiView.scene?.rootNode.addChildNode(geometryNode)
//        uiView.scene?.rootNode.addChildNode()
    }
}
