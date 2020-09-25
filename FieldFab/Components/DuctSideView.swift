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
    var side: DuctSides
    @State var shapePos: CGPoint = CGPoint(x: 0.0, y: 0.0)
    @State var shapeScale: CGFloat = 0.8
    
    func applyTransforms(_ v: [String: CGPoint]) -> [String: CGPoint] {
        let center = self.g.size.center
        let shapeW = abs(min(v["bl"]!.x, v["tl"]!.x).distance(to: max(v["br"]!.x, v["tr"]!.x)))
        let shapeH = v["tl"]!.y.distance(to: v["bl"]!.y)
        let sMax = max(shapeH, shapeW)
        let cMin = min(self.g.size.width, self.g.size.height)
        var b4p = [
            "bl": v["bl"]!.multiplyScalar(cMin / sMax * self.shapeScale),
            "br": v["br"]!.multiplyScalar(cMin / sMax * self.shapeScale),
            "tl": v["tl"]!.multiplyScalar(cMin / sMax * self.shapeScale),
            "tr": v["tr"]!.multiplyScalar(cMin / sMax * self.shapeScale)
        ]
        if self.side == .back {
            b4p["bl"] = b4p["bl"]!.flip(.x)
            b4p["br"] = b4p["br"]!.flip(.x)
            b4p["tl"] = b4p["tl"]!.flip(.x)
            b4p["tr"] = b4p["tr"]!.flip(.x)
        }
        let p = [
            "bl": center.translate(b4p["bl"]!).addScalar(cMin / sMax * self.shapeScale),
//                .translate(self.shapePos),
            "br": center.translate(b4p["br"]!).addScalar(cMin / sMax * self.shapeScale),
//                .translate(self.shapePos),
            "tl": center.translate(b4p["tl"]!).addScalar(cMin / sMax * self.shapeScale),
//                .translate(self.shapePos),
            "tr": center.translate(b4p["tr"]!).addScalar(cMin / sMax * self.shapeScale)
//                .translate(self.shapePos)
        ]
        return p
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
        
        switch self.side {
            case .front: sS = "front"
            case .back: sS = "back"
            case .left: sS = "left"
            case .right: sS = "right"
        }
        
        return [
            "bounding-l": Text(self.aL.duct.measurements["\(sS)-bounding-l"]?.text("w n/d\"") ?? ""),
            "bounding-el": Text(self.aL.duct.measurements["\(sS)-bounding-el"]?.text("w n/d\"") ?? ""),
            "bounding-er": Text(self.aL.duct.measurements["\(sS)-bounding-er"]?.text("w n/d\"") ?? ""),
            "duct-l": Text(self.aL.duct.measurements["\(sS)-duct-l"]?.text("w n/d\"") ?? ""),
            "duct-r": Text(self.aL.duct.measurements["\(sS)-duct-r"]?.text("w n/d\"") ?? ""),
            "duct-t": Text(self.aL.duct.measurements["\(sS)-duct-t"]?.text("w n/d\"") ?? ""),
            "duct-b": Text(self.aL.duct.measurements["\(sS)-duct-b"]?.text("w n/d\"") ?? ""),
        ]
    }
    
    func genTextZStack(_ d: [String: CGPoint], _ b: [String: CGPoint], _ t: [String: Text]) -> some View {
        let tS: CGFloat = 10.0
        let el = d["tl"]!.x < d["bl"]!.x ? "t" : "b"
        let lol = self.side == .back ? "r" : "l"
        return ZStack {
            t["bounding-l"]!
                .rotationEffect(Angle(degrees: 90))
                .position(b["t\(lol)"]!.translate(y: b["t\(lol)"]!.y.distance(to: b["b\(lol)"]!.y) / 2).translate(x: -tS))
            if b["\(el)l"]!.x != d["\(el)l"]!.x {
                t["bounding-el"]!
                    .position(b["\(el)l"]!.translate(x: b["\(el)l"]!.x.distance(to: d["\(el)l"]!.x) / 2)
                         .translate(y: el == "t" ? -tS : tS))
            }
            if b["\(el)r"]!.x != d["\(el)r"]!.x {
                t["bounding-er"]!
                    .position(b["\(el)r"]!.translate(x: -(b["\(el)r"]!.x.distance(to: d["\(el)r"]!.x) / 2))
                                .translate(y: el == "t" ? -tS : tS))
            }
            t["duct-l"]!
                .position(
                    d["tl"]!
                        .translate(x: d["tl"]!.x.distance(to: d["bl"]!.x) / 2 + (self.side == .back ? -25.0 : 25.0))
                        .translate(y: d["tl"]!.y.distance(to: d["bl"]!.y) / 2))
            t["duct-r"]!
                .position(
                    d["tr"]!
                        .translate(x: d["tr"]!.x.distance(to: d["br"]!.x) / 2 - (self.side == .back ? -30.0 : 25.0))
                        .translate(y: d["tr"]!.y.distance(to: d["br"]!.y) / 2))
            t["duct-t"]!
                .position(b["tl"]!.translate(x: b["tl"]!.x.distance(to: d["tr"]!.x) / 2).translate(y: -tS))
            t["duct-b"]!
                .position(b["bl"]!.translate(x: b["bl"]!.x.distance(to: d["br"]!.x) / 2).translate(y: tS))
            
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
    
    var body: some View {
        let ductPoints = self.genDuctPoints()
        let bPoints = self.genBoundingPoints()
        let textEls = self.genText()
        let textZStack = self.genTextZStack(ductPoints, bPoints, textEls)
        let ductPath = self.genPath(ductPoints)
        let bPath = self.genPath(bPoints)
        return ZStack() {
            ductPath
            .stroke(lineWidth: 1.0)
            .position(self.shapePos)
//            .scaleEffect(self.shapeScale)
            
            ductPath
            .fill(ImagePaint(image: Image("sheetmetal")))
            .position(self.shapePos)
            .gesture(DragGesture().onChanged({v in
                self.shapePos = v.location
            }))
            .gesture(MagnificationGesture().onChanged({v in
                self.shapeScale = v
            }))
            .opacity(/*@START_MENU_TOKEN@*/0.5/*@END_MENU_TOKEN@*/)
//            .scaleEffect(self.shapeScale)
            
            bPath
            .stroke(style: StrokeStyle(lineWidth: 1.0, lineCap: .round, lineJoin: .bevel, miterLimit: 0.0, dash: [10.0, 10.0, 10.0, 10.0], dashPhase: 5.0))
            .position(self.shapePos)
//            .scaleEffect(self.shapeScale)
            
            textZStack
            .position(self.shapePos)
//            .scaleEffect(self.shapeScale)
        }
        .onAppear(perform: {
            self.shapePos = CGPoint(x: self.g.size.width / 2, y: self.g.size.height / 2)
        })
    }
}

struct DuctSideView_Previews: PreviewProvider {
    static var previews: some View {
        let aL = AppLogic()
        aL.width.original = 3.0
        aL.depth.original = 4.0
        aL.length.original = 2.0
        aL.offsetX.original = -1.0
        aL.offsetY.original = 1.0
        aL.tWidth.original = 4.0
        aL.tDepth.original = 5.0
        return ContentView().environmentObject(aL)
    }
}
