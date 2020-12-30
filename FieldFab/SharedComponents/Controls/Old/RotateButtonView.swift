//
//  RotateButtonView.swift
//  FieldFab
//
//  Created by Robert Sale on 9/27/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI

struct RotateButtonView: View {
    @Environment(\.colorScheme) var colorScheme
    var side: Side
    typealias V2 = CGPoint

    enum Side {
        case top, bottom, left, right
    }

    func renderBacking(_ minC: CGFloat) -> some View {
        var wm: CGFloat = 1.0
        var hm: CGFloat = 1.0
        if side == .top || side == .bottom { hm = 0.5 } else { wm = 0.5}
        return Rectangle()
            .fill(AppColors.ControlBG[.dark])
            .opacity(colorScheme == .dark ? 0.05 : 0.1)
            .background(VisualEffectView(effect: UIBlurEffect(style: colorScheme == .dark ? .dark : .light)))
            .cornerRadius(minC * 0.1)
            .frame(width: minC * wm, height: minC * hm, alignment: .center/*@END_MENU_TOKEN@*/)
            .position(x: minC / 2, y: minC / 2)
    }

    func renderArrow(_ minC: CGFloat) -> Path {
        var p = Path()
        if side == .bottom || side == .left {
            p.addArc(
                center: V2(x: minC * 0.5, y: minC * 0.5),
                radius: minC * 0.325,
                startAngle: Angle(degrees: 140),
                endAngle: Angle(degrees: 0),
                clockwise: true)
            p.addLine(to: p.currentPoint!.translate(x: minC * 0.05))
            p.addLine(to: p.currentPoint!.translate(V2(x: -(minC * 0.035 * 2), y: minC * -0.065)))
            p.addLine(to: p.currentPoint!.translate(V2(x: -(minC * 0.035 * 2), y: minC * 0.065)))
            p.addLine(to: p.currentPoint!.translate(x: minC * 0.05))
            p.addRelativeArc(
                center: V2(x: minC / 2, y: minC / 2),
                radius: p.currentPoint!.distance(V2(x: minC / 2, y: minC / 2)),
                startAngle: Angle(degrees: 0),
                delta: Angle(degrees: 140))
        } else {
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
        }
        return p
    }

    func renderButton (_ g: GeometryProxy) -> some View {
        let minC = min(g.size.width, g.size.height)
        var d: Double = 0
        var p: CGPoint = CGPoint(x: 0.0, y: 0.0)
        switch side {
        case .left:
            d = 110
            p = V2(x: minC / 3 * 2, y: minC / 2)
        case .top:
            d = 160
            p = V2(x: minC / 2, y: minC / 3 * 2)
        case .right:
            d = 250
            p = V2(x: minC / 3, y: minC / 2)
        case .bottom:
            d = 20
            p = V2(x: minC / 2, y: minC / 3)
        }
        return ZStack {
            renderBacking(minC)
                .zIndex(-1)
            renderArrow(minC)
                .fill(Color.blue)
                .frame(width: minC, height: minC, alignment: .center/*@END_MENU_TOKEN@*/)
                .rotationEffect(Angle(degrees: d))
                .position(p)
        }
    }

    var body: some View {
        GeometryReader { g in
            renderButton(g)
        }
    }
}

struct RotateButtonView_Previews: PreviewProvider {
    static var previews: some View {
        RotateButtonView(side: .bottom)
    }
}
