//
//  ResetViewButton.swift
//  FieldFab
//
//  Created by Robert Sale on 9/27/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI

struct ResetViewButton: View {
    @Environment(\.colorScheme) var colorScheme
    typealias V2 = CGPoint
    
    func renderArrow(_ minC: CGFloat) -> Path {
        return Path() { p in
            p.addArc(
                center: V2(x: minC * 0.5, y: minC * 0.5),
                radius: minC * 0.325,
                startAngle: Angle(degrees: 40),
                endAngle: Angle(degrees: 180),
                clockwise: false)
            p.addLine(to: p.currentPoint!.translate(x: -(minC * 0.05)))
            p.addLine(to: p.currentPoint!.translate(V2(x: minC * 0.035 * 2, y: minC * -0.065)))
            p.addLine(to: p.currentPoint!.translate(V2(x: minC * 0.035 * 2, y: minC * 0.065)))
            p.addLine(to: p.currentPoint!.translate(x: -(minC * 0.05)))
            p.addRelativeArc(
                center: V2(x: minC / 2, y: minC / 2),
                radius: p.currentPoint!.distance(V2(x: minC / 2, y: minC / 2)),
                startAngle: Angle(degrees: 180),
                delta: Angle(degrees: -140))
//                p.addLine(to: p.)
        }
    }
    
    func renderControl(_ g: GeometryProxy) -> some View {
        let minC = min(g.size.width, g.size.height)
        
        return ZStack {
            Rectangle()
                .fill(AppColors.ControlBG[.dark])
                .opacity(colorScheme == .dark ? 0.05 : 0.1)
                .background(
                    VisualEffectView(effect: UIBlurEffect(style: colorScheme == .dark ? .dark : .light))
                )
                .cornerRadius(minC / 2)
                .zIndex(/*@START_MENU_TOKEN@*/1.0/*@END_MENU_TOKEN@*/)
            renderArrow(minC)
            .fill(Color.blue)
            .rotationEffect(Angle(degrees: 160))
            .zIndex(2.0)
            renderArrow(minC)
            .fill(Color.blue)
            .rotationEffect(Angle(degrees: -20))
            .zIndex(2.0)
                
        }.frame(width: minC, height: minC)
    }
    
    var body: some View {
        GeometryReader { g in
            renderControl(g)
        }
    }
}

struct ResetViewButton_Previews: PreviewProvider {
    static var previews: some View {
        ResetViewButton().environment(\.colorScheme, .dark)
    }
}
