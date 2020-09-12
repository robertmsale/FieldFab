//
//  ContentView.swift
//  FieldFab
//
//  Created by Robert Sale on 9/4/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI
import RealityKit
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
            
            ARViewContainer().edgesIgnoringSafeArea(.all)
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
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        
        // Load the "Box" scene from the "Experience" Reality File
        let boxAnchor = try! Experience.loadBox()
        
        // Add the box anchor to the scene
        arView.scene.anchors.append(boxAnchor)
        
        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
