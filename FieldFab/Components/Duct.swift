//
//  Duct.swift
//  FieldFab
//
//  Created by Robert Sale on 9/20/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI
import SceneKit

enum DuctSides {
    case front
    case left
    case back
    case right
}

struct Ductwork {
    typealias V3 = SCNVector3
    typealias V2 = CGPoint
    typealias F = CGFloat
    public var v2D: [String: V2] = [:]
    public var v3D: [String: V3] = [:]
    public var b2D: [String: V2] = [:]
    public var b3D: [String: V3] = [:]
    public var measurements: [String: Fraction] = [:]
    
    init (
        _ l: F,
        _ w: F,
        _ d: F,
        _ oX: F,
        _ oY: F,
        _ tW: F,
        _ tD: F,
        _ rT: F) {
        let v3 = Ductwork.getVertices3D(l, w, d, oX, oY, tW, tD)
        self.v3D = v3
        let v2 = Ductwork.getVertices2D(l, w, d, oX, oY, tW, tD)
        self.v2D = v2
        let b2 = Ductwork.getBounding2D(v2)
        self.b2D = b2
        let b3 = Ductwork.getBounding3D(v3)
        self.b3D = b3
        let m = Ductwork.getMeasurements(v3, rT)
        self.measurements = m
    }
    
    mutating func update (
        _ l: F,
        _ w: F,
        _ d: F,
        _ oX: F,
        _ oY: F,
        _ tW: F,
        _ tD: F,
        _ rT: F) {
        let v3 = Ductwork.getVertices3D(l, w, d, oX, oY, tW, tD)
        self.v3D = v3
        let v2 = Ductwork.getVertices2D(l, w, d, oX, oY, tW, tD)
        self.v2D = v2
        let b2 = Ductwork.getBounding2D(v2)
        self.b2D = b2
        let b3 = Ductwork.getBounding3D(v3)
        self.b3D = b3
        let m = Ductwork.getMeasurements(v3, rT)
        self.measurements = m
    }
    
    mutating func updateMeasurements(_ rT: F) {
        let m = Ductwork.getMeasurements(self.v3D, rT)
        self.measurements = m
    }
    
    static func getMeasurements(_ v: [String: V3], _ rT: F) -> [String: Fraction] {
        var lol: [String: Fraction] = [:]
        lol["front-bounding-l"] = v["fbl"]!.zero(.x).distance(v["ftl"]!.zero(.x)).toFraction(rT)
        lol["front-bounding-el"] = v["ftl"]!.zero(.y, .z).distance(v["fbl"]!.zero(.y, .z)).isLTZ()?.toFraction(rT)
        lol["front-bounding-er"] = v["ftr"]!.zero(.y, .z).distance(v["fbr"]!.zero(.y, .z)).isLTZ()?.toFraction(rT)
        lol["front-duct-t"] = v["ftl"]!.distance(v["ftr"]!).toFraction(rT)
        lol["front-duct-b"] = v["fbl"]!.distance(v["fbr"]!).toFraction(rT)
        lol["front-duct-l"] = v["fbl"]!.distance(v["ftl"]!).toFraction(rT)
        lol["front-duct-r"] = v["fbr"]!.distance(v["ftr"]!).toFraction(rT)
        lol["back-bounding-l"] = v["bbl"]!.zero(.x).distance(v["btl"]!.zero(.x)).isLTZ()?.toFraction(rT)
        lol["back-bounding-el"] = v["ftl"]!.zero(.y, .z).distance(v["fbl"]!.zero(.y, .z)).isLTZ()?.toFraction(rT)
        lol["back-bounding-er"] = v["ftr"]!.zero(.y, .z).distance(v["fbr"]!.zero(.y, .z)).isLTZ()?.toFraction(rT)
        lol["back-duct-t"] = v["ftr"]!.distance(v["ftl"]!).toFraction(rT)
        lol["back-duct-b"] = v["fbr"]!.distance(v["fbl"]!).toFraction(rT)
        lol["back-duct-l"] = v["fbl"]!.distance(v["ftl"]!).toFraction(rT)
        lol["back-duct-r"] = v["fbr"]!.distance(v["ftr"]!).toFraction(rT)
        lol["left-bounding-l"] = v["bbl"]!.zero(.z).distance(v["btl"]!.zero(.z)).isLTZ()?.toFraction(rT)
        lol["left-bounding-el"] = v["btl"]!.zero(.y, .x).distance(v["bbl"]!.zero(.y, .x)).isLTZ()?.toFraction(rT)
        lol["left-bounding-er"] = v["ftl"]!.zero(.y, .x).distance(v["fbl"]!.zero(.y, .x)).isLTZ()?.toFraction(rT)
        lol["left-duct-t"] = v["btl"]!.distance(v["ftl"]!).toFraction(rT)
        lol["left-duct-b"] = v["bbl"]!.distance(v["fbl"]!).toFraction(rT)
        lol["left-duct-l"] = v["bbl"]!.distance(v["btl"]!).toFraction(rT)
        lol["left-duct-r"] = v["fbl"]!.distance(v["ftl"]!).toFraction(rT)
        lol["right-bounding-l"] = v["bbr"]!.zero(.z).distance(v["btr"]!.zero(.z)).isLTZ()?.toFraction(rT)
        lol["right-bounding-el"] = v["fbr"]!.zero(.y, .x).distance(v["ftr"]!.zero(.y, .x)).isLTZ()?.toFraction(rT)
        lol["right-bounding-er"] = v["bbr"]!.zero(.y, .x).distance(v["btr"]!.zero(.y, .x)).isLTZ()?.toFraction(rT)
        lol["right-duct-t"] = v["btr"]!.distance(v["ftr"]!).toFraction(rT)
        lol["right-duct-b"] = v["bbr"]!.distance(v["fbr"]!).toFraction(rT)
        lol["right-duct-l"] = v["bbr"]!.distance(v["btr"]!).toFraction(rT)
        lol["right-duct-r"] = v["fbr"]!.distance(v["ftr"]!).toFraction(rT)
        return lol
    }
    
    static func getBounding2D (_ v: [String: CGPoint]) -> [String: CGPoint] {
        var lol: [String: CGPoint] = [:]
        let iter: [String] = ["f", "b", "l", "r"]
        for i in iter {
            let minX: F = min(min(v["\(i)bl"]!.x, v["\(i)tl"]!.x), min(v["\(i)br"]!.x, v["\(i)tr"]!.x))
            let maxX: F = max(max(v["\(i)bl"]!.x, v["\(i)tl"]!.x), max(v["\(i)br"]!.x, v["\(i)tr"]!.x))
            lol["\(i)bl"] = CGPoint(x: minX, y: v["\(i)bl"]!.y)
            lol["\(i)br"] = CGPoint(x: maxX, y: v["\(i)br"]!.y)
            lol["\(i)tl"] = CGPoint(x: minX, y: v["\(i)tl"]!.y)
            lol["\(i)tr"] = CGPoint(x: maxX, y: v["\(i)tr"]!.y)
        }
        return lol
    }
    
    static func getBounding3D (_ v: [String: V3]) -> [String: V3] {
        var minX: Float = 0.0
        var minY: Float = 0.0
        var minZ: Float = 0.0
        var maxX: Float = 0.0
        var maxY: Float = 0.0
        var maxZ: Float = 0.0
        for (_, v) in v {
            if v.x < minX { minX = v.x }
            if v.x > maxX { maxX = v.x }
            if v.y < minY { minY = v.y }
            if v.y > maxY { maxY = v.y }
            if v.z < minZ { minZ = v.z }
            if v.z > maxZ { maxZ = v.z }
        }
        var lol: [String: V3] = [:]
        lol["fbl"] = V3(minX, minY, maxZ)
        lol["fbr"] = V3(maxX, minY, maxZ)
        lol["ftl"] = V3(minX, maxY, maxZ)
        lol["ftr"] = V3(maxX, maxY, maxZ)
        lol["bbl"] = V3(minX, minY, minZ)
        lol["bbr"] = V3(maxX, minY, minZ)
        lol["btl"] = V3(minX, maxY, minZ)
        lol["btr"] = V3(maxX, maxY, minZ)
        return lol
    }
    
    static func getVertices2D (/*_ v: [String: V3]*/
        _ l: F,
        _ w: F,
        _ d: F,
        _ oX: F,
        _ oY: F,
        _ tW: F,
        _ tD: F
    ) -> [String: CGPoint] {
        var lol: [String: CGPoint] = [:]
        
        lol["fbl"] = V2(x: -(w / 2), y: l / 2).translate(x: -(oX / 2))
        lol["fbr"] = V2(x: w / 2, y: l / 2).translate(x: -(oX / 2))
        lol["ftl"] = V2(x: -(tW / 2) + oX, y: -(l / 2)).translate(x: -(oX / 2))
        lol["ftr"] = V2(x: tW / 2 + oX, y: -(l / 2)).translate(x: -(oX / 2))
        
        lol["bbl"] = V2(x: -(w / 2), y: l / 2).translate(x: oX)
        lol["bbr"] = V2(x: w / 2, y: l / 2).translate(x: oX)
        lol["btl"] = V2(x: -(tW / 2) - oX, y: -(l / 2)).translate(x: oX)
        lol["btr"] = V2(x: tW / 2 - oX, y: -(l / 2)).translate(x: oX)
        
        lol["lbl"] = V2(x: -(d / 2), y: l / 2).translate(x: -(oY))
        lol["lbr"] = V2(x: d / 2, y: l / 2).translate(x: -(oY))
        lol["ltl"] = V2(x: -(tD / 2) + oY, y: -(l / 2)).translate(x: -(oY))
        lol["ltr"] = V2(x: tD / 2 + oY, y: -(l / 2)).translate(x: -(oY))
        
        lol["rbl"] = V2(x: -(d / 2), y: l / 2).translate(x: oY / 2)
        lol["rbr"] = V2(x: d / 2, y: l / 2).translate(x: oY / 2)
        lol["rtl"] = V2(x: -(tD / 2) - oY, y: -(l / 2)).translate(x: oY / 2)
        lol["rtr"] = V2(x: tD / 2 - oY, y: -(l / 2)).translate(x: oY / 2)
        return lol
    }
    
    static func getVertices3D (
        _ l: F,
        _ w: F,
        _ d: F,
        _ oX: F,
        _ oY: F,
        _ tW: F,
        _ tD: F) -> [String: V3] {
        var lol: [String: V3] = [ "fbl": V3(-(w / 2), -(l / 2), d / 2) ]
        lol["fbr"] = V3(w / 2, -(l / 2), d / 2)
        lol["ftl"] = V3(-(tW / 2) + oX, l / 2, tD / 2 + oY)
        lol["ftr"] = V3(tW / 2 + oX, l / 2, tD / 2 + oY)
        lol["bbl"] = V3(-(w / 2), -(l / 2), -(d / 2))
        lol["bbr"] = V3(w / 2, -(l / 2), -(d / 2))
        lol["btl"] = V3(-(tW / 2) + oX, l / 2, -(tD / 2 + oY) + (oY * 2))
        lol["btr"] = V3(tW / 2 + oX, l / 2, -(tD / 2 + oY) + (oY * 2))
        return lol
    }
}

struct Duct {
    typealias F = CGFloat
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
    
    init (_ l: F, _ w: F, _ d: F, _ oX: F, _ oY: F, _ tW: F, _ tD: F) {
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
    
    mutating func update(_ l: F, _ w: F, _ d: F, _ oX: F, _ oY: F, _ tW: F, _ tD: F) {
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
    
    func textElements(side: DuctSides, roundTo: F) -> [String: Text] {
        let bounding = self.boundingLen(side: side)
        let l = Fraction(self[side, .left], roundTo: roundTo)
        let r = Fraction(self[side, .right], roundTo: roundTo)
        let t = Fraction(self[side, .top], roundTo: roundTo)
        let b = Fraction(self[side, .bottom], roundTo: roundTo)
        let lF = Fraction(bounding[.left]!, roundTo: roundTo)
        let tLF = Fraction(bounding[.topLeft]!, roundTo: roundTo)
        let tRF = Fraction(bounding[.topRight]!, roundTo: roundTo)
        let bLF = Fraction(bounding[.bottomLeft]!, roundTo: roundTo)
        let bRF = Fraction(bounding[.bottomRight]!, roundTo: roundTo)
        func reduce(_ v: Fraction) -> String {
            if v.original == 0.0 { return "" }
            else { return "\(v.whole)\(v.parts.d > 1 ? v.text(" n/d") : "")\"" }
        }
        print(lF.original)
        print(tLF.original)
        print(tRF.original)
        print(bLF.original)
        print(bRF.original)
        return [
            "bounding left": Text(reduce(lF)),
            "bounding topLeft": Text(reduce(tLF)),
            "bounding topRight": Text(reduce(tRF)),
            "bounding bottomLeft": Text(reduce(bLF)),
            "bounding bottomRight": Text(reduce(bRF)),
            "left": Text(reduce(l)),
            "right": Text(reduce(r)),
            "top": Text(reduce(t)),
            "bottom": Text(reduce(b)),
        ]
    }
    
    func bounding(side: DuctSides) -> [String: Vector2] {
        let p: [String: Vector2] = self[side]
        var s: [String] = []
        s.append(contentsOf: ["bl", "br", "tl", "tr"])
        var maxX: F = 0.0
        var minX: F = 0.0
        var maxY: F = 0.0
        var minY: F = 0.0
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
    
    func boundingLen(side: DuctSides) -> [BoundingLines: F] {
        var bd: [String: Vector3] = [:]
        var d: [String: Vector3] = [:]
        var s: [String] = []
        let axis = side == .left || side == .right ? "z" : "x"
        switch side {
            case .front: s.append("f")
            case .back: s.append("b")
            case .left: s.append("l")
            case .right: s.append("r")
        }
        s.append(contentsOf: ["bl", "br", "tl", "tr"])
        var minX = F(0.0)
        var maxX = F(0.0)
        for i in 1...s.count - 1 {
            bd[s[i]] = self[s[0] + s[i]]
            d[s[i]] = bd[s[i]]
            if bd[s[i]]![axis] < minX { minX = bd[s[i]]![axis] }
            if bd[s[i]]![axis] > maxX { maxX = bd[s[i]]![axis] }
        }
        let corners = side == .left || side == .back ? ["tr", "tl", "br", "bl"] : ["tl", "tr", "bl", "br"]
        bd["bl"]![axis] = minX
        bd["tl"]![axis] = minX
        bd["br"]![axis] = maxX
        bd["tr"]![axis] = maxX
        return [
            .left: bd["bl"]!.distance(to: bd["tl"]!),
            .topLeft: bd["\(corners[0])"]!.distance(to: d["\(corners[0])"]!),
            .topRight: bd["\(corners[1])"]!.distance(to: d["\(corners[1])"]!),
            .bottomLeft: bd["\(corners[2])"]!.distance(to: d["\(corners[2])"]!),
            .bottomRight: bd["\(corners[3])"]!.distance(to: d["\(corners[3])"]!)
        ]
        
    }
    
    subscript(side: DuctSides, line: DuctLines) -> F {
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
                    "bl": Vector2(self["fbl"], .xy).flipY(),
                    "br": Vector2(self["fbr"], .xy).flipY(),
                    "tl": Vector2(self["ftl"], .xy).flipY(),
                    "tr": Vector2(self["ftr"], .xy).flipY()
                ]
            case .left:
                return [
                    "bl": Vector2(self["lbl"], .zy).flipY(),
                    "br": Vector2(self["lbr"], .zy).flipY(),
                    "tl": Vector2(self["ltl"], .zy).flipY(),
                    "tr": Vector2(self["ltr"], .zy).flipY()
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
                    "bl": Vector2(bl, .zy).flipY(),
                    "br": Vector2(br, .zy).flipY(),
                    "tl": Vector2(tl, .zy).flipY(),
                    "tr": Vector2(tr, .zy).flipY()
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
                    "bl": Vector2(bl, .xy).flipY(),
                    "br": Vector2(br, .xy).flipY(),
                    "tl": Vector2(tl, .xy).flipY(),
                    "tr": Vector2(tr, .xy).flipY()
                ]
        }
    }
}

