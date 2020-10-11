//
//  DuctSideView.swift
//  FieldFab
//
//  Created by Robert Sale on 9/6/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI

enum TwoDAxis {
    case x
    case y
}

struct TabPath: Identifiable {
    let id: UUID
    var path: Path
}

struct DuctPoints {
    var bl: CGPoint
    var br: CGPoint
    var tl: CGPoint
    var tr: CGPoint

    mutating func translate(_ a: TwoDAxis, _ m: CGFloat) {
        if a == .x {
            self.bl.x += m
            self.br.x += m
            self.tl.x += m
            self.tr.x += m
        } else {
            self.bl.y += m
            self.br.y += m
            self.tl.y += m
            self.tr.y += m
        }
    }

    mutating func scale(_ a: TwoDAxis, _ m: CGFloat) {
        if a == .x {
            self.bl.x *= m
            self.br.x *= m
            self.tl.x *= m
            self.tr.x *= m
        } else {
            self.bl.y *= m
            self.br.y *= m
            self.tl.y *= m
            self.tr.y *= m
        }
    }

    mutating func applyTransform(_ t: CGAffineTransform) {
        self.bl = self.bl.applying(t)
        self.br = self.br.applying(t)
        self.tl = self.tl.applying(t)
        self.tr = self.tr.applying(t)
    }
}

struct DuctSideView: View {
    @EnvironmentObject var aL: AppLogic
    var g: GeometryProxy
    var side: DuctFace
    var shapePos: CGPoint = CGPoint(x: 0.0, y: 0.0)
    var shapeScale: CGFloat = 0.75
    @Environment(\.colorScheme) var colorScheme

    func applyTransforms(_ v: [String: CGPoint]) -> [String: CGPoint] {
        let center = self.g.size.center
        let shapeW = abs(min(v["bl"]!.x, v["tl"]!.x).distance(to: max(v["br"]!.x, v["tr"]!.x)))
        let shapeH = v["tl"]!.y.distance(to: v["bl"]!.y)
        let sMax = max(shapeH, shapeW)
        let cMin = min(self.g.size.width, self.g.size.height)
        let xMin = 0 + (cMin - (cMin * shapeScale)) / 2
        let xMax = cMin - xMin
        let b4p = [
            "bl": v["bl"]!.multiplyScalar(cMin / sMax * max(self.shapeScale, 0.25)),
            "br": v["br"]!.multiplyScalar(cMin / sMax * max(self.shapeScale, 0.25)),
            "tl": v["tl"]!.multiplyScalar(cMin / sMax * max(self.shapeScale, 0.25)),
            "tr": v["tr"]!.multiplyScalar(cMin / sMax * max(self.shapeScale, 0.25))
        ]
        var p = [
            "bl": center.translate(b4p["bl"]!),
            //                .addScalar(cMin / sMax * self.shapeScale),
            //                .translate(self.shapePos),
            "br": center.translate(b4p["br"]!),
            //                .addScalar(cMin / sMax * self.shapeScale),
            //                .translate(self.shapePos),
            "tl": center.translate(b4p["tl"]!),
            //                .addScalar(cMin / sMax * self.shapeScale),
            //                .translate(self.shapePos),
            "tr": center.translate(b4p["tr"]!)
            //                .addScalar(cMin / sMax * self.shapeScale)
            //                .translate(self.shapePos)
        ]
        var transLeft: CGFloat = 0
        var transRight: CGFloat = 0
        for (k, v) in p {
            switch k {
            case "bl", "tl":
                if v.x < xMin { transLeft = v.x.distance(to: xMin) }
            case "br", "tr":
                if v.x > xMax { transRight = -xMax.distance(to: v.x) }
            default: break
            }
        }
        for (k, v) in p {
            p[k] = v.translate(x: transLeft).translate(x: transRight)
        }
        return p
    }
    
    func genTabs(_ v: [String: CGPoint]) -> [TabPath] {
        var paths: [TabPath] = []
        if aL.tabs[side].top.getType() != .none {
            var d = CGFloat(0)
            switch aL.tabs[side].top.getLength() {
                case .inch: d = -10
                case .half: d = -5
                case .threeEighth: d = -3
                default: break
            }
            let p = CGMutablePath()
            p.move(to: v["tl"]!)
            p.addLine(to: p.currentPoint.translate(y: d))
            p.addLine(to: v["tr"]!.translate(y: d))
            p.addLine(to: v["tr"]!)
            p.addLine(to: v["tl"]!)
            paths.append(TabPath(id: UUID(), path: Path(p)))
        }
        if aL.tabs[side].left.getType() != .none {
            var d = CGFloat(0)
            switch aL.tabs[side].left.getLength() {
                case .inch: d = -10
                case .half: d = -5
                case .threeEighth: d = -3
                default: break
            }
            let p = CGMutablePath()
            p.move(to: v["bl"]!)
            p.addLine(to: p.currentPoint.translate(x: d))
            p.addLine(to: v["tl"]!.translate(x: d))
            p.addLine(to: v["tl"]!)
            p.addLine(to: v["bl"]!)
            paths.append(TabPath(id: UUID(), path: Path(p)))
        }
        if aL.tabs[side].right.getType() != .none {
            var d = CGFloat(0)
            switch aL.tabs[side].right.getLength() {
                case .inch: d = 10
                case .half: d = 5
                case .threeEighth: d = 3
                default: break
            }
            let p = CGMutablePath()
            p.move(to: v["br"]!)
            p.addLine(to: p.currentPoint.translate(x: d))
            p.addLine(to: v["tr"]!.translate(x: d))
            p.addLine(to: v["tr"]!)
            p.addLine(to: v["br"]!)
            paths.append(TabPath(id: UUID(), path: Path(p)))
        }
        if aL.tabs[side].bottom.getType() != .none {
            var d = CGFloat(0)
            switch aL.tabs[side].bottom.getLength() {
                case .inch: d = 10
                case .half: d = 5
                case .threeEighth: d = 3
                default: break
            }
            let p = CGMutablePath()
            p.move(to: v["bl"]!)
            p.addLine(to: v["bl"]!.translate(y: d))
            p.addLine(to: v["br"]!.translate(y: d))
            p.addLine(to: v["br"]!)
            p.addLine(to: v["bl"]!)
            paths.append(TabPath(id: UUID(), path: Path(p)))
        }
        return paths
    }

    func genDuctPoints() -> [String: CGPoint] {
        var points: [String: CGPoint] = [:]
        var sS = ""
        let sC = ["bl", "br", "tl", "tr"]

        switch self.side {
        case .front: sS = "f"
        case .back: sS = "b"
        case .left: sS = "l"
        case .right: sS = "r"
        }
        for i in sC {
            points["\(i)"] = self.aL.duct.v2D["\(sS)\(i)"]
        }
        return self.applyTransforms(points)
    }

    func genBoundingPoints() -> [String: CGPoint] {
        var points: [String: CGPoint] = [:]
        var sS = ""
        let sC = ["bl", "br", "tl", "tr"]

        switch self.side {
        case .front: sS = "f"
        case .back: sS = "b"
        case .left: sS = "l"
        case .right: sS = "r"
        }
        for i in sC {
            points["\(i)"] = self.aL.duct.b2D["\(sS)\(i)"]
        }
        return self.applyTransforms(points)
    }

    func genText() -> [String: Text] {
        var sS = ""
        var tlLen: CGFloat = 0
        var trLen: CGFloat = 0
        var ttLen: CGFloat = 0
        var tbLen: CGFloat = 0
        switch self.side {
        case .front:
            sS = "front"
            tlLen = aL.tabs.front.left.length
            trLen = aL.tabs.front.right.length
            ttLen = aL.tabs.front.top.length
            tbLen = aL.tabs.front.bottom.length
        case .back:
            sS = "back"
            tlLen = aL.tabs.back.left.length
            trLen = aL.tabs.back.right.length
            ttLen = aL.tabs.back.top.length
            tbLen = aL.tabs.back.bottom.length
        case .left:
            sS = "left"
            tlLen = aL.tabs.left.left.length
            trLen = aL.tabs.left.right.length
            ttLen = aL.tabs.left.top.length
            tbLen = aL.tabs.left.bottom.length
        case .right:
            sS = "right"
            tlLen = aL.tabs.right.left.length
            trLen = aL.tabs.right.right.length
            ttLen = aL.tabs.right.top.length
            tbLen = aL.tabs.right.bottom.length
        }
        let ml = Fraction(aL.duct.measurements["\(sS)-bounding-l"]!.original + ttLen + tbLen)
        let mt = Fraction(aL.duct.measurements["\(sS)-tabs-t"]!.original + tlLen + trLen)
        
        return [
            "bounding-l": Text(self.aL.duct.measurements["\(sS)-bounding-l"]?.text("w n/d\"") ?? ""),
            "bounding-el": Text(self.aL.duct.measurements["\(sS)-bounding-el"]?.text("w n/d\"") ?? ""),
            "bounding-er": Text(self.aL.duct.measurements["\(sS)-bounding-er"]?.text("w n/d\"") ?? ""),
            "duct-l": Text(self.aL.duct.measurements["\(sS)-duct-l"]?.text("w n/d\"") ?? ""),
            "duct-r": Text(self.aL.duct.measurements["\(sS)-duct-r"]?.text("w n/d\"") ?? ""),
            "duct-t": Text(self.aL.duct.measurements["\(sS)-duct-t"]?.text("w n/d\"") ?? ""),
            "duct-b": Text(self.aL.duct.measurements["\(sS)-duct-b"]?.text("w n/d\"") ?? ""),
            "tabs-l": Text("Length:   \(ml.text("w n/d\""))"),
            "tabs-t": Text("Width:   \(mt.text("w n/d\""))")
        ]
    }

    enum SideTextAng { case left, right }

    func getAng(_ s: SideTextAng, _ d: [String: CGPoint], _ b: [String: CGPoint]) -> Double {
        switch s {
        case .left:
            if b["tl"]! == d["tl"]! {
                let o = b["bl"]!.distance(d["bl"]!)
                let a = b["bl"]!.distance(b["tl"]!)
                if Int(o) == Int(a) { return Double(45) }
                return Double(90 - atan(o < a ? o / a : a / o).toDeg())
            } else {
                let o = b["tl"]!.distance(d["tl"]!)
                let a = b["tl"]!.distance(b["bl"]!)
                if Int(o) == Int(a) { return Double(135) }
                return Double(90 + atan(o < a ? o / a : a / o).toDeg())
            }
        case .right:
            if b["tr"]! == d["tr"]! {
                let o = b["br"]!.distance(d["br"]!)
                let a = b["br"]!.distance(b["tr"]!)
                if Int(o) == Int(a) { return Double(-45) }
                return Double(-90 + atan(o < a ? o / a : a / o).toDeg())
            } else {
                let o = b["tr"]!.distance(d["tr"]!)
                let a = b["tr"]!.distance(b["br"]!)
                if Int(o) == Int(a) { return Double(-135) }
                return Double(-90 - atan(o < a ? o / a : a / o).toDeg())
            }
        }
    }

    func genTextZStack(_ d: [String: CGPoint], _ b: [String: CGPoint], _ t: [String: Text]) -> some View {
        let tS: CGFloat = 10.0
        let bl = d["tl"]!.x < d["bl"]!.x ? "b" : "t"
        let br = d["tr"]!.x < d["br"]!.x ? "t" : "b"
        let belPos = b["\(bl)l"]!.translate(y: bl == "t" ? -tS: tS).translate(x: b["\(bl)l"]!.x.distance(to: d["\(bl)l"]!.x) / 2)
        let berPos = b["\(br)r"]!.translate(y: br == "t" ? -tS : tS).translate(x: -d["\(br)r"]!.x.distance(to: b["\(br)r"]!.x) / 2)
        let dlPos = CGPoint(x: b["bl"]!.x + abs(d["bl"]!.x.distance(to: d["tl"]!.x)) / 2, y: d["tl"]!.y)
            .translate(x: 15)
            .translate(y: d["tl"]!.y.distance(to: d["bl"]!.y) / 2)
        let dlAng = Angle(degrees: getAng(.left, d, b))
        let drAng = Angle(degrees: getAng(.right, d, b))
        let drPos = CGPoint(x: b["br"]!.x - abs(d["br"]!.x.distance(to: d["tr"]!.x)) / 2, y: d["tr"]!.y)
            .translate(x: -15)
            .translate(y: d["tr"]!.y.distance(to: d["br"]!.y) / 2)
        //        let isBack = self.side == .back
        return ZStack {
            t["bounding-l"]!
                .rotationEffect(Angle(degrees: 90))
                .position(b["tr"]!.translate(y: b["tr"]!.y.distance(to: b["br"]!.y) / 2).translate(x: tS * 3))
            if b["\(bl)l"]!.x != d["\(bl)l"]!.x {
                t["bounding-el"]!
                    .position(/*isBack ? berPos : */belPos)
            }
            if b["\(br)r"]!.x != d["\(br)r"]!.x {
                t["bounding-er"]!
                    .position(/*isBack ? belPos : */berPos)
            }
            if d["\(bl)l"]!.x != b["\(bl)l"]!.x {
                t["duct-l"]!
                    .rotationEffect(/*isBack ? drAng : */dlAng)
                    .position(/*isBack ? drPos : */dlPos)
            }
            if d["\(br)r"]!.x != b["\(br)r"]!.x {
                t["duct-r"]!
                    .rotationEffect(/*isBack ? dlAng : */drAng)
                    .position(/*isBack ? dlPos : */drPos)
            }
            t["duct-t"]!
                .position(d["tl"]!.translate(x: d["tl"]!.x.distance(to: d["tr"]!.x) / 2).translate(y: tS))
            t["duct-b"]!
                .position(d["bl"]!.translate(x: d["bl"]!.x.distance(to: d["br"]!.x) / 2).translate(y: -tS))

        }
    }

    func genPath(_ v: [String: CGPoint]) -> Path {
        let p = CGMutablePath()
        p.move(to: v["bl"]!)
        p.addLine(to: v["br"]!)
        p.addLine(to: v["tr"]!)
        p.addLine(to: v["tl"]!)
        p.addLine(to: v["bl"]!)
        return Path(p)
    }
    
    func genLeftTotalLen(bl: CGPoint, tl: CGPoint) -> (Path, CGPoint) {
        var up = CGFloat(0)
        var down = CGFloat(0)
        switch aL.tabs[side].top.getLength() {
            case .inch: up = -10
            case .half: up = -5
            case .threeEighth: up = -3
            default: break
        }
        switch aL.tabs[side].bottom.getLength() {
            case .inch: down = 10
            case .half: down = 5
            case .threeEighth: down = 3
            default: break
        }
        let p = CGMutablePath()
        p.move(to: tl.translate(x: -15).translate(y: up))
        p.addLine(to: p.currentPoint.translate(x: -5))
        p.addLine(to: bl.translate(x: -20).translate(y: down))
        p.addLine(to: p.currentPoint.translate(x: 5))
        return (
            Path(p),
            tl.translate(x: -30).translate(y: tl.y.distance(to: bl.y) / 2)
        )
    }
    
    func genTopTotalLen(tl: CGPoint, tr: CGPoint) -> (Path, CGPoint) {
        var left = CGFloat(0)
        var right = CGFloat(0)
        switch aL.tabs[side].left.getLength() {
            case .inch: left = -10
            case .half: left = -5
            case .threeEighth: left = -3
            default: break
        }
        switch aL.tabs[side].right.getLength() {
            case .inch: right = 10
            case .half: right = 5
            case .threeEighth: right = 3
            default: break
        }
        let p = CGMutablePath()
        p.move(to: tl.translate(y: -15).translate(x: left))
        p.addLine(to: p.currentPoint.translate(y: -5))
        p.addLine(to: tr.translate(y: -20).translate(x: right))
        p.addLine(to: p.currentPoint.translate(y: 5))
        return (
            Path(p),
            tl.translate(y: -30).translate(x: tl.x.distance(to: tr.x) / 2)
        )
    }

    var body: some View {
        let ductPoints = self.genDuctPoints()
        let bPoints = self.genBoundingPoints()
        let textEls = self.genText()
        let textZStack = self.genTextZStack(ductPoints, bPoints, textEls)
        let ductPath = self.genPath(ductPoints)
        let bPath = self.genPath(bPoints)
        let (totLenLeftPath, totLenLeftPos) = genLeftTotalLen(bl: bPoints["bl"]!, tl: bPoints["tl"]!)
        let (totLenTopPath, totLenTopPos) = genTopTotalLen(tl: bPoints["tl"]!, tr: bPoints["tr"]!)
        let tabPaths = genTabs(ductPoints)
        return ZStack {
            ductPath
                .stroke(lineWidth: 1.0)

            ductPath
                .fill(ImagePaint(image: Image("metal-diffuse")))
                .opacity(colorScheme == .light ? 0.5 : 1.0)

            bPath
                .stroke(
                    style: StrokeStyle(
                        lineWidth: 1.0,
                        lineCap: .round,
                        lineJoin: .bevel,
                        miterLimit: 0.0,
                        dash: [10.0, 10.0, 10.0, 10.0],
                        dashPhase: 5.0)
                )
            totLenTopPath
                .stroke(
                style: StrokeStyle(
                    lineWidth: 1.0,
                    lineCap: .round,
                    lineJoin: .bevel,
                    miterLimit: 0,
                    dash: [10, 10, 10, 10],
                    dashPhase: 5)
                )
            totLenLeftPath
                .stroke(
                style: StrokeStyle(
                    lineWidth: 1.0,
                    lineCap: .round,
                    lineJoin: .bevel,
                    miterLimit: 0,
                    dash: [10, 10, 10, 10],
                    dashPhase: 5)
                )
            textEls["tabs-l"]
                .rotationEffect(Angle(degrees: -90))
                .position(totLenLeftPos)
            textEls["tabs-t"]
                .position(totLenTopPos)
            
            ForEach(tabPaths) { i in
                i.path
                    .stroke(lineWidth: 1.0)
                i.path
                    .fill(ImagePaint(image: Image("metal-diffuse")))
                    .opacity(colorScheme == .light ? 0.15 : 0.3)
            }
            

            textZStack
        }
    }
}

struct DuctSideView_Previews: PreviewProvider {
    static var previews: some View {
        let aL = AppLogic()
        aL.width.original = 20
        aL.depth.original = 18
        aL.length.original = 12
        aL.offsetX.original = -8
        aL.offsetY.original = 11
        aL.tWidth.original = 12
        aL.tDepth.original = 12
        return GeometryReader { g in
            DuctSideView(g: g, side: .back).environmentObject(aL)
        }
    }
}
