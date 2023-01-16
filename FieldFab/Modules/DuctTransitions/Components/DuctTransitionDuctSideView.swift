//
//  DuctTransitionSideView.swift
//  FieldFab
//
//  Created by Robert Sale on 12/31/22.
//  Copyright © 2022 Robert Sale. All rights reserved.
//

import SwiftUI
import simd
#if DEBUG
@_exported import HotSwiftUI
#endif

extension DuctTransition {
    struct DuctSideView: View {
        typealias V2 = SIMD2<Double>
        typealias V3 = SIMD3<Float>
        typealias CG = CGPoint
        typealias TE = DuctTransition.TabEdge
        @AppStorage(DuctTransition.AppStorageKeys.showHelpers) var showHelpers: Bool = false
        @AppStorage(AppStorageKeys.texture) var texture: String = "galvanized"
        @Environment(\.colorScheme) var colorScheme
        var ductwork: DuctTransition.DuctData
        var face: DuctTransition.Face
        var showTabInfo: Bool = false
        var showFaceInfo: Bool = false
        struct Quad {
            var tl: V2
            var tr: V2
            var bl: V2
            var br: V2
            subscript(_ idx: UInt) -> V2 {
                get {
                    switch idx % 4 {
                    case 0: return tr
                    case 1: return tl
                    case 2: return bl
                    default: return br
                    }
                } set(v) {
                    switch idx % 4 {
                    case 0: tr = v
                    case 1: tl = v
                    case 2: bl = v
                    default: br = v
                    }
                }
            }
            init(_ tr: V2, _ tl: V2, _ bl: V2, _ br: V2) {
                self.tl = tl
                self.tr = tr
                self.bl = bl
                self.br = br
            }
            var arr: [V2] { [tr, tl, bl, br] }
        }
        
        func genBoundingBox(_ g: GeometryProxy) -> Quad {
            let min = Double(min(g.size.width, g.size.height))
            let l = min * 0.2
            let r = min * 0.8
            return Quad(V2(r, l), V2(l, l), V2(l, r), V2(r, r))
        }
        
        func genPoints(
            _ g: GeometryProxy,
            vdata: DuctTransition.VertexData,
            q2D: [V2]
        ) -> [V2] {
            var bb: Quad = genBoundingBox(g)
//            let obb: Quad = bb
            
            let fOrB: Bool = face == .front || face == .back
//            let fOrL: Bool = face == .front || face == .left
            
            let measureX: DuctTransition.UserMeasurement = fOrB ? .width : .depth
            let measureTX: DuctTransition.UserMeasurement = fOrB ? .twidth : .tdepth
            let oX: DuctTransition.UserMeasurement = fOrB ? .offsetx : .offsety
            
            let w: Double = ductwork[measureX]
            let tW: Double = ductwork[measureTX]
            let oW: Double = ductwork[oX]
            let h: Double = ductwork[.length]
            
            let totalW: Double = Swift.max(Swift.min(w, tW) + Swift.abs(oW), Swift.max(w, tW))
            let ratioW: Double = Swift.max(0.7, Swift.min(1.0, totalW / h))
            let ratioH: Double = Swift.max(0.7, Swift.min(1.0, h / totalW))
            
            var cbb: Quad = bb
            bb.tr = bb.tr.lerp(cbb.br, alpha: 1 - ratioH)
            bb.tl = bb.tl.lerp(cbb.bl, alpha: 1 - ratioH)
            bb.bl = bb.bl.lerp(cbb.tl, alpha: 1 - ratioH)
            bb.br = bb.br.lerp(cbb.tr, alpha: 1 - ratioH)
            cbb = bb
            bb.tr = bb.tr.lerp(cbb.tl, alpha: 1 - ratioW)
            bb.tl = bb.tl.lerp(cbb.tr, alpha: 1 - ratioW)
            bb.bl = bb.bl.lerp(cbb.br, alpha: 1 - ratioW)
            bb.br = bb.br.lerp(cbb.bl, alpha: 1 - ratioW)
            cbb = bb
            
            let atr: V2 = q2D[0]
            let atl: V2 = q2D[1]
            let abl: V2 = q2D[2]
            let abr: V2 = q2D[3]
            let xOnly: [Double] = q2D.map { $0.x }
            let minX: Double = xOnly.min()!
            let maxX: Double = xOnly.max()!
            if atr.x < maxX {
                let ratio: Double = atr.x / maxX
                bb.tr = bb.tr.lerp(cbb.tl, alpha: min(0.4, max(0.0, (1-ratio) )))
            }
            if abs(atl.x) < abs(minX) {
                let ratio: Double = abs(atl.x) / abs(minX)
                bb.tl = bb.tl.lerp(cbb.tr, alpha: min(0.4, max(0.0, (1-ratio) )))
            }
            if abr.x < maxX {
                let ratio: Double = abr.x / maxX
                bb.br = bb.br.lerp(cbb.bl, alpha: min(0.4, max(0.0, (1-ratio) )))
            }
            if abs(abl.x) < abs(minX) {
                let ratio: Double = abs(abl.x) / abs(minX)
                bb.bl = bb.bl.lerp(cbb.br, alpha: min(0.4, max(0.0, (1-ratio) )))
            }
            if face == .back || face == .right {
                let dleft: Double = bb.tl.x - cbb.tl.x
                let dright: Double = cbb.tr.x - bb.tr.x
                bb.tr.x = cbb.tr.x - dleft
                bb.tl.x = cbb.tl.x + dright
                let dleft2: Double = bb.bl.x - cbb.bl.x
                let dright2: Double = cbb.br.x - bb.br.x
                bb.br.x = cbb.br.x - dleft2
                bb.bl.x = cbb.bl.x + dright2
            }
            return bb.arr
        }
        
        func genBoundingPoints(_ points: [V2]) -> [V2] {
            let minXY: V2 = points.reduce(V2(100000.0,100000.0), {res, next in V2(min(res.x, next.x), min(res.y, next.y))})
            let maxXY: V2 = points.reduce(V2(0.0,0.0), {res, next in V2(max(res.x, next.x), max(res.y, next.y))})
            
            let retval: [V2] = [
                V2(maxXY.x, minXY.y),
                minXY,
                V2(minXY.x, maxXY.y),
                maxXY
            ]
            return retval
        }
        
        func genTabBoundingPoints(_ points: [V2]) -> [V2] {
            typealias Tab = DuctTransition.Tab
            var retval: [V2] = points
            let tabs: [Tab?] = ductwork.tabs[face]
            if let tab: Tab = tabs[DuctTransition.TabEdge.top.rawValue] {
                retval[0] -= V2(0, CompilerRelief.tabLen * tab.length.ratio)
                retval[1] -= V2(0, CompilerRelief.tabLen * tab.length.ratio)
            }
            if let tab: Tab = tabs[DuctTransition.TabEdge.bottom.rawValue] {
                retval[2] += V2(0, CompilerRelief.tabLen * tab.length.ratio)
                retval[3] += V2(0, CompilerRelief.tabLen * tab.length.ratio)
            }
            if let tab: Tab = tabs[DuctTransition.TabEdge.left.rawValue] {
                retval[1] -= V2(CompilerRelief.tabLen * tab.length.ratio, 0)
                retval[2] -= V2(CompilerRelief.tabLen * tab.length.ratio, 0)
            }
            if let tab: Tab = tabs[DuctTransition.TabEdge.right.rawValue] {
                retval[0] += V2(CompilerRelief.tabLen * tab.length.ratio, 0)
                retval[3] += V2(CompilerRelief.tabLen * tab.length.ratio, 0)
            }
            return retval
        }
        
        
        
        func genRawMeasurements(q3D: [V3], q2D: [V2], tabs: [DuctTransition.Tab?]) -> [String] {
            let minXY: V2 = q2D.reduce(V2(100000.0, 100000.0), {res, next in V2(Swift.min(res.x, next.x), Swift.min(res.y, next.y))})
            let maxXY: V2 = q2D.reduce(V2(-100000.0, -100000.0), {res, next in V2(Swift.max(res.x, next.x), Swift.max(res.y, next.y))})
            var totalWidth: Double = simd_distance(V2(minXY.x, 0), V2(maxXY.x, 0))
            let tabWidthEdges: [DuctTransition.TabEdge] = [.left, .right]
            for edge in tabWidthEdges {
                if let tab = tabs[edge.rawValue] {
                    totalWidth += Double(tab.length.meters)
                }
            }
            
            let tabHeightEdges: [DuctTransition.TabEdge] = [.top, .bottom]
            
            var totalHeight: Double = 0.0
            if face == .front || face == .back {
                totalHeight = Double(simd_distance(q3D[1], V3(q3D[1].x, q3D[2].y, q3D[2].z)))
            } else {
                totalHeight = Double(simd_distance(q3D[1], V3(q3D[2].x, q3D[2].y, q3D[1].z)))
            }
            for edge in tabHeightEdges {
                if let tab: DuctTransition.Tab = tabs[edge.rawValue] {
                    totalHeight += Double(tab.length.meters)
                }
            }
            
            let leftCut: Double = simd_distance(V2(q2D[1].x, 0), V2(q2D[2].x, 0))
            let rightCut: Double = simd_distance(V2(q2D[0].x, 0), V2(q2D[3].x, 0))
            
            var topEdge: Double = face == .front || face == .back ? ductwork[.twidth] : ductwork[.tdepth]
            var bottomEdge: Double = face == .front || face == .back ? ductwork[.width] : ductwork[.depth]
            topEdge = topEdge.convert(to: .meters, from: ductwork.unit)
            bottomEdge = bottomEdge.convert(to: .meters, from: ductwork.unit)
            
            let leftEdge: Double = Double(simd_distance(q3D[1], q3D[2]))
            let rightEdge: Double = Double(simd_distance(q3D[0], q3D[3]))
            
            return [
                totalWidth,
                totalHeight,
                leftCut,
                rightCut,
                topEdge,
                bottomEdge,
                leftEdge,
                rightEdge
            ]
                .map { $0.convert(to: ductwork.unit, from: .meters) }
                .map { ductwork.unit.asViewOnlyString($0) }
        }
        
        struct Pathable: Identifiable {
            let points: [V2]
            var id: UUID = UUID()
        }
        
        func genTabPoints(
            _ bPoints: [V2],
            _ dPoints: [V2],
            _ tabs: [DuctTransition.Tab?]
        ) -> [Pathable] {
            typealias Tab = DuctTransition.Tab
            var retval: [[V2]] = []
            if let tab: Tab = tabs[DuctTransition.TabEdge.top.rawValue] {
                retval.append([
                    dPoints[0] - V2(0, 0),
                    dPoints[0] - V2(0, CompilerRelief.tabLen * tab.length.ratio),
                    dPoints[1] - V2(0, CompilerRelief.tabLen * tab.length.ratio),
                    dPoints[1] - V2(0, 0),
                ])
            }
            if let tab: Tab = tabs[DuctTransition.TabEdge.bottom.rawValue] {
                retval.append([
                    dPoints[2] + V2(0, 0),
                    dPoints[2] + V2(0, CompilerRelief.tabLen * tab.length.ratio),
                    dPoints[3] + V2(0, CompilerRelief.tabLen * tab.length.ratio),
                    dPoints[3] + V2(0, 0),
                ])
            }
            if let tab: Tab = tabs[DuctTransition.TabEdge.left.rawValue] {
                retval.append([
                    dPoints[1] - V2(0, 0),
                    dPoints[1] - V2(CompilerRelief.tabLen * tab.length.ratio, 0),
                    dPoints[2] - V2(CompilerRelief.tabLen * tab.length.ratio, 0),
                    dPoints[2] - V2(0, 0),
                ])
            }
            if let tab: Tab = tabs[DuctTransition.TabEdge.right.rawValue] {
                retval.append([
                    dPoints[0] + V2(0, 0),
                    dPoints[0] + V2(CompilerRelief.tabLen * tab.length.ratio, 0),
                    dPoints[3] + V2(CompilerRelief.tabLen * tab.length.ratio, 0),
                    dPoints[3] + V2(0, 0),
                ])
            }
            return retval.map { Pathable(points: $0) }
        }
        
        struct CompilerRelief {
            let g: GeometryProxy
            var ductwork: DuctTransition.DuctData
            var vdata: DuctTransition.VertexData
            let q3D: Math.Quad
            var q2D: [V2]
            let points: [V2]
            let tabs: [DuctTransition.Tab?]
            var bPoints: [V2]
            let tPoints: [V2]
            var ductPath: Path { genPath(g, points: points) }
            var bounPath: Path { genPath(g, points: bPoints) }
            var tbouPath: Path { genPath(g, points: tPoints) }
            let tabPoints: [Pathable]
            let totWPoints: [V2]
            var totWPath: Path { genPath(g, points: totWPoints, closed: false) }
            let totHPoints: [V2]
            var totHPath: Path { genPath(g, points: totHPoints, closed: false) }
            let measurements: [String]
            let face: DuctTransition.Face
            var showHelpers: Bool = false
            var showTabInfo: Bool
            var showFaceInfo: Bool
            var texture: String
            var colorScheme: ColorScheme
            
            func genPath(_ g: GeometryProxy, points: [V2], closed: Bool = true) -> Path {
                Path { p in
                    if points.isEmpty { return }
                    p.move(to: points[0].cgpoint)
                    for point in points {
                        p.addLine(to: point.cgpoint)
                    }
                    if closed { p.addLine(to: points[0].cgpoint)}
                }
            }
            
            @ViewBuilder
            func drawPaths() -> some View {
                
                ductPath
                    .fill(ImagePaint(image:Image("\(texture)-diffuse").resizable()))
                    .opacity(colorScheme == .light ? 0.5 : 1)
                if showHelpers {
                    ductPath
                        .fill(face == .front ? Color.green : face == .back ? Color.red : face == .left ? Color.yellow : Color.blue)
                        .opacity(0.5)
                }
                totWPath
                    .strokedPath(StrokeStyle(lineWidth: 1, dash: [1, 0]))
                totHPath
                    .stroke(lineWidth: 1)
                tbouPath
                    .stroke(lineWidth: 1)
                ForEach(tabPoints) { point in
                    let path = genPath(g, points: point.points)
                    path
                        .fill(ImagePaint(image: Image("\(texture)-diffuse")))
                        .opacity(colorScheme == .dark ? 0.75 : 0.25)
                }
            }
            static let tabLen: Double = 15.0
            @ViewBuilder
            func drawMorePaths() -> some View {
                if points[1].x > points[2].x {
                    Path { p in
                        
                        p.move(to: (tPoints[1]).cgpoint)
                        p.addLine(to: V2(points[1].x - (Self.tabLen * (ductwork.tabs[face, DuctTransition.TabEdge.left]?.length.ratio ?? 0)), tPoints[1].y).cgpoint)
                    }
                    .stroke(Color.red)
                } else if points[1].x < points[2].x {
                    Path { p in
                        p.move(to: tPoints[2].cgpoint)
                        p.addLine(to: V2(points[2].x - (Self.tabLen * (ductwork.tabs[face, DuctTransition.TabEdge.left]?.length.ratio ?? 0)), tPoints[2].y).cgpoint)
                    }
                    .stroke(Color.red)
                }
                if points[0].x < points[3].x {
                    Path { p in
                        p.move(to: tPoints[0].cgpoint)
                        p.addLine(to: V2(points[0].x + (Self.tabLen * (ductwork.tabs[face, DuctTransition.TabEdge.right]?.length.ratio ?? 0)), tPoints[0].y).cgpoint)
                    }
                    .stroke(Color.red)
                } else if points[0].x > points[3].x {
                    Path { p in
                        p.move(to: tPoints[3].cgpoint)
                        p.addLine(to: V2(points[3].x + (Self.tabLen * (ductwork.tabs[face, DuctTransition.TabEdge.right]?.length.ratio ?? 0)), tPoints[3].y).cgpoint)
                    }
                    .stroke(Color.red)
                }
            }
            
            @ViewBuilder
            func drawMeasurements() -> some View {
                Text(measurements[0])
                    .fixedSize()
                    .position(x: totWPoints[1].lerp(totWPoints[2], alpha: 0.5).x, y: totWPoints[1].y - 10)
                Text(measurements[1])
                    .fixedSize()
                    .rotationEffect(Angle(degrees: -90))
                    .position(totHPoints[1].lerp(totHPoints[2], alpha: 0.5).cgpoint)
                    .offset(x: -10)
                Text(measurements[face == .front || face == .left ? 2 : 3])
                    .fixedSize()
                    .position(
                        points[1].x > points[2].x ?
                        points[1].lerp(V2(points[2].x, points[1].y), alpha: 0.5).cgpoint :
                        points[2].lerp(V2(points[1].x, points[2].y), alpha: 0.5).cgpoint
                    )
                    .offset(y: points[1].x > points[2].x ? -11 : 11)
                    .offset(x: tabs[TE.left.rawValue] != nil ? -CompilerRelief.tabLen * tabs[TE.left.rawValue]!.length.ratio : 0)
                    .offset(y: points[1].x > points[2].x ?
                            tabs[TE.top.rawValue] != nil ? -CompilerRelief.tabLen * tabs[TE.top.rawValue]!.length.ratio : 0 :
                            tabs[TE.bottom.rawValue] != nil ? CompilerRelief.tabLen * tabs[TE.bottom.rawValue]!.length.ratio : 0
                    )
                    .foregroundColor(Color.red)
                    .opacity(points[1].x == points[2].x ? 0 : 1)
                Text(measurements[face == .front || face == .left ? 3 : 2])
                    .fixedSize()
//                            .background(colorScheme == .dark ? Color.black : Color.white)
                    .position(
                        points[0].x < points[3].x ?
                        points[0].lerp(V2(points[3].x, points[0].y), alpha: 0.5).cgpoint :
                        points[3].lerp(V2(points[0].x, points[3].y), alpha: 0.5).cgpoint
                    )
                    .offset(y: points[0].x < points[3].x ? -11 : 11)
                    .offset(x: tabs[TE.right.rawValue] != nil ? CompilerRelief.tabLen * tabs[TE.right.rawValue]!.length.ratio : 0)
                    .offset(y: points[0].x < points[3].x ?
                            tabs[TE.top.rawValue] != nil ? -CompilerRelief.tabLen * tabs[TE.top.rawValue]!.length.ratio : 0 :
                            tabs[TE.bottom.rawValue] != nil ? CompilerRelief.tabLen * tabs[TE.bottom.rawValue]!.length.ratio : 0
                    )
                    .foregroundColor(Color.red)
                    .opacity(points[0].x == points[3].x ? 0 : 1)
                Text(measurements[4])
                    .fixedSize()
                    .position(points[0].lerp(points[1], alpha: 0.5).cgpoint)
                    .offset(y: -11)
                    .offset(y:
                        tabs[TE.top.rawValue] != nil ? -CompilerRelief.tabLen * tabs[TE.top.rawValue]!.length.ratio : 0
                    )
                Text(measurements[5])
                    .fixedSize()
                    .position(points[2].lerp(points[3], alpha: 0.5).cgpoint)
                    .offset(y: 11)
                    .offset(y: tabs[TE.bottom.rawValue] != nil ? CompilerRelief.tabLen * tabs[TE.bottom.rawValue]!.length.ratio : 0)
                Text(measurements[6])
                    .fixedSize()
                    .rotationEffect(Angle(degrees: -90))
                    .rotationEffect(Angle(radians: {
                        let tmp = V2(points[2].x, points[1].y)
                        let o = simd_distance(tmp, points[2])
                        let a = simd_distance(tmp, points[1])
                        let retval = atan(a / o)
                        return points[1].x > points[2].x ? retval : -retval
                    }()))
                    .position(points[1].lerp(points[2], alpha: 0.5).cgpoint)
                    .offset(x: 11)
                Text(measurements[7])
                    .fixedSize()
                    .rotationEffect(Angle(degrees: -90))
                    .rotationEffect(Angle(radians: {
                        let tmp = V2(points[3].x, points[0].y)
                        let o = simd_distance(tmp, points[3])
                        let a = simd_distance(tmp, points[0])
                        let retval = atan(a / o)
                        return points[0].x > points[3].x ? retval : -retval
                    }()))
                    .position(points[0].lerp(points[3], alpha: 0.5).cgpoint)
                    .offset(x: -11)
            }
            
            @ViewBuilder
            func drawTabInfo() -> some View {
                if showTabInfo {
                    if let tab = tabs[TabEdge.top.rawValue] {
                        Text("\(tab.type.localizedString) ⤴")
                            .position(points[1].lerp(points[0], alpha: 0.5).cgpoint)
                            .offset(y: 11)
                    }
                    if let tab = tabs[TabEdge.bottom.rawValue] {
                        Text("\(tab.type.localizedString) ⤵")
                            .position(points[2].lerp(points[3], alpha: 0.5).cgpoint)
                            .offset(y: -11)
                    }
                }
                if showFaceInfo {
                    Text(face.localizedString)
                }
            }
        }
        
        var body: some View {
            GeometryReader { g in
                let vdata: DuctTransition.VertexData = ductwork.vertexData
                let q3D: Math.Quad = vdata.get3DQuad(face)
                let q2D: [V2] = vdata.get2DQuad(face, q3D).arr
                let points: [V2] = genPoints(g, vdata: vdata, q2D: q2D)
                let tabs: [DuctTransition.Tab?] = ductwork.tabs[face]
                let bPoints: [V2] = genBoundingPoints(points)
                let tPoints: [V2] = genTabBoundingPoints(bPoints)
                let tabPoints: [Pathable] = genTabPoints(bPoints, points, tabs)
                let totWPoints: [V2] = [
                    tPoints[0] - V2(0, 8),
                    tPoints[0] - V2(0, 22),
                    tPoints[1] - V2(0, 22),
                    tPoints[1] - V2(0, 8),
                ]
                let totHPoints: [V2] = [
                    tPoints[1] - V2(8, 0),
                    tPoints[1] - V2(22, 0),
                    tPoints[2] - V2(22, 0),
                    tPoints[2] - V2(8, 0),
                ]
                let measurements: [String] = genRawMeasurements(q3D: q3D.arr, q2D: q2D, tabs: tabs)
                let compilerBeNice = CompilerRelief(
                        g: g,
                        ductwork: ductwork,
                        vdata: vdata,
                        q3D: q3D,
                        q2D: q2D,
                        points: points,
                        tabs: tabs,
                        bPoints: bPoints,
                        tPoints: tPoints,
                        tabPoints: tabPoints,
                        totWPoints: totWPoints,
                        totHPoints: totHPoints,
                        measurements: measurements,
                        face: face,
                        showHelpers: showHelpers,
                        showTabInfo: showTabInfo,
                        showFaceInfo: showFaceInfo,
                        texture: texture,
                        colorScheme: colorScheme
                )
                ZStack {
                    compilerBeNice.drawPaths()
                    compilerBeNice.drawMorePaths().zIndex(5)
                    compilerBeNice.drawMeasurements()
                    compilerBeNice.drawTabInfo()
                }
//                    .frame(width: min(g.size.width, g.size.height), height: min(g.size.width, g.size.height))
                    .offset(x: (g.size.width > g.size.height ? (g.size.width - g.size.height) / 2 : 0) + 4, y: 8)
                        
            }
            #if DEBUG
            .eraseToAnyView()
            #endif
        }
        #if DEBUG
        @ObservedObject var iO = injectionObserver
        #endif
    }
}

