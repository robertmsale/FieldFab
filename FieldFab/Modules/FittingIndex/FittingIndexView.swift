//
//  FittingIndexView.swift
//  FieldFab
//
//  Created by Robert Sale on 4/3/24.
//  Copyright © 2024 Robert Sale. All rights reserved.
//

import SwiftUI
import SceneKit
import RealityKit
import ARKit
import SceneKit.ModelIO

struct FittingIndex {}

extension FittingIndex {
    struct ModuleView: View {
        var body: some View {
            TestSceneView()
                .eraseToAnyView()
            .enableInjection()
        }

        @ObserveInjection var forceRedraw
    }
    
    struct TestSceneView: UIViewRepresentable {
        func makeUIView(context: Context) -> SCNView {
            let scene = SCNScene(named: "Torpedo Boot.scn")
            let view = UIViewType(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
            view.autoenablesDefaultLighting = true
            view.allowsCameraControl = true
            
            view.scene = scene
            
            return view
        }
        
        func updateUIView(_ uiView: SCNView, context: Context) {
            
        }
        
        typealias UIViewType = SCNView
        
        
    }
}



#Preview {
    FittingIndex.ModuleView()
}
