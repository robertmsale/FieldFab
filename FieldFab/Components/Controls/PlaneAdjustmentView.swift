//
//  PlaneAdjustmentView.swift
//  FieldFab
//
//  Created by Robert Sale on 9/27/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI

struct PlaneAdjustmentView: View {
    @Binding var xz: CGPoint
    var axis: Axis = .xy
    @Environment(\.colorScheme) var colorScheme
    
    enum Axis { case x, y, xy }
    
    enum Direction {
        case up, down, left, right
    }
    
    func renderChevron(_ g: GeometryProxy, direction: Direction) -> Path {
        return Path { p in
            switch direction {
                case .up:
                    p.move(to: CGPoint(x: g.size.width * 0.2, y: g.size.height * 0.5))
                    p.addLine(to: CGPoint(x: g.size.width * 0.5, y: g.size.height * 0.25))
                    p.addLine(to: CGPoint(x: g.size.width * 0.8, y: g.size.height * 0.5))
                case .down:
                    p.move(to: CGPoint(x: g.size.width * 0.2, y: g.size.height * 0.5))
                    p.addLine(to: CGPoint(x: g.size.width * 0.5, y: g.size.height * 0.75))
                    p.addLine(to: CGPoint(x: g.size.width * 0.8, y: g.size.height * 0.5))
                case .left:
                    p.move(to: CGPoint(x: g.size.width * 0.5, y: g.size.height * 0.2))
                    p.addLine(to: CGPoint(x: g.size.width * 0.25, y: g.size.height * 0.5))
                    p.addLine(to: CGPoint(x: g.size.width * 0.5, y: g.size.height * 0.8))
                case .right:
                    p.move(to: CGPoint(x: g.size.width * 0.5, y: g.size.height * 0.2))
                    p.addLine(to: CGPoint(x: g.size.width * 0.75, y: g.size.height * 0.5))
                    p.addLine(to: CGPoint(x: g.size.width * 0.5, y: g.size.height * 0.8))
            }
        }
    }
    
    func renderCBox(_ d: Direction, _ minC: CGFloat) -> some View {
        return GeometryReader { g in
            ZStack {
                RoundedRectangle(cornerRadius: minC * 0.05, style: .circular)
                    .fill(AppColors.ControlBG[.dark])
                    .frame(width: g.size.width, height: g.size.height, alignment: .center)
                    .opacity(colorScheme == .dark ? 0.05 : 0.1)
                    .background(
                        VisualEffectView(effect: UIBlurEffect(style: colorScheme == .dark ? .dark : .light))
                            .cornerRadius(minC * 0.05)
                    )
                    .zIndex(1.0)
                renderChevron(g, direction: d)
                    .stroke(lineWidth: g.size.width * 0.05)
                    .foregroundColor(.blue)
                    .zIndex(2.0)
            }
            
        }
    }
    
    func renderBackingBG() -> VisualEffectView {
        return VisualEffectView(effect: UIBlurEffect(style: colorScheme == .dark ? .dark : .light))
    }
    
    func renderBacking(_ g: GeometryProxy, _ minC: CGFloat) -> some View {
        return ZStack {
            Rectangle()
                .fill(AppColors.ControlBG[.dark])
                .opacity(colorScheme == .dark ? 0.05 : 0.1)
                .background(renderBackingBG())
                .frame(width: minC / 3, height: minC / 3)
            if axis == .x || axis == .xy {
                Rectangle()
                    .fill(AppColors.ControlBG[.dark])
                    .opacity(colorScheme == .dark ? 0.05 : 0.1)
                    .background(renderBackingBG())
                    .frame(width: minC / 3 / 2, height: minC / 3)
                    .position(x: minC / 12 * 3, y: minC / 2)
                Rectangle()
                    .fill(AppColors.ControlBG[.dark])
                    .opacity(colorScheme == .dark ? 0.05 : 0.1)
                    .background(renderBackingBG())
                    .frame(width: minC / 3 / 2, height: minC / 3)
                    .position(x: minC / 12 * 9, y: minC / 2)
            }
            if axis == .y || axis == .xy {
                Rectangle()
                    .fill(AppColors.ControlBG[.dark])
                    .opacity(colorScheme == .dark ? 0.05 : 0.1)
                    .background(renderBackingBG())
                    .frame(width: minC / 3, height: minC / 3 / 2)
                    .position(x: minC / 2, y: minC / 12 * 3)
                Rectangle()
                    .fill(AppColors.ControlBG[.dark])
                    .opacity(colorScheme == .dark ? 0.05 : 0.1)
                    .background(renderBackingBG())
                    .frame(width: minC / 3, height: minC / 3 / 2)
                    .position(x: minC / 2, y: minC / 12 * 9)
            }
        }
    }
    
    func bindGesture(_ d: Direction, _ c: Int) -> some Gesture {
        var magnitude: CGFloat = 0.0
        switch c {
            case 1: magnitude = 0.0254 / 8
            case 2: magnitude = 0.0254 / 2
            case 3: magnitude = 0.0254
            default: magnitude = 0.0254 / 8
        }
        switch d {
            case .up: return TapGesture(count: c).onEnded { self.xz = self.xz.translate(y: magnitude) }
            case .down: return TapGesture(count: c).onEnded { self.xz = self.xz.translate(y: -magnitude) }
            case .left: return TapGesture(count: c).onEnded { self.xz = self.xz.translate(x: -magnitude) }
            case .right: return TapGesture(count: c).onEnded { self.xz = self.xz.translate(x: magnitude) }
        }
    }
    
    func renderControls(_ g: GeometryProxy) -> some View {
        let minC = min(g.size.width, g.size.height)
        
        return ZStack {
            if axis == .y || axis == .xy {
                renderCBox(.up, minC)
                    .frame(width: minC / 3, height: minC / 3)
                    .position(x: minC / 2, y: (minC / 3) / 2)
                    .zIndex(6.0)
                    .gesture(bindGesture(.up, 1))
                    .gesture(bindGesture(.up, 2))
                    .gesture(bindGesture(.up, 3))
                renderCBox(.down, minC)
                    .frame(width: minC / 3, height: minC / 3)
                    .position(x: minC / 2, y: (minC / 3 * 5) / 2)
                    .zIndex(6.0)
                    .gesture(bindGesture(.down, 1))
                    .gesture(bindGesture(.down, 2))
                    .gesture(bindGesture(.down, 3))
            }
            if axis == .x || axis == .xy {
                renderCBox(.left, minC)
                    .frame(width: minC / 3, height: minC / 3)
                    .position(x: minC / 6, y: (minC / 3 * 3) / 2)
                    .zIndex(6.0)
                    .gesture(bindGesture(.left, 1))
                    .gesture(bindGesture(.left, 2))
                    .gesture(bindGesture(.left, 3))
                renderCBox(.right, minC)
                    .frame(width: minC / 3, height: minC / 3)
                    .position(x: minC - (minC / 3 / 2), y: (minC / 3 * 3) / 2)
                    .zIndex(6.0)
                    .gesture(bindGesture(.right, 1))
                    .gesture(bindGesture(.right, 2))
                    .gesture(bindGesture(.right, 3))
            }
            renderBacking(g, minC)
            
            
        }.frame(width: minC, height: minC)
    }
    
    var body: some View {
        GeometryReader { g in
            renderControls(g)
        }
    }
}

struct PlaneAdjustmentView_Previews: PreviewProvider {
    static var previews: some View {
        PlaneAdjustmentView(xz: Binding.constant(CGPoint(x: 0, y: 0)), axis: .y).environment(\.colorScheme, ColorScheme.dark)
    }
}
