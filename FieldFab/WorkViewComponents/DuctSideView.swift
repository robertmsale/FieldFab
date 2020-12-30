//
//  DuctSideView.swift
//  FieldFab
//
//  Created by Robert Sale on 12/26/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI
import SceneKit
import VectorExtensions
import VectorProtocol

struct DuctSideView: View {
    typealias V3 = SCNVector3
    typealias V2 = CGPoint
    var face: DuctData.Face
    var forceHelpersOff: Bool = false
    var showMeasurements: Bool = true
    @Binding var duct: Duct
    @EnvironmentObject var state: AppState
    
    func generate(g: GeometryProxy) -> some View {
        /// Max width/height
        let maxwh = min(g.size.width, g.size.height)
        /// Center of view
        let center = V2(x: maxwh/2, y: maxwh/2)
        /// Inner bounding edge scale
        let scale: CGFloat = 0.7
        var (tl, tr, bl, br) = (
            center.lerped(v: V2(x: 0, y: 0), alpha: scale),
            center.lerped(v: V2(x: maxwh, y: 0), alpha: scale),
            center.lerped(v: V2(x: 0, y: maxwh), alpha: scale),
            center.lerped(v: V2(x: maxwh, y: maxwh), alpha: scale))
        let (ctl, ctr, cbr, cbl) = (
            center.lerped(v: V2(x: 0, y: 0), alpha: scale),
            center.lerped(v: V2(x: maxwh, y: 0), alpha: scale),
            center.lerped(v: V2(x: maxwh, y: maxwh), alpha: scale),
            center.lerped(v: V2(x: 0, y: maxwh), alpha: scale)
            )
        var ntl: V2!
        var ntr: V2!
        var nbl: V2!
        var nbr: V2!
        var v3a: V3Axis!
        var v3c: [PerspectiveV3]!
        var aspectw: CGFloat!
        var aspecth: CGFloat!
        var tabt: CGFloat!
//        var tabtc: Measurement<UnitLength>?
        var tabb: CGFloat!
//        var tabbc: Measurement<UnitLength>?
        var tabl: CGFloat!
//        var tablc: Measurement<UnitLength>?
        var tabr: CGFloat!
//        var tabrc: Measurement<UnitLength>?
        let linelen: CGFloat = maxwh * 0.035
        let len2F: (DuctTab.Length) -> CGFloat = {
            switch $0 {
                case .inch: return maxwh * 0.035
                case .half: return maxwh * 0.025
                case .threeeighth: return maxwh * 0.015
            }
        }
        func processFace() {
            switch face {
                case .front:
                    v3a = .x
                    v3c = [.ftr, .ftl, .fbl, .fbr]
                    let sw = max(duct.data.width.rendered2D, duct.data.twidth.rendered2D + abs(duct.data.offsetx.rendered2D))
                    let sh = duct.data.length.rendered2D
                    if sw < sh { aspectw = sw / sh } else { aspecth = sh / sw }
                    if duct.data.tabs.ft != nil { tabt = len2F(duct.data.tabs.ft!.length) }
                    if duct.data.tabs.fb != nil { tabb = len2F(duct.data.tabs.fb!.length) }
                    if duct.data.tabs.fl != nil { tabl = len2F(duct.data.tabs.fl!.length) }
                    if duct.data.tabs.fr != nil { tabr = len2F(duct.data.tabs.fr!.length) }
                case .back:
                    v3a = .x
                    v3c = [.btr, .btl, .bbl, .bbr]
                    let sw = max(duct.data.width.rendered2D, duct.data.twidth.rendered2D + abs(duct.data.offsetx.rendered2D))
                    let sh = duct.data.length.rendered2D
                    if sw < sh { aspectw = sw / sh } else { aspecth = sh / sw }
                    if duct.data.tabs.bt != nil { tabt = len2F(duct.data.tabs.bt!.length) }
                    if duct.data.tabs.bb != nil { tabb = len2F(duct.data.tabs.bb!.length) }
                    if duct.data.tabs.bl != nil { tabl = len2F(duct.data.tabs.bl!.length) }
                    if duct.data.tabs.br != nil { tabr = len2F(duct.data.tabs.br!.length) }
                case .left:
                    v3a = .z
                    v3c = [.ltr, .ltl, .lbl, .lbr]
                    let sw = max(duct.data.depth.rendered2D, duct.data.tdepth.rendered2D + abs(duct.data.offsety.rendered2D))
                    let sh = duct.data.length.rendered2D
                    if sw < sh { aspectw = sw / sh } else { aspecth = sh / sw }
                    if duct.data.tabs.lt != nil { tabt = len2F(duct.data.tabs.lt!.length) }
                    if duct.data.tabs.lb != nil { tabb = len2F(duct.data.tabs.lb!.length) }
                    if duct.data.tabs.ll != nil { tabl = len2F(duct.data.tabs.ll!.length) }
                    if duct.data.tabs.lr != nil { tabr = len2F(duct.data.tabs.lr!.length) }
                case .right:
                    v3a = .z
                    v3c = [.rtr, .rtl, .rbl, .rbr]
                    let sw = max(duct.data.depth.rendered2D, duct.data.tdepth.rendered2D + abs(duct.data.offsety.rendered2D))
                    let sh = duct.data.length.rendered2D
                    if sw < sh { aspectw = sw / sh } else { aspecth = sh / sw }
                    if duct.data.tabs.rt != nil { tabt = len2F(duct.data.tabs.rt!.length) }
                    if duct.data.tabs.rb != nil { tabb = len2F(duct.data.tabs.rb!.length) }
                    if duct.data.tabs.rl != nil { tabl = len2F(duct.data.tabs.rl!.length) }
                    if duct.data.tabs.rr != nil { tabr = len2F(duct.data.tabs.rr!.length) }
            }
        }
        processFace()
        let tw = CGFloat(max(
            abs(duct.outer[v3c[0]][v3a]), abs(duct.outer[v3c[3]][v3a])
        ) + max(
            abs(duct.outer[v3c[2]][v3a]), abs(duct.outer[v3c[1]][v3a])
        ))
        func aspectClamp(min: CGFloat) {
            if aspectw != nil {
                tl.lerp(v: ctr, alpha: 1 - aspectw.clamp(min: min, max: 1.0))
                tr.lerp(v: ctl, alpha: 1 - aspectw.clamp(min: min, max: 1.0))
                bl.lerp(v: cbr, alpha: 1 - aspectw.clamp(min: min, max: 1.0))
                br.lerp(v: cbl, alpha: 1 - aspectw.clamp(min: min, max: 1.0))
            }
            if aspecth != nil {
                tl.lerp(v: cbl, alpha: 1 - aspecth.clamp(min: min, max: 1.0))
                tr.lerp(v: cbr, alpha: 1 - aspecth.clamp(min: min, max: 1.0))
                bl.lerp(v: ctl, alpha: 1 - aspecth.clamp(min: min, max: 1.0))
                br.lerp(v: ctr, alpha: 1 - aspecth.clamp(min: min, max: 1.0))
            }
        }
        aspectClamp(min: 0.7)
        let ml = CGFloat(abs(duct.outer[v3c[0]][v3a].distance(to: duct.outer[v3c[3]][v3a])))
        let mr = CGFloat(abs(duct.outer[v3c[1]][v3a].distance(to: duct.outer[v3c[2]][v3a])))
        func transform() {
            if abs(duct.outer[v3c[0]][v3a].distance(to: 0)) > abs(duct.outer[v3c[3]][v3a].distance(to: 0)) {
                nbr = br.lerped(v: bl, alpha: ml / tw)
            } else {
                ntr = tr.lerped(v: tl, alpha: ml / tw)
            }
            if abs(duct.outer[v3c[2]][v3a].distance(to: 0)) > abs(duct.outer[v3c[1]][v3a].distance(to: 0)) {
                ntl = tl.lerped(v: tr, alpha: mr / tw)
            } else {
                nbl = bl.lerped(v: br, alpha: mr / tw)
            }
        }
        transform()
        if ntl != nil { tl = ntl }
        if nbl != nil { bl = nbl }
        if ntr != nil { tr = ntr }
        if nbr != nil { br = nbr }
        let basePath = Path { p in
            p.move(to: tl)
            p.addLine(to: tr)
            p.addLine(to: br)
            p.addLine(to: bl)
            p.addLine(to: tl)
        }
        struct TabPath: Identifiable {
            let id: Int
            let v0: CGPoint
            let v1: CGPoint
            let v2: CGPoint
            let v3: CGPoint
        }
        var tabPaths: [TabPath] = []
        if tabt != nil {
            tabPaths.append(.init(id: 0, v0: tl, v1: tl.translated([.y: -tabt]), v2: tr.translated([.y: -tabt]), v3: tr))
        }
        if tabl != nil {
            tabPaths.append(.init(id: 1, v0: bl, v1: bl.translated([.x: -tabl]), v2: tl.translated([.x: -tabl]), v3: tl ))
//                                  path: Path { p in
//                p.move(to: bl)
//                p.addLine(to: bl.translated([.x: -tabl]))
//                p.addLine(to: tl.translated([.x: -tabl]))
//                p.addLine(to: tl)
//                p.addLine(to: bl)
//            }))
        }
        if tabr != nil {
            tabPaths.append(.init(id: 2, v0: tr, v1: tr.translated([.x: tabr]), v2: br.translated([.x: tabr]), v3: br ))
//                                  path: Path { p in
//                p.move(to: tr)
//                p.addLine(to: tr.translated([.x: tabr]))
//                p.addLine(to: br.translated([.x: tabr]))
//                p.addLine(to: br)
//                p.addLine(to: tr)
//            }))
        }
        if tabb != nil {
            tabPaths.append(.init(id: 3, v0: br, v1: br.translated([.y: tabb]), v2: bl.translated([.y: tabb]), v3: bl ))
//                                  path: Path { p in
//                p.move(to: br)
//                p.addLine(to: br.translated([.y: tabb]))
//                p.addLine(to: bl.translated([.y: tabb]))
//                p.addLine(to: bl)
//                p.addLine(to: br)
//            }))
        }
        var measurements = [
            duct.measurements[face].top.asElement,
            duct.measurements[face].bottom.asElement,
            duct.measurements[face].left.asElement,
            duct.measurements[face].right.asElement,
            duct.measurements[face].boundingLeft.asElement,
            duct.measurements[face].boundingRight.asElement,
            duct.measurements[face].totalLeft.asElement,
            duct.measurements[face].totalTop.asElement
        ]
        let bounding = basePath.boundingRect
        let btl = V2(x: bounding.minX, y: bounding.minY)
        let bbl = V2(x: bounding.minX, y: bounding.maxY)
        let bbr = V2(x: bounding.maxX, y: bounding.maxY)
        let btr = V2(x: bounding.maxX, y: bounding.minY)
        var angr: Double!
        var angl: Double!
        if btl.x == tl.x {
            let o = bbl.distance(bl).d
            let a = bbl.distance(btl).d
            if Int(o) == Int(a) { angl = 45 }
            else { angl = 90 - atan(o < a ? o / a : a / o).deg}
        } else {
            let o = btl.distance(tl).d
            let a = btl.distance(bbl).d
            if Int(o) == Int(a) { angl = 135 }
            else { angl = 90 + atan(o < a ? o / a : a / o).deg}
        }
        if btr.x == tr.x {
            let o = bbr.distance(br).d
            let a = bbr.distance(tr).d
            if Int(o) == Int(a) { angr = -45 }
            else { angr = -90 + atan(o < a ? o / a : a / o).deg}
        } else {
            let o = btr.distance(tr).d
            let a = btr.distance(bbr).d
            if Int(o) == Int(a) { angr = -135 }
            else { angr = -90 - atan(o < a ? o / a : a / o).deg}
        }
        
        func makePaths() -> some View {
            let path: (TabPath) -> Path = { d in
                return Path { p in
                    p.move(to: d.v0)
                    p.addLine(to: d.v1)
                    p.addLine(to: d.v2)
                    p.addLine(to: d.v3)
                    p.addLine(to: d.v0)
                }
            }
            return ForEach(tabPaths) { p in
                path(p).stroke(lineWidth: 1)
                Image("\(state.material)-diffuse").clipShape(path(p)).opacity(0.6)
            }
        }
        
        func helperColor() -> Color {
            switch face {
                case .front: return Color.green
                case .back: return Color.red
                case .left: return Color.yellow
                case .right: return Color.blue
            }
        }
        
        return ZStack {
            basePath.stroke(lineWidth: 1)
            Path { p in
                p.move(to: btl)
                p.addLine(to: btr)
                p.addLine(to: bbr)
                p.addLine(to: bbl)
                p.addLine(to: btl)
            }.strokedPath(StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .bevel, miterLimit: .zero, dash: [10, 10, 10, 10], dashPhase: 5))
            Image("\(state.material)-diffuse").clipShape(basePath).opacity(0.8)
            if state.showHelpers && !forceHelpersOff {
                basePath.fill(helperColor()).opacity(0.2)
            }
            makePaths()
            if showMeasurements {
                Group {
                    measurements[0].position(tl.lerped(v: tr, alpha: 0.5).subbed(V2(x: 0, y: -10)))
                    measurements[1].position(bl.lerped(v: br, alpha: 0.5).subbed(V2(x: 0, y: 10)))
                    measurements[2].rotationEffect(Angle(degrees: angl)).position(bl.lerped(v: tl, alpha: 0.5).translated([.x: 10]))
                    measurements[3].rotationEffect(Angle(degrees: angr)).position(tr.lerped(v: br, alpha: 0.5).translated([.x: -10]))
                    measurements[4].position(btl.x == tl.x ? bbl.lerped(v: bl, alpha: 0.5) : btl.lerped(v: tl, alpha: 0.5)).offset(x: 0, y: btl.x == tl.x ? 10 : -10)
                    measurements[5].position(btr.x == tr.x ? bbr.lerped(v: br, alpha: 0.5) : btr.lerped(v: tr, alpha: 0.5)).offset(x: 0, y: btr.x == tr.x ? 10 : -10)
                }
                Group {
                    Path { p in
                        p.move(to: bbl.translated([.x: -linelen, .y: tabb == nil ? 0 : tabb]))
                        p.addLine(to: p.currentPoint!.translated([.x: -linelen]))
                        p.addLine(to: btl.translated([.x: -linelen * 2, .y: tabt == nil ? 0 : -tabt]))
                        p.addLine(to: p.currentPoint!.translated([.x: linelen]))
                    }.strokedPath(StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .bevel, miterLimit: .zero, dash: [10, 10, 10, 10], dashPhase: 5))
                    HStack {
                        Text("Length: ")
                        measurements[6]
                    }.rotationEffect(Angle(degrees: -90))
                    .position(bbl.lerped(v: btl, alpha: 0.5).translated([.x: -linelen * 2 - 10]))
                    Path { p in
                        p.move(to: btl.translated([.x: tabl == nil ? 0 : -tabl, .y: -linelen]))
                        p.addLine(to: p.currentPoint!.translated([.y: -linelen]))
                        p.addLine(to: btr.translated([.x: tabr == nil ? 0 : tabr, .y: -linelen * 2]))
                        p.addLine(to: p.currentPoint!.translated([.y: linelen]))
                    }.strokedPath(StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .bevel, miterLimit: .zero, dash: [10, 10, 10, 10], dashPhase: 5))
                    HStack {
                        Text("Width: ")
                        measurements[7]
                    }.position(btl.lerped(v: btr, alpha: 0.5).translated([.y: -linelen * 2 - 10]))
                }
            }
            else {
                Text(face.rawValue).position(x: g.size.width / 2, y: g.size.height / 2).font(.caption)
            }
        }
    }
    
    var body: some View {
        GeometryReader {g in
            generate(g: g)
        }
//        VStack {
//            Text("Top: \(measurements.top.value)")
//            Text("Bottom: \(measurements.bottom.value)")
//            Text("Left: \(measurements.left.value)")
//            Text("Right: \(measurements.right.value)")
//            Text("TotalL: \(measurements.totalLeft.value)")
//            Text("TotalT: \(measurements.totalTop.value)")
//        }
    }
}

struct DuctSideView_Previews: PreviewProvider {
    static var previews: some View {let width = Measurement<UnitLength>(value: 18, unit: .inches)
        let depth = Measurement<UnitLength>(value: 20, unit: .inches)
        let length = Measurement<UnitLength>(value: 6, unit: .inches)
        let offsetx = Measurement<UnitLength>(value: 0, unit: .inches)
        let offsety = Measurement<UnitLength>(value: 0, unit: .inches)
        let twidth = Measurement<UnitLength>(value: 20, unit: .inches)
        let tdepth = Measurement<UnitLength>(value: 18, unit: .inches)
        var tabs = DuctTabContainer()
        let len = DuctTab.Length.half
        tabs.ft = .init(length: len, type: .straight)
        tabs.fb = .init(length: len, type: .straight)
        tabs.bt = .init(length: len, type: .straight)
        tabs.bb = .init(length: len, type: .straight)
        tabs.lt = .init(length: len, type: .straight)
        tabs.lb = .init(length: len, type: .straight)
        tabs.ll = .init(length: len, type: .straight)
//        tabs.lr = .init(length: .inch, type: .straight)
        tabs.rt = .init(length: len, type: .straight)
        tabs.rb = .init(length: len, type: .straight)
        tabs.rl = .init(length: len, type: .straight)
        tabs.rr = .init(length: .inch, type: .straight)
        return DuctSideView(face: .right, duct: .constant(Duct(data: .init(name: "Some duct", id: UUID(), created: Date(), width: .init(value: width), depth: .init(value: depth), length: .init(value: length), offsetx: .init(value: offsetx), offsety: .init(value: offsety), twidth: .init(value: twidth), tdepth: .init(value: tdepth), type: DuctData.DType.fourpiece, tabs: tabs)))).scaledToFit().environmentObject(AppState())
    }
}
