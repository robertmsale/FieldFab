//
//  DuctTransitionDataTypes.swift
//  FieldFab
//
//  Created by Robert Sale on 12/31/22.
//  Copyright © 2022 Robert Sale. All rights reserved.
//

import Foundation
import Accelerate
import SceneKit
import SwiftUI
import SIMDExtensions
import ComplexModule

typealias DuctSideView = DuctTransition.DuctSideView

protocol LocalizedStringable: Codable, Identifiable {
    var localizedString: String { get }
}

struct DuctTransition {}

extension DuctTransition {
    enum TabEdge: Int, CaseIterable, LocalizedStringable {
        case top, bottom, left, right
        var id: Int { rawValue }
        var localizedString: String {
            switch self {
            case .top:
                return "Top"
            case .bottom:
                return "Bottom"
            case .left:
                return "Left"
            case .right:
                return "Right"
            }
        }
    }
}

extension DuctTransition {
    enum MeasurementUnit: Int, CaseIterable, LocalizedStringable {
        case inch, feet, meters, centimeters, millimeters
        
        var id: Int { self.rawValue }
        var localizedString: String {
            switch self {
            case .inch: return "Inches"
            case .feet: return "Feet"
            case .meters: return "Meters"
            case .centimeters: return "Centimeters"
            case .millimeters: return "Millimeters"
            }
        }
        var actualUnit: UnitLength {
            switch self {
            case .inch: return .inches
            case .feet: return .feet
            case .meters: return .meters
            case .centimeters: return .centimeters
            case .millimeters: return .millimeters
            }
        }
        static let fracVals = [
            "⅛": 0.125,
            "¼": 0.25,
            "⅜": 0.375,
            "½": 0.5,
            "⅝": 0.625,
            "¾": 0.75,
            "⅞": 0.875,
        ]
        func asEditableString(_ num: Double) -> String {
            if self == .inch {
                var suffix = ""
                var floor = num.rounded(.towardZero)
                switch abs(num.distance(to: floor)) {
                case let x where x >= 0.0625 && x < 0.1875: suffix = "⅛"
                case let x where x >= 0.1875 && x < 0.3125: suffix = "¼"
                case let x where x >= 0.3125 && x < 0.4375: suffix = "⅜"
                case let x where x >= 0.4375 && x < 0.5625: suffix = "½"
                case let x where x >= 0.5625 && x < 0.6875: suffix = "⅝"
                case let x where x >= 0.6875 && x < 0.8125: suffix = "¾"
                case let x where x >= 0.8125 && x < 0.9375: suffix = "⅞"
                case let x where x >= 0.9375: floor += 1.0
                default: break
                }
                return String(Int64(floor)) + suffix
            }
            if self == .millimeters { return String(Int(num.rounded())) }
            if self == .centimeters { return String(Double(Int(num * 10)) / 10) }
            if self == .meters { return String(Double(Int(num * 1000)) / 1000) }
            if self == .feet { return String(Double(Int(num * 10)) / 10) }
            return String(num)
        }
        func asViewOnlyString(_ num: Double) -> String {
            let estring = asEditableString(num)
            switch self {
            case .inch: return estring + "\""
            case .millimeters: return estring + " mm"
            case .centimeters: return estring + " cm"
            case .feet: return estring + " ft"
            default: return estring + "m"
            }
        }
    }
}
extension DuctTransition {
    enum UserMeasurement: Int, CaseIterable, LocalizedStringable {
        case width, depth, length, offsetx, offsety, twidth, tdepth
        
        var id: Int { self.rawValue }
        var localizedString: String {
            switch self {
            case .width: return "Width"
            case .depth: return "Depth"
            case .length: return "Length"
            case .offsetx: return "Offset X"
            case .offsety: return "Offset Y"
            case .twidth: return "T Width"
            case .tdepth: return "T Depth"
            }
        }
    }
}
extension DuctTransition {
    struct DuctData: Codable, Identifiable, Hashable, Equatable {
        typealias Tab = DuctTransition.Tab
        typealias Face = DuctTransition.Face
        typealias TabEdge = DuctTransition.TabEdge
        typealias VertexData = DuctTransition.VertexData
        typealias FaceIndices = DuctTransition.FaceIndices
        typealias MeasurementUnit = DuctTransition.MeasurementUnit
        typealias V2 = SIMD2<Double>
        typealias V3 = SIMD3<Float>
        
        var measurements: [Double] = [12.0, 12.0, 12.0, 0.0, 0.0, 12.0, 12.0]
        var unit: MeasurementUnit = .inch {
            willSet(v) {
                convert(to: v)
            }
        }
        var isTransition: Bool = false
        var name: String = "Duct"
        var date: Date = Date()
        var tabs: [DuctTransition.Tab?] = Array(repeating: nil, count: 16)
        var id: UUID = UUID()
        
        subscript(_ value: DuctTransition.UserMeasurement) -> Double {
            get {
                return measurements[value.rawValue]
            }
            set(v) {
                measurements[value.rawValue] = v
            }
        }
        
        mutating func convert(to: MeasurementUnit) {
            if to == unit { return }
            measurements = measurements.map { value in
                Measurement<UnitLength>(value: value, unit: unit.actualUnit).converted(to: to.actualUnit).value
            }
        }
        
        func genRawMeasurements(q3D: [V3], q2D: [V2], tabs: [DuctTransition.Tab?], face: DuctTransition.Face) -> [String] {
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
                totalHeight = Double(q3D[1].distance(to:V3(q3D[1].x, q3D[2].y, q3D[2].z)))
            } else {
                totalHeight = Double(q3D[1].distance(to:V3(q3D[2].x, q3D[2].y, q3D[1].z)))
            }
            for edge in tabHeightEdges {
                if let tab: DuctTransition.Tab = tabs[edge.rawValue] {
                    totalHeight += Double(tab.length.meters)
                }
            }
            
            let leftCut: Double = V2(q2D[1].x, 0).distance(to: V2(q2D[2].x, 0))
            let rightCut: Double = V2(q2D[0].x, 0).distance(to: V2(q2D[3].x, 0))
            
            var topEdge: Double = face == .front || face == .back ? self[.twidth] : self[.tdepth]
            var bottomEdge: Double = face == .front || face == .back ? self[.width] : self[.depth]
            topEdge = topEdge.convert(to: .meters, from: self.unit)
            bottomEdge = bottomEdge.convert(to: .meters, from: self.unit)
            
            let leftEdge: Double = Double(q3D[1].distance(to: q3D[2]))
            let rightEdge: Double = Double(q3D[0].distance(to: q3D[3]))
            
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
                .map { $0.convert(to: self.unit, from: .meters) }
                .map { self.unit.asViewOnlyString($0) }
        }
        
        mutating func makeSideFlat(_ side: String) {
            let depth = self[.depth]
            let tdepth = self[.tdepth]
            let width = self[.width]
            let twidth = self[.twidth]
            switch side {
                case "Front":
                    print("Made side flat")
                    self[.offsety] = abs(depth - tdepth)
                case "Back":
                    self[.offsety] = -abs(depth - tdepth)
                case "Right":
                    self[.offsetx] = abs(width - twidth)
                case "Left":
                    self[.offsetx] = -abs(width - twidth)
                default: break
            }
        }
        
        func converted(to: MeasurementUnit) -> DuctData {
            var nd = self
            nd.convert(to: to)
            return nd
        }
        
        var vertexData: VertexData { VertexData(self) }
    }
}

extension DuctTransition {
    struct VertexData {
        typealias V3 = SIMD3<Float>
        typealias Tab = DuctTransition.Tab
        typealias Face = DuctTransition.Face
        typealias TabEdge = DuctTransition.TabEdge
        typealias VertexData = DuctTransition.VertexData
        typealias FaceIndices = DuctTransition.FaceIndices
        static let GAUGE: Float = 0.00045
        var outer: [V3]
        var inner: [V3]
        init(_ data: DuctData) {
            let toMeters = data.converted(to: .meters)
            let w = Float(toMeters[.width]) / 2
            let d = Float(toMeters[.depth]) / 2
            let l = Float(toMeters[.length]) / 2
            let x = Float(toMeters[.offsetx]) / 2
            let y = Float(toMeters[.offsety]) / 2
            let u = Float(toMeters[.twidth]) / 2
            let b = Float(toMeters[.tdepth]) / 2
            let g = VertexData.GAUGE
            outer = [
                V3( u,  l,  b) + V3(x, 0, y),
                V3(-u,  l,  b) + V3(x, 0, y),
                V3(-w, -l,  d),
                V3( w, -l,  d),
                V3( u,  l, -b) + V3(x, 0, y),
                V3(-u,  l, -b) + V3(x, 0, y),
                V3(-w, -l, -d),
                V3( w, -l, -d)
            ]
            inner = outer.map { vert in
                vert - V3(vert.x < 0 ? -g : g, 0, vert.z < 0 ? -g : g)
            }
        }
        
        subscript(_ coord: FaceIndices) -> V3 {
            get    { outer[coord.index] }
            set(v) { outer[coord.index] = v }
        }
        
        func getTabPoints(_ face: DuctTransition.Face, _ edge: DuctTransition.TabEdge) -> [V3] {
            var coords: [DuctTransition.FaceIndices] = []
            switch face {
            case .front:
                switch edge {
                case .top:
                    coords = [.ftr, .ftl]
                case .bottom:
                    coords = [.fbr, .fbl]
                case .left:
                    coords = [.ftl, .fbl]
                case .right:
                    coords = [.ftr, .fbr]
                }
            case .back:
                switch edge {
                case .top:
                    coords = [.btr, .btl]
                case .bottom:
                    coords = [.bbr, .bbl]
                case .left:
                    coords = [.btl, .bbl]
                case .right:
                    coords = [.btr, .bbr]
                }
            case .left:
                switch edge {
                case .top:
                    coords = [.ltr, .ltl]
                case .bottom:
                    coords = [.lbr, .lbl]
                case .left:
                    coords = [.ltl, .lbl]
                case .right:
                    coords = [.ltr, .lbr]
                }
            case .right:
                switch edge {
                case .top:
                    coords = [.rtr, .rtl]
                case .bottom:
                    coords = [.rbr, .rbl]
                case .left:
                    coords = [.rtl, .rbl]
                case .right:
                    coords = [.rtr, .rbr]
                }
            }
            return coords.map { self[$0] }
        }
        
        func get2DQuad(_ face: Face, _ q: Math.Quad) -> DuctTransition.DuctSideView.Quad {
            typealias Q = DuctSideView.Quad
            typealias V2 = SIMD2<Double>
//            let nx = V2(-1, 1)
            switch face {
            case .front, .back: return Q(q[0].xy, q[1].xy, q[2].xy, q[3].xy)
            default: return Q(q[0].zy, q[1].zy, q[2].zy, q[3].zy)
            }
        }
        func get3DQuad(_ face: Face) -> Math.Quad {
            Math.Quad(
                FaceIndices.getFaceVerts(perspective: face == .front || face == .left ? .outer : .inner, face: face).map { outer[$0] }
            )
        }
    }
}

extension DuctTransition {
    enum Face: Int, CaseIterable, LocalizedStringable {
        case front, back, left, right
        var id: Int { rawValue }
        var localizedString: String {
            switch self {
            case .front: return "Front"
            case .back: return "Back"
            case .left: return "Left"
            case .right: return "Right"
            }
        }
    }
}

extension DuctTransition {
    enum Perspective { case outer, inner }
}

extension DuctTransition {
    enum FaceIndices: Int, CaseIterable, LocalizedStringable {
        typealias Tab = DuctTransition.Tab
        typealias Face = DuctTransition.Face
        typealias TabEdge = DuctTransition.TabEdge
        typealias VertexData = DuctTransition.VertexData
        typealias FaceIndices = DuctTransition.FaceIndices
        typealias MeasurementUnit = DuctTransition.MeasurementUnit
        case ftr =  0, ftl =  1, fbl =  2, fbr =  3,
             btr =  5, btl =  4, bbl =  7, bbr =  6,
             
             ltr = 0b1001, ltl = 0b1101, lbl = 0b1110, lbr = 0b1010,
             rtr = 0b1100, rtl = 0b1000, rbl = 0b1011, rbr = 0b1111
        var id: Int { rawValue }
        var index: Int { rawValue & 0b111 }
        var localizedString: String {
            switch self {
            case .ftr: return "ftr"
            case .ftl: return "ftl"
            case .fbl: return "fbl"
            case .fbr: return "fbr"
            case .btr: return "btr"
            case .btl: return "btl"
            case .bbl: return "bbl"
            case .bbr: return "bbr"
            case .ltr: return "ltr"
            case .ltl: return "ltl"
            case .lbl: return "lbl"
            case .lbr: return "lbr"
            case .rtr: return "rtr"
            case .rtl: return "rtl"
            case .rbl: return "rbl"
            case .rbr: return "rbr"
            }
        }
        
        static func getFaceVerts(perspective p: DuctTransition.Perspective, face f: Face) -> Array<Int> {
            var indices: [Self]!
            if p == .outer {
                if f == .front { indices = [.ftr, .ftl, .fbl, .fbr] }
                else if f == .back  { indices = [.btr, .btl, .bbl, .bbr] }
                else if f == .left  { indices = [.ltr, .ltl, .lbl, .lbr] }
                else                { indices = [.rtr, .rtl, .rbl, .rbr] }
            } else {
                if f == .front { indices = [.ftl, .ftr, .fbr, .fbl] }
                else if f == .back  { indices = [.btl, .btr, .bbr, .bbl] }
                else if f == .left  { indices = [.ltl, .ltr, .lbr, .lbl] }
                else                { indices = [.rtl, .rtr, .rbr, .rbl] }
            }
            return indices.map { $0.index }
        }
    }
}

extension DuctTransition {
    struct Tab: Codable, Hashable {
        typealias V3 = SIMD3<Float>
        typealias Face = DuctTransition.Face
        typealias TabEdge = DuctTransition.TabEdge
        typealias VertexData = DuctTransition.VertexData
        typealias FaceIndices = DuctTransition.FaceIndices
        typealias MeasurementUnit = DuctTransition.MeasurementUnit
        enum Length: Int, CaseIterable, LocalizedStringable {
            case inch = 1, half, threeEighth
            var meters: Float {
                switch self {
                case .inch: return 0.0254
                case .half: return 0.0127
                case .threeEighth: return 0.009252
                }
            }
            var ratio: Double {
                switch self {
                case .inch: return 1.0
                case .half: return 0.5
                case .threeEighth: return 0.375
                }
            }
            var localizedString: String {
                switch self {
                case .inch: return "Inch"
                case .half: return "Half Inch"
                case .threeEighth: return "Three Eighths"
                }
            }
            var id: Int { rawValue }
        }
        enum TType: Int, CaseIterable, LocalizedStringable {
            case straight = 1, tapered, foldIn, foldOut
            var id: Int { rawValue }
            var localizedString: String {
                switch self {
                case .straight: return "Straight"
                case .tapered: return "Tapered"
                case .foldIn: return "Fold In"
                case .foldOut: return "Fold Out"
                }
            }
        }
        var length: Length
        var type: TType
    }
}

extension DuctTransition {
    struct FaceGeometry {
        typealias V3 = SIMD3<Float>
        typealias V2 = SIMD2<Double>
        typealias Tab = DuctTransition.Tab
        typealias Face = DuctTransition.Face
        typealias TabEdge = DuctTransition.TabEdge
        typealias VertexData = DuctTransition.VertexData
        typealias FaceIndices = DuctTransition.FaceIndices
        static func generate(data: VertexData, face f: Face, crossBrake cb: Bool) -> Math.GeometryComplete {
            var geo: Math.GeometryComplete!
            let g = VertexData.GAUGE
            let ov = data.outer
            let iv = data.inner
            let id = FaceIndices.getFaceVerts(perspective: .outer, face: f)
            if cb {
                let cbdist: Float = 0.0163
                let oc: V3 = {
                    let p1 = ov[id[0]]
                    let p2 = ov[id[2]]
                    let p3 = ov[id[1]]
                    let p4 = ov[id[3]]
                    
                    let p13 = p1 - p3
                    let p43 = p4 - p3
                    let p21 = p2 - p1
                    
                    let d1343 = p13.dot(with: p43)
                    let d4321 = p43.dot(with: p21)
                    let d1321 = p13.dot(with: p21)
                    let d4343 = p43.dot(with: p43)
                    let d2121 = p21.dot(with: p21)
                    let denom = d2121 * d4343 - d4321 * d4321
                    let numer = d1343 * d4321 - d1321 * d4343
                    
                    let mua = numer / denom
                    let mub = (d1343 + d4321 * mua) / d4343
                    
                    let pa = p1 + mua * p21
                    let pb = p3 + mub * p43

                    let c = pa.lerp(with: pb, by: 0.5)
                    
                    let to = V3(
                        f == .left || f == .right ? f == .right ? cbdist : -cbdist : 0, 0,
                        f == .front || f == .back ? f == .front ? cbdist : -cbdist : 0
                    )
                    return c + to
                }()
                let ic: V3 = {
                    let to = V3(
                        f == .left || f == .right ? f == .right ? -g : g : 0, 0,
                        f == .front || f == .back ? f == .front ? -g : g : 0
                    )
                    return oc + to
                }()
                
                let verts: [V3] = [
                    ov[id[0]], ov[id[1]], ov[id[2]], ov[id[3]], oc,
                    iv[id[0]], iv[id[1]], iv[id[2]], iv[id[3]], ic,
                ]
                let indices: [UInt16] = [
                    // Outer
                    0, 1, 4,
                    1, 2, 4,
                    2, 3, 4,
                    3, 0, 4,
                    // Inner
                    6, 5, 9,
                    7, 6, 9,
                    8, 7, 9,
                    5, 8, 9,
                ]
                let positions: [V3] = {
                    var p: [V3] = []
                    for i in 0..<8 {
                        let ii = i*3
                        for j in ii...ii+2 {
                            p.append(verts[Int(indices[j])])
                        }
                    }
                    p.append(contentsOf: [
                        verts[5], verts[6], verts[1],
                        verts[5], verts[1], verts[0],
                        verts[3], verts[2], verts[7],
                        verts[3], verts[7], verts[8],
                    ])
                    return p
                }()
                let normals: [V3] = {
                    var n: [V3] = []
                    for i in 0..<8 {
                        let ii = i*3
                        let h01 = positions[ii].lerp(with: positions[ii+1], by: 0.5)
                        let c = h01.lerp(with: positions[ii+2], by: 0.5).normalized
                        n.append(contentsOf: [
                            c,
                            c,
                            c
                        ])
                    }
                    let t = V3(0, 1, 0).normalized
                    let b = V3(0, 1, 0).normalized
                    n.append(contentsOf: [
                        t, t, t, t, t, t,
                        b, b, b, b, b, b,
                    ])
                    return n
                }()
                let uv: [V2] = {
                    var p: [V2] = []
                    let tl = V2(x: 0, y: 1)
                    let tr = V2(x: 1, y: 1)
                    let bl = V2(x: 0, y: 0)
                    let br = V2(x: 1, y: 0)
                    let c = V2(x: 0.5, y: 0.5)
                    p.append(contentsOf: [
                        tr, tl, c,
                        tl, bl, c,
                        bl, br, c,
                        br, tr, c,
                        
                        tl, tr, c,
                        bl, tl, c,
                        br, bl, c,
                        tr, br, c,
                        
                        tr, tl, bl,
                        tr, bl, br,
                        tr, tl, bl,
                        tr, bl, br,
                        
                    ])
                    return p
                }()
                var idcfinal: [UInt16] = []
                for i in 0..<36 {idcfinal.append(UInt16(i))}
                geo = Math.GeometryComplete(vertices: positions, normals: normals, tcoords: uv, faceIndices: (0..<idcfinal.count).map({UInt16($0)}))
            } else {
                let verts: [V3] = [
                    ov[id[0]], ov[id[1]], ov[id[2]], ov[id[3]],
                    iv[id[0]], iv[id[1]], iv[id[2]], iv[id[3]],
                ]
                geo = Math.BlockGeometryBuilder(quads: [
                    Math.Quad(verts[0], verts[1], verts[2], verts[3]),
                    Math.Quad(verts[5], verts[4], verts[7], verts[6]),
                    Math.Quad(verts[4], verts[5], verts[1], verts[0]),
                    Math.Quad(verts[3], verts[2], verts[6], verts[7])
                ]).getGeometryParts()
            }
            
            return geo
        }
    }
}
    
extension DuctTransition {
    struct TabGeometry  {
        typealias V3 = SIMD3<Float>
        typealias Tab = DuctTransition.Tab
        typealias Face = DuctTransition.Face
        typealias TabEdge = DuctTransition.TabEdge
        typealias VertexData = DuctTransition.VertexData
        typealias FaceIndices = DuctTransition.FaceIndices
        
        static func getIndices(face f: Face, edge e: TabEdge) -> [Int] {
            let i = FaceIndices.getFaceVerts(perspective: .outer, face: f)
            switch e {
            case .top:
                return [i[0], i[1]]
            case .bottom:
                return [i[3], i[2]]
            case .left:
                return [i[2], i[1]]
            case .right:
                return [i[0], i[3]]
            }
        }
        
        static func generate(_ tab: Tab, face f: Face, edge e: TabEdge, verts v: [V3]) -> SCNNode {
            let x = V3(1, 0, 0)
            let y = V3(0, 1, 0)
            let z = V3(0, 0, 1)
            var axis = y
            var grow = z
            var amt: Float = VertexData.GAUGE
            var mag: Float = tab.length.meters
            if tab.type == .foldIn {
                grow = y
                switch f {
                case .front:
                    axis = z
                    mag = -mag
                case .back:
                    axis = z
                case .left:
                    axis = x
                case .right:
                    axis = x
                    mag = -mag
                }
                if e == .bottom { amt = -amt }
            } else if tab.type == .foldOut {
                grow = y
                switch f {
                case .front:
                    axis = z
                case .back:
                    axis = z
                    mag = -mag
                case .left:
                    axis = x
                    mag = -mag
                case .right:
                    axis = x
                }
                if e == .bottom { amt = -amt }
            } else if e == .left {
                axis = f == .front || f == .back ? z : x
                grow = f == .front || f == .back ? x : z
                amt *= -15
                if f == .right || f == .left {
                    amt = -amt
                }
            } else if e == .right {
                axis = f == .front || f == .back ? z : x
                grow = axis == z ? x : z
                amt *= -15
                if f == .right || f == .left { amt = -amt }
                //            else { mag = -mag }
            } else if e == .bottom {
                mag = -mag
            }
            var verts: [V3] = {
                var verts = [
                    v[1] + (axis * mag),
                    v[0] + (axis * mag),
                    v[0],
                    v[1],
                ]
                verts.append(contentsOf: verts.map({ $0 + (grow * amt) }))
                return verts
            }()
            if e == .left || e == .right {
                verts = verts.map({ $0 + (grow * (-amt/2)) })
                if f == .front || f == .right {
                    verts = verts.map({ $0 + (axis * -mag) })
                }
            } else if tab.type == .tapered || tab.type == .foldIn || tab.type == .foldOut {
                if f == .front || f == .back {
                    if  e == .bottom && tab.type != .foldOut ||
                        e == .top && tab.type == .foldIn ||
                            f == .back && tab.type == .tapered
                    { mag = -mag }
                    if f == .back && e == .bottom && tab.type == .tapered {
                        mag = -mag
                    }
                    let xmag = V3(mag, 0, 0)
                    let nxmag = V3(-mag, 0, 0)
                    verts[0] = verts[0] + xmag
                    verts[4] = verts[4] + xmag
                    verts[1] = verts[1] + nxmag
                    verts[5] = verts[5] + nxmag
                }
                if f == .left || f == .right {
                    if f == .left && e == .top && tab.type == .foldOut {
                        mag = -mag
                    }
                    if f == .left && e == .bottom && (tab.type == .tapered || tab.type == .foldOut) {
                        mag = -mag
                    }
                    if f == .right && e == .top && (tab.type == .tapered || tab.type == .foldOut) {
                        mag = -mag
                    }
                    if f == .right && e == .bottom && (tab.type == .foldOut) {
                        mag = -mag
                    }
                    let zmag = V3(0, 0, mag)
                    let nzmag = V3(0, 0, -mag)
                    verts[0] = verts[0] + zmag
                    verts[4] = verts[4] + zmag
                    verts[1] = verts[1] + nzmag
                    verts[5] = verts[5] + nzmag
                }
            }
            return Math.BlockGeometryBuilder(quads: [
                Math.Quad(verts[4], verts[5], verts[6], verts[7]),
                Math.Quad(verts[1], verts[0], verts[3], verts[2]),
                Math.Quad(verts[0], verts[1], verts[5], verts[4]),
                Math.Quad(verts[7], verts[6], verts[2], verts[3]),
                Math.Quad(verts[5], verts[1], verts[2], verts[6]),
                Math.Quad(verts[0], verts[4], verts[7], verts[3])
            ]).getGeometryParts().toNode(name: "tab-" + f.localizedString + e.localizedString)
        }
    }
}
