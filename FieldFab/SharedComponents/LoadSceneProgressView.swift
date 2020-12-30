//
//  ProgressView.swift
//  FieldFab
//
//  Created by Robert Sale on 12/25/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI

struct LoadSceneProgressView: View {
    @State var progress: Double = 0
    
    func circlePath(_ g: GeometryProxy) -> Path {
        let mm = min(g.size.width, g.size.height) * 0.9
        let center = CGPoint(x: g.size.width / 2, y: g.size.height / 2)
        
        return Path { p in
            p.addArc(center: center, radius: mm / 2, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 180), clockwise: true)
            p.addArc(center: center, radius: mm / 2, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 0), clockwise: true)
        }
    }
    
    func progressPath( _ g: GeometryProxy) -> Path {
            let mm = min(g.size.width, g.size.height) * 0.9
            let center = CGPoint(x: g.size.width / 2, y: g.size.height / 2)
        
        return Path { p in
            p.addArc(center: center, radius: mm / 2, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 360 * (progress)), clockwise: false)
        }
    }
    
    var body: some View {
        GeometryReader { g in
            ZStack {
                circlePath(g).stroke(lineWidth: 16).fill(Color.gray)
                progressPath(g).stroke(lineWidth: 16).fill(Color.blue).animation(Animation.easeInOut.repeatForever())
                Text("Loading").font(.title)
            }
        }.opacity(progress >= 1 ? 0 : 1).onAppear { progress = 1 }
    }
}

#if DEBUG
struct ProgressView_Previews: PreviewProvider {
    static var previews: some View {
        StatefulPreviewWrapper(true) { _ in
            LoadSceneProgressView()
        }
    }
}
#endif
