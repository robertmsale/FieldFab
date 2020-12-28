//
//  RotationTest.swift
//  FieldFab
//
//  Created by Robert Sale on 12/26/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI
import SceneKit
import VectorExtensions
//import VectorProtocol

//struct Spherical {
//    #if canImport(CoreGraphics)
//    public typealias BFP = CGFloat
//    #else
//    public typealias BFP = Float
//    #endif
//    public var radius: BFP
//    public var phi: BFP
//    public var theta: BFP
//
//    public mutating func makeSafe() {
//        let EPS: BFP = 0.000001
//        phi = max(EPS, min(BFP.pi - EPS, phi))
//    }
//}

struct RotationTest: View {
    @State var pos = CGPoint(x: 0, y: 0)
    @State var oldPos = CGPoint(x: 0, y: 0)
    @State var rotating = false
    let delta: CGFloat = 1
    
    var body: some View {
        VStack {
            RotTest(pos: $pos, oldPos: $oldPos)
            HStack {
                Button(action: {pos.x += delta}, label: { Image(systemName: "chevron.left") })
                Text("X")
                Button(action: {pos.x += -delta}, label: { Image(systemName: "chevron.right") })
            }
            HStack {
                Button(action: {pos.y += delta}, label: { Image(systemName: "chevron.left") })
                Text("Y")
                Button(action: {pos.y += -delta}, label: { Image(systemName: "chevron.right") })
            }
        }
    }
}

#if DEBUG
struct DuctSCN_Preview: PreviewProvider {
    static var previews: some View {
        RotationTest()
    }
}
#endif

struct RotTest: UIViewRepresentable {
    typealias UIViewType = SCNView
    @Binding var pos: CGPoint
    @Binding var oldPos: CGPoint
    func makeUIView(context: Context) -> SCNView {
        let view = SCNView(frame: CGRect.zero)
        let scene = SCNScene()
        let boxNode = SCNNode(geometry: SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0))
        view.autoenablesDefaultLighting = true
        view.allowsCameraControl = false
        scene.rootNode.addChildNode(boxNode)
        scene.background.contents = UIColor(red: 0, green: 0, blue: 0.5, alpha: 0.5)
        let camNode = SCNNode()
        camNode.name = "camera"
        camNode.camera = SCNCamera()
        camNode.worldPosition = SCNVector3(0, 0, 4)
//        camNode.rotate(by: quat, aroundTarget: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(camNode)
        view.pointOfView = camNode
        view.scene = scene
        return view
    }
    func updateUIView(_ uiView: SCNView, context: Context) {
        let camNode = uiView.scene?.rootNode.childNode(withName: "camera", recursively: false)
        if oldPos != pos {
            var origin = Spherical(radius: 4, phi: oldPos.x.f.rad, theta: oldPos.y.f.rad)
            let dest = Spherical(radius: 4, phi: pos.x.f.rad, theta: pos.y.f.rad)
            var offset = SCNVector3()
            var quat = SCNQuaternion()
            quat.set(from: camNode!.worldUp, to: SCNVector3(0, 1, 0))
            var quatI = quat.multipliedScalar(-1)
            quatI.w = 1
            origin.theta += dest.theta
            origin.phi += dest.phi
            offset.set(spherical: origin)
            offset.set(quat: quatI)
            camNode?.worldPosition = offset
            camNode?.look(at: SCNVector3(0, 0, 0))
            oldPos = pos
        }
    }
    
//    class Coordinator {
//
//    }
}
