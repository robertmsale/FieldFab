//
//  Duct.swift
//  FieldFab
//
//  Created by Robert Sale on 9/20/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI

struct Duct2D {
    enum DuctSides {
        case front
        case left
        case back
        case right
    }
    enum DuctLines {
        case top
        case bottom
        case left
        case right
    }
    enum BoundingLines {
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
        case left
    }
    
    public var vertices: [String: Vector3] = [
        "fbl": Vector3(),
        "ftl": Vector3(),
        "fbr": Vector3(),
        "ftr": Vector3(),
        "bbl": Vector3(),
        "bbr": Vector3(),
        "btl": Vector3(),
        "btr": Vector3()
    ]
    
    init (_ l: CGFloat, _ w: CGFloat, _ d: CGFloat, _ oX: CGFloat, _ oY: CGFloat, _ tW: CGFloat, _ tD: CGFloat) {
        let fbl = Vector3(-(w / 2), -(l / 2), d / 2)
        let fbr = Vector3(w / 2, -(l / 2), d / 2)
        let ftl = Vector3(-(tW / 2) + oX, l / 2, tD / 2 + oY)
        let ftr = Vector3(tW / 2 + oX, l / 2, tD / 2 + oY)
        let bbl = Vector3(fbl.x, fbl.y, -fbl.z)
        let bbr = Vector3(fbr.x, fbr.y, -fbr.z)
        let btl = Vector3(ftl.x, ftl.y, -ftl.z + (oY * 2))
        let btr = Vector3(ftr.x, ftr.y, -ftl.z + (oY * 2))
        self.vertices["fbl"] = fbl
        self.vertices["fbr"] = fbr
        self.vertices["ftl"] = ftl
        self.vertices["ftr"] = ftr
        self.vertices["bbl"] = bbl
        self.vertices["bbr"] = bbr
        self.vertices["btl"] = btl
        self.vertices["btr"] = btr
    }
    
    mutating func update(_ l: CGFloat, _ w: CGFloat, _ d: CGFloat, _ oX: CGFloat, _ oY: CGFloat, _ tW: CGFloat, _ tD: CGFloat) {
        let fbl = Vector3(-(w / 2), -(l / 2), d / 2)
        let fbr = Vector3(w / 2, -(l / 2), d / 2)
        let ftl = Vector3(-(tW / 2) + oX, l / 2, tD / 2 + oY)
        let ftr = Vector3(tW / 2 + oX, l / 2, tD / 2 + oY)
        let bbl = Vector3(fbl.x, fbl.y, -fbl.z)
        let bbr = Vector3(fbr.x, fbr.y, -fbr.z)
        let btl = Vector3(ftl.x, ftl.y, -ftl.z + (oY * 2))
        let btr = Vector3(ftr.x, ftr.y, -ftl.z + (oY * 2))
        self.vertices["fbl"] = fbl
        self.vertices["fbr"] = fbr
        self.vertices["ftl"] = ftl
        self.vertices["ftr"] = ftr
        self.vertices["bbl"] = bbl
        self.vertices["bbr"] = bbr
        self.vertices["btl"] = btl
        self.vertices["btr"] = btr
    }
    
    func textElements(side: DuctSides, roundTo: CGFloat) -> [BoundingLines: Text] {
        let bounding = self.boundingLen(side: side)
        let lF = Fraction(bounding[.left]!, roundTo: roundTo)
        let tLF = Fraction(bounding[.topLeft]!, roundTo: roundTo)
        let tRF = Fraction(bounding[.topRight]!, roundTo: roundTo)
        let bLF = Fraction(bounding[.bottomLeft]!, roundTo: roundTo)
        let bRF = Fraction(bounding[.bottomRight]!, roundTo: roundTo)
        return [
            .left: Text("\(lF.whole) \(lF.parts.d > 1 ? lF.text("n/d\"") : "")"),
            .topLeft: Text("\(tLF.whole) \(tLF.parts.d > 1 ? tLF.text("n/d\"") : "")"),
            .topRight: Text("\(tRF.whole) \(tRF.parts.d > 1 ? tRF.text("n/d\"") : "")"),
            .bottomLeft: Text("\(bLF.whole) \(bLF.parts.d > 1 ? bLF.text("n/d\"") : "")"),
            .bottomRight: Text("\(bRF.whole) \(bRF.parts.d > 1 ? bRF.text("n/d\"") : "")"),
        ]
    }
    
    func bounding(side: DuctSides) -> [String: Vector2] {
        let p: [String: Vector2] = self[side]
        var s: [String] = []
        s.append(contentsOf: ["bl", "br", "tl", "tr"])
        var maxX: CGFloat = 0.0
        var minX: CGFloat = 0.0
        var maxY: CGFloat = 0.0
        var minY: CGFloat = 0.0
        for i in 0...s.count - 1 {
            if p["\(s[i])"]!.x < minX { minX = p["\(s[i])"]!.x }
            if p["\(s[i])"]!.x > maxX { maxX = p["\(s[i])"]!.x }
            if p["\(s[i])"]!.y < minY { minY = p["\(s[i])"]!.y }
            if p["\(s[i])"]!.y > maxY { maxY = p["\(s[i])"]!.y }
        }
        return [
            "bl": Vector2(minX, minY),
            "br": Vector2(maxX, minY),
            "tr": Vector2(maxX, maxY),
            "tl": Vector2(minX, maxY)
        ]
    }
    
    func boundingLen(side: DuctSides) -> [BoundingLines: CGFloat] {
        var bd: [String: Vector3] = [:]
        var d: [String: Vector3] = [:]
        var s: [String] = []
        let axis = side == .left || side == .right ? "x" : "z"
        switch side {
            case .front: s.append("f")
            case .back: s.append("b")
            case .left: s.append("l")
            case .right: s.append("r")
        }
        s.append(contentsOf: ["bl", "br", "tl", "tr"])
        var minX = CGFloat(0.0)
        var maxX = CGFloat(0.0)
        var minY = CGFloat(0.0)
        var maxY = CGFloat(0.0)
        for i in 1...s.count - 1 {
            bd[s[i]] = self[s[0] + s[i]]
            d[s[i]] = bd[s[i]]
            if bd[s[i]]![axis] < minX { minX = bd[s[i]]![axis] }
            if bd[s[i]]![axis] > maxX { maxX = bd[s[i]]![axis] }
            if bd[s[i]]!.y < minY { minY = bd[s[i]]!.y }
            if bd[s[i]]!.y > maxY { maxY = bd[s[i]]!.y }
        }
        let corners = side == .left || side == .back ? ["tr", "tl", "br", "bl"] : ["tl", "tr", "bl", "br"]
        return [
            .left: abs(bd["bl"]!.distance(to: bd["tl"]!)),
            .topLeft: abs(bd["\(corners[0])"]!.distance(to: d["\(corners[0])"]!)),
            .topRight: abs(bd["\(corners[1])"]!.distance(to: d["\(corners[1])"]!)),
            .bottomLeft: abs(bd["\(corners[2])"]!.distance(to: d["\(corners[2])"]!)),
            .bottomRight: abs(bd["\(corners[3])"]!.distance(to: d["\(corners[3])"]!))
        ]
        
    }
    
    subscript(side: DuctSides, line: DuctLines) -> CGFloat {
        var s: [String] = []
        switch side {
            case .front:
                s.append("f")
            case .back:
                s.append("b")
            case .left:
                s.append("l")
            case .right:
                s.append("r")
        }
        switch line {
            case .top: s.append(contentsOf: ["tl", "tr"])
            case .bottom: s.append(contentsOf: ["bl", "br"])
            case .left: s.append(contentsOf: [
                side == .left || side == .right ? "tr" : "tl",
                side == .left || side == .right ? "br" : "bl"])
            case .right: s.append(contentsOf: [
                side == .left || side == .right ? "tl" : "tr",
                side == .left || side == .right ? "bl" : "br"])
        }
        return self["\(s[0])\(s[1])"].distance(to: self["\(s[0])\(s[2])"])
    }
    
    subscript(vertex: String) -> Vector3 {
        switch vertex {
            case "fbl": return self.vertices["fbl"]!
            case "fbr": return self.vertices["fbr"]!
            case "ftl": return self.vertices["ftl"]!
            case "ftr": return self.vertices["ftr"]!
            case "bbl": return self.vertices["bbl"]!
            case "bbr": return self.vertices["bbr"]!
            case "btl": return self.vertices["btl"]!
            case "btr": return self.vertices["btr"]!
            case "lbl": return self.vertices["bbl"]!
            case "lbr": return self.vertices["fbl"]!
            case "ltl": return self.vertices["btl"]!
            case "ltr": return self.vertices["ftl"]!
            case "rbl": return self.vertices["fbr"]!
            case "rbr": return self.vertices["bbr"]!
            case "rtl": return self.vertices["ftr"]!
            case "rtr": return self.vertices["btr"]!
            default: return Vector3()
        }
    }
    
    subscript(side: DuctSides) -> [String: Vector2] {
        switch side {
            case .front:
                return [
                    "bl": Vector2(self["fbl"], .xy),
                    "br": Vector2(self["fbr"], .xy),
                    "tl": Vector2(self["ftl"], .xy),
                    "tr": Vector2(self["ftr"], .xy)
                ]
            case .left:
                return [
                    "bl": Vector2(self["lbl"], .zy),
                    "br": Vector2(self["lbr"], .zy),
                    "tl": Vector2(self["ltl"], .zy),
                    "tr": Vector2(self["ltr"], .zy)
                ]
            case .right:
                var bl = self["rbl"]
                var br = self["rbr"]
                var tl = self["rtl"]
                var tr = self["rtr"]
                bl.translate(z: -(bl.z * 2))
                br.translate(z: -(br.z * 2))
                tl.translate(z: -(tl.z * 2))
                tr.translate(z: -(tr.z * 2))
                return [
                    "bl": Vector2(bl, .zy),
                    "br": Vector2(br, .zy),
                    "tl": Vector2(tl, .zy),
                    "tr": Vector2(tr, .zy)
                ]
            case .back:
                var bl = self["bbl"]
                var br = self["bbr"]
                var tl = self["btl"]
                var tr = self["btr"]
                bl.translate(x: -(bl.x * 2))
                br.translate(x: -(br.x * 2))
                tl.translate(x: -(tl.x * 2))
                tr.translate(x: -(tr.x * 2))
                return [
                    "bl": Vector2(bl, .xy),
                    "br": Vector2(br, .xy),
                    "tl": Vector2(tl, .xy),
                    "tr": Vector2(tr, .xy)
                ]
        }
    }
}
