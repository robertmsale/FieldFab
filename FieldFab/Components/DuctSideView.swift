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
    var face: QuadFace
    var side: String
    @State var shapePos: CGPoint = CGPoint(x: 0.0, y: 0.0)
    @State var shapeScale: CGFloat = 0.8
    var bottomLength: CGFloat = 0.0
    var leftLength: CGFloat = 0.0
    var rightLength: CGFloat = 0.0
    var topLength: CGFloat = 0.0
    
    func initDuctPoints() -> DuctPoints {
        var d = DuctPoints(
            bl: CGPoint(x: 0.0, y: 0.0),
            br: CGPoint(x: 0.0, y: 0.0),
            tl: CGPoint(x: 0.0, y: 0.0),
            tr: CGPoint(x: 0.0, y: 0.0))
        switch self.side {
        case "Left":
            d.tl = self.face[.tlz]
            d.tr = self.face[.trz]
            d.bl = self.face[.blz]
            d.br = self.face[.brz]
        case "Right":
            d.tl = self.face[.tlz]
            d.tl.x = -d.tl.x
            d.tr = self.face[.trz]
            d.tr.x = -d.tr.x
            d.bl = self.face[.blz]
            d.bl.x = -d.bl.x
            d.br = self.face[.brz]
            d.br.x = -d.br.x
        case "Back":
            d.tr = self.face[.tlx]
            d.tr.x = -d.tr.x
            d.tl = self.face[.trx]
            d.tl.x = -d.tl.x
            d.br = self.face[.blx]
            d.br.x = -d.br.x
            d.bl = self.face[.brx]
            d.bl.x = -d.bl.x
        default:
            d.tl = self.face[.tlx]
            d.tr = self.face[.trx]
            d.bl = self.face[.blx]
            d.br = self.face[.brx]
        }
        d.tl.y = -d.tl.y
        d.tr.y = -d.tr.y
        d.bl.y = -d.bl.y
        d.br.y = -d.br.y
        return d
    }
    
    func applyDuctScaling (_ d: inout DuctPoints) {
        let sc = self.getScaling(d)
        d.scale(.x, sc)
        d.scale(.y, sc)
    }
    
    func getScaling (_ d: DuctPoints) -> CGFloat {
        let shapeW = min(d.bl.x, d.tl.x).distance(to: max(d.br.x, d.tr.x))
        let shapeH = d.bl.y.distance(to: d.tl.y)
        let shapeMax = max(shapeW, shapeH)
        let containerMin = min(self.g.size.width, self.g.size.height)
        return containerMin / shapeMax * self.shapeScale
    }
    
    func applyZeroCentering (_ d: inout DuctPoints) {
        let reduceX = CGFloat(0.0).distance(to: self.g.size.width / 2)
        let reduceY = CGFloat(0.0).distance(to: self.g.size.height / 2)
        d.translate(.x, reduceX)
        d.translate(.y, reduceY)
    }
    
    func initBounding (_ d: inout DuctPoints) {
        let leftBound = min(d.tl.x, d.bl.x)
        let rightBound = max(d.tr.x, d.br.x)
        d.tl.x = leftBound
        d.bl.x = leftBound
        d.tr.x = rightBound
        d.br.x = rightBound
    }
    
    func makeDuctPoints() -> DuctPoints {
        var d = self.initDuctPoints()
        self.applyDuctScaling(&d)
        self.applyZeroCentering(&d)
        return d
    }
    
    func makeBounding() -> DuctPoints {
        var d = self.initDuctPoints()
        self.initBounding(&d)
        self.applyDuctScaling(&d)
        self.applyZeroCentering(&d)
        return d
    }
    
    func makeTextViews() -> some View {
        var d = self.initDuctPoints()
        var b = self.initDuctPoints()
        let tlF = Fraction(d.bl.x.distance(to: b.tl.x))
        let trF = Fraction(d.tr.x.distance(to: b.br.x))
        let blF = Fraction(d.tl.x.distance(to: d.bl.x))
        let brF = Fraction(d.br.x.distance(to: d.tr.x))
        let lF = Fraction(
            tlF.original != 0.0 ? sqrt(self.face.lenLeft * self.face.lenLeft - abs(tlF.original) * abs(tlF.original)) : 0.0
        )
        let rF = Fraction(
            trF.original != 0.0 ? sqrt(self.face.lenRight * self.face.lenRight - abs(trF.original) * abs(trF.original)) : 0.0
        )
        self.applyDuctScaling(&d)
        self.applyZeroCentering(&d)
        self.initBounding(&b)
        self.applyDuctScaling(&b)
        self.applyZeroCentering(&b)
        let bottomF = Fraction(self.face.lenBottom)
        let topF = Fraction(self.face.lenTop)
        let leftF = Fraction(self.face.lenLeft)
        let rightF = Fraction(self.face.lenRight)
        let offsetX = self.aL.offsetX.original
        
        return ZStack {
            Text("\(bottomF.whole)\(bottomF.textParts)")
                .position(CGPoint(
                    x: (d.br.x - d.bl.x.distance(to: 0.0)) / 2,
                    y: d.br.y + 10))
            Text("\(topF.whole)\(topF.textParts)")
                .position(CGPoint(
                    x: (d.tr.x - d.tl.x.distance(to: 0.0)) / 2,
                    y: d.tr.y - 10
                ))
            Text("\(leftF.whole)\(leftF.textParts)")
                .position(CGPoint(
                    x: (d.bl.x - d.tl.x.distance(to: 0.0)) / 2 + 40,
                    y: (d.tl.y - d.bl.y.distance(to: 0.0)) / 2
                ))
            Text("\(rightF.whole)\(rightF.textParts)")
                .position(CGPoint(
                    x: (d.br.x - d.tr.x.distance(to: 0.0)) / 2 - 40,
                    y: (d.tr.y - d.br.y.distance(to: 0.0)) / 2
                ))
            Text(tlF.original > 0 ? "\(tlF.whole)\(tlF.textParts)" : "")
                .position(CGPoint(
                    x: (d.tl.x - d.bl.x.distance(to: 0.0)) / 2,
                    y: d.tl.y - 10
                ))
            Text(trF.original > 0 ? "\(trF.whole)\(trF.textParts)" : "")
                .position(CGPoint(
                    x: (d.tr.x - d.br.x.distance(to: 0.0)) / 2,
                    y: d.tr.y - 10
                ))
            Text(blF.original > 0.0 ? "\(blF.whole)\(blF.textParts)" : "")
                .position(CGPoint(
                    x: (d.bl.x - d.tl.x.distance(to: 0.0)) / 2,
                    y: d.bl.y + 10
                ))
            Text(brF.original > 0.0 ? "\(brF.whole)\(brF.textParts)" : "")
                .position(CGPoint(
                    x: (d.br.x - d.tr.x.distance(to: 0.0)) / 2,
                    y: d.br.y + 10
                ))
            Text(lF.original > 0.0 && offsetX < 0.0 ? "\(lF.whole)\(lF.textParts)" : "")
                .rotationEffect(Angle(degrees: 90.0))
                .position(CGPoint(
                    x: b.bl.x - 10,
                    y: (d.tl.y - d.bl.y.distance(to: 0.0)) / 2
                ))
            Text(rF.original > 0.0 && offsetX > 0.0 ? "\(rF.whole)\(rF.textParts)" : "")
                .rotationEffect(Angle(degrees: 90.0))
                .position(CGPoint(
                    x: b.br.x + 10,
                    y: (d.tr.y - d.br.y.distance(to: 0.0)) / 2
                ))
        }
    }
    
    var body: some View {
        ZStack() {
            Path { path in
                let d = self.makeDuctPoints()
                path.move(to: d.bl)
                path.addLine(to: d.br)
                path.addLine(to: d.tr)
                path.addLine(to: d.tl)
                path.addLine(to: d.bl)
            }
            .stroke(lineWidth: 1.0)
            .position(self.shapePos)
            
            Path { path in
                let d = self.makeDuctPoints()
                path.move(to: d.bl)
                path.addLine(to: d.br)
                path.addLine(to: d.tr)
                path.addLine(to: d.tl)
                path.addLine(to: d.bl)
            }
            .fill(ImagePaint(image: Image("sheetmetal")))
            .position(self.shapePos)
            .gesture(DragGesture().onChanged({v in
                self.shapePos = v.location
            }))
            .gesture(MagnificationGesture().onChanged({v in
                self.shapeScale = v
            }))
                .opacity(/*@START_MENU_TOKEN@*/0.5/*@END_MENU_TOKEN@*/)
            
            Path { path in
                let d = self.makeBounding()
                path.move(to: d.bl)
                path.addLine(to: d.br)
                path.addLine(to: d.tr)
                path.addLine(to: d.tl)
                path.addLine(to: d.bl)
            }
            .stroke(style: StrokeStyle(lineWidth: 1.0, lineCap: .round, lineJoin: .bevel, miterLimit: 0.0, dash: [10.0, 10.0, 10.0, 10.0], dashPhase: 5.0))
            .position(self.shapePos)
            
            self.makeTextViews().position(self.shapePos).zIndex(15.0)
            
        }
        .onAppear(perform: {
            self.shapePos = CGPoint(x: self.g.size.width / 2, y: self.g.size.height / 2)
        })
    }
}

struct DuctSideView_Previews: PreviewProvider {
    static var previews: some View {
        let aL = AppLogic()
        aL.offsetX.original = 3.0
        return ContentView().environmentObject(aL)
    }
}
