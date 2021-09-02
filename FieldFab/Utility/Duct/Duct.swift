//
//  Duct.swift
//  FieldFab
//
//  Created by Robert Sale on 12/17/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI
import SceneKit
import UIKit
import VectorExtensions
import StringFix

extension Array {
    subscript(index: Int, defaultVal: Element) -> Element {
        if count - 1 < index { return defaultVal }
        return self[index]
    }
}
enum RawV3 { case ftl, ftr, fbl, fbr, btl, btr, bbl, bbr }
enum PerspectiveV3 {
    case ftl, ftr, fbl, fbr, btl, btr, bbl, bbr, ltl, ltr, lbl, lbr, rtl, rtr, rbl, rbr
    var raw: RawV3 {
        switch self {
            case .ftl, .ltr: return .ftl
            case .ftr, .rtl: return .ftr
            case .fbl, .lbr: return .fbl
            case .fbr, .rbl: return .fbr
            case .btr, .ltl: return .btl
            case .btl, .rtr: return .btr
            case .bbr, .lbl: return .bbl
            case .bbl, .rbr: return .bbr
        }
    }
}

struct DuctFaceMeasure {
    var top:            Measurement<UnitLength>
    var bottom:         Measurement<UnitLength>
    var left:           Measurement<UnitLength>
    var right:          Measurement<UnitLength>
    var boundingLeft:   Measurement<UnitLength>
    var boundingRight:  Measurement<UnitLength>
    var totalLeft:      Measurement<UnitLength>
    var totalTop:       Measurement<UnitLength>
    enum Sides: Int, CaseIterable { case top, bottom, left, right, boundingLeft, boundingRight, totalLeft, totalTop }
    subscript(side: Sides) -> Measurement<UnitLength> {
        switch side {
            case .top: return top
            case .bottom: return bottom
            case .left: return left
            case .right: return right
            case .boundingLeft: return boundingLeft
            case .boundingRight: return boundingRight
            case .totalLeft: return totalLeft
            case .totalTop: return totalTop
        }
    }
    struct Faces {
        var front: DuctFaceMeasure
        var back:  DuctFaceMeasure
        var left:  DuctFaceMeasure
        var right: DuctFaceMeasure
        subscript(face: DuctData.Face) -> DuctFaceMeasure {
            get {
                switch face {
                    case .front: return front
                    case .back: return back
                    case .left: return left
                    case .right: return right
                }
            }
        }
    }
}

struct DuctGeometry {
    var front: GeometryComplete
    var back: GeometryComplete
    var left: GeometryComplete
    var right: GeometryComplete
    var tabs: DuctTabGeometry
}

struct DuctTabGeometry: DTSubscriptable {
    typealias Element = GeometryComplete
    var fl: GeometryComplete?
    var fr: GeometryComplete?
    var ft: GeometryComplete?
    var fb: GeometryComplete?
    var ll: GeometryComplete?
    var lr: GeometryComplete?
    var lt: GeometryComplete?
    var lb: GeometryComplete?
    var rl: GeometryComplete?
    var rr: GeometryComplete?
    var rt: GeometryComplete?
    var rb: GeometryComplete?
    var bl: GeometryComplete?
    var br: GeometryComplete?
    var bt: GeometryComplete?
    var bb: GeometryComplete?
}

struct Duct {
    typealias V3 = SCNVector3
    typealias V2 = CGPoint
    static let tabNodeNames: [String] = [
        "tab-front-left", "tab-front-right", "tab-front-top", "tab-front-bottom", "tab-left-left", "tab-left-right", "tab-left-top", "tab-left-bottom", "tab-right-left", "tab-right-right", "tab-right-top", "tab-right-bottom", "tab-back-left", "tab-back-right", "tab-back-top", "tab-back-bottom"
    ]
    static let ductNodeNames: [String] = [
        "Front", "Back", "Left", "Right"
    ]
    static let allNodeNames: [String] = [
        "tab-front-left", "tab-front-right", "tab-front-top", "tab-front-bottom", "tab-left-left", "tab-left-right", "tab-left-top", "tab-left-bottom", "tab-right-left", "tab-right-right", "tab-right-top", "tab-right-bottom", "tab-back-left", "tab-back-right", "tab-back-top", "tab-back-bottom", "Front", "Back", "Left", "Right"
    ]
    var data:           DuctData {
        didSet {
            recalculate()
        }
    }
    var outer:          DuctCoordinates
    var inner:          DuctCoordinates
    var tabs:           DuctTabCoordinates
    var geometry:       DuctGeometry
    var measurements:   DuctFaceMeasure.Faces
    
    mutating func recalculate() {
        let (o,i) = self.data.generateCoordinates()
        outer = o
        inner = i
        measurements = Self.genMeasurements(o: o, units: data.depth.value.unit, data: data)
        var tc = DuctTabCoordinates()
        for tab in DuctTab.FaceTab.allCases {
            if let t = data.tabs[tab] {
                tc[tab] = DuctCoordinates(array: t.generate(tab, duct: o))
            }
        }
        tabs = tc
        geometry = Self.initGeometry(o: o, i: i, tc: tc)
    }
    static func genMeasurements(o: DuctCoordinates, units: UnitLength, data: DuctData) -> DuctFaceMeasure.Faces {
        // front
        let fbl  = Measurement(value: o[.fbl].zeroed(.x).distance(o[.ftl].zeroed(.x)).d + (data.tabs.ft?.length.to3D().d ?? 0) + (data.tabs.fb?.length.to3D().d ?? 0), unit: UnitLength.meters)
        var pftt = Measurement(value: max(data.width.value.value, data.twidth.value.value), unit: data.width.value.unit)
        let (flt, frt) = (data.tabs.fl?.length.to3D().d ?? 0, data.tabs.fr?.length.to3D().d ?? 0)
        if (abs(data.offsetx.value.value) > abs(data.width.value.value - data.twidth.value.value)) {
            pftt.value += abs(data.offsetx.value.value) - abs(data.width.value.value - data.twidth.value.value)
        }
        let ftt  = Measurement(value: pftt.converted(to: .meters).value + flt + frt, unit: UnitLength.meters)
        let fbel = Measurement(value: o[.ftl].zeroed(.y, .z).distance(o[.fbl].zeroed(.y, .z)).d, unit: UnitLength.meters)
        let fber = Measurement(value: o[.ftr].zeroed(.y, .z).distance(o[.fbr].zeroed(.y, .z)).d, unit: UnitLength.meters)
        let fdt  = data.twidth.value.converted(to: .meters)
        let fdb  = data.width.value.converted(to: .meters)
        let fdl  = Measurement(value: o[.fbl].distance(o[.ftl]).d, unit: UnitLength.meters)
        let fdr  = Measurement(value: o[.fbr].distance(o[.ftr]).d, unit: UnitLength.meters)
        // back
        let bbl  = Measurement(value: o[.bbl].zeroed(.x).distance(o[.btl].zeroed(.x)).d + (data.tabs.bt?.length.to3D().d ?? 0) + (data.tabs.bb?.length.to3D().d ?? 0), unit: UnitLength.meters)
        let (blt, brt) = (data.tabs.bl?.length.to3D().d ?? 0, data.tabs.br?.length.to3D().d ?? 0)
        let btt  = Measurement(value: pftt.converted(to: .meters).value + blt + brt, unit: UnitLength.meters)
        let bbel = Measurement(value: o[.bbl].zeroed(.y, .z).distance(o[.btl].zeroed(.y, .z)).d, unit: UnitLength.meters)
        let bber = Measurement(value: o[.bbr].zeroed(.y, .z).distance(o[.btr].zeroed(.y, .z)).d, unit: UnitLength.meters)
        let bdt  = fdt
        let bdb  = fdb
        let bdl  = Measurement(value: o[.bbl].distance(o[.btl]).d, unit: UnitLength.meters)
        let bdr  = Measurement(value: o[.bbr].distance(o[.btr]).d, unit: UnitLength.meters)
        // left
        let lbl  = Measurement(value: o[.lbl].zeroed(.z).distance(o[.ltl].zeroed(.z)).d + (data.tabs.lt?.length.to3D().d ?? 0) + (data.tabs.lb?.length.to3D().d ?? 0), unit: UnitLength.meters)
        var pltt = Measurement(value: max(data.depth.value.value, data.tdepth.value.value), unit: data.depth.value.unit)
        let (llt, lrt) = (data.tabs.ll?.length.to3D().d ?? 0, data.tabs.lr?.length.to3D().d ?? 0)
        if (abs(data.offsety.value.value) > abs(data.depth.value.value - data.tdepth.value.value)) {
            pltt.value += abs(data.offsety.value.value) - abs(data.depth.value.value - data.tdepth.value.value)
        }
        let ltt  = Measurement(value: pltt.converted(to: .meters).value + llt + lrt, unit: UnitLength.meters)
        let lbel = Measurement(value: o[.ltl].zeroed(.y, .x).distance(o[.lbl].zeroed(.y, .x)).d, unit: UnitLength.meters)
        let lber = Measurement(value: o[.ltr].zeroed(.y, .x).distance(o[.lbr].zeroed(.y, .x)).d, unit: UnitLength.meters)
        let ldt  = data.tdepth.value.converted(to: .meters)
        let ldb  = data.depth.value.converted(to: .meters)
        let ldl  = Measurement(value: o[.lbl].distance(o[.ltl]).d, unit: UnitLength.meters)
        let ldr  = Measurement(value: o[.lbr].distance(o[.ltr]).d, unit: UnitLength.meters)
        // right
        let rbl  = Measurement(value: o[.rbl].zeroed(.z).distance(o[.rtl].zeroed(.z)).d + (data.tabs.rt?.length.to3D().d ?? 0) + (data.tabs.rb?.length.to3D().d ?? 0), unit: UnitLength.meters)
        let (rlt, rrt) = (data.tabs.rl?.length.to3D().d ?? 0, data.tabs.rr?.length.to3D().d ?? 0)
        let rtt  = Measurement(value: pltt.converted(to: .meters).value + rlt + rrt, unit: UnitLength.meters)
        let rbel = Measurement(value: o[.rtl].zeroed(.y, .x).distance(o[.rbl].zeroed(.y, .x)).d, unit: UnitLength.meters)
        let rber = Measurement(value: o[.rtr].zeroed(.y, .x).distance(o[.rbr].zeroed(.y, .x)).d, unit: UnitLength.meters)
        let rdt  = ldt
        let rdb  = ldb
        let rdl  = Measurement(value: o[.rbl].distance(o[.rtl]).d, unit: UnitLength.meters)
        let rdr  = Measurement(value: o[.rbr].distance(o[.rtr]).d, unit: UnitLength.meters)
        let result = DuctFaceMeasure.Faces(
            front: .init(
                top:            fdt.converted(to: units),
                bottom:         fdb.converted(to: units),
                left:           fdl.converted(to: units),
                right:          fdr.converted(to: units),
                boundingLeft:   fbel.converted(to: units),
                boundingRight:  fber.converted(to: units),
                totalLeft:      fbl.converted(to: units),
                totalTop:       ftt.converted(to: units)),
            back: .init(
                top:            bdt.converted(to: units),
                bottom:         bdb.converted(to: units),
                left:           bdl.converted(to: units),
                right:          bdr.converted(to: units),
                boundingLeft:   bbel.converted(to: units),
                boundingRight:  bber.converted(to: units),
                totalLeft:      bbl.converted(to: units),
                totalTop:       btt.converted(to: units)),
            left: .init(
                top:            ldt.converted(to: units),
                bottom:         ldb.converted(to: units),
                left:           ldl.converted(to: units),
                right:          ldr.converted(to: units),
                boundingLeft:   lbel.converted(to: units),
                boundingRight:  lber.converted(to: units),
                totalLeft:      lbl.converted(to: units),
                totalTop:       ltt.converted(to: units)),
            right: .init(
                top:            rdt.converted(to: units),
                bottom:         rdb.converted(to: units),
                left:           rdl.converted(to: units),
                right:          rdr.converted(to: units),
                boundingLeft:   rbel.converted(to: units),
                boundingRight:  rber.converted(to: units),
                totalLeft:      rbl.converted(to: units),
                totalTop:       rtt.converted(to: units)))
        return result
    }
    
    init(data: DuctData) {
        let (o, i) = data.generateCoordinates()
        var tc = DuctTabCoordinates()
        for tab in DuctTab.FaceTab.allCases {
            if let t = data.tabs[tab] {
                tc[tab] = DuctCoordinates(array: t.generate(tab, duct: o))
            }
        }
        var predata = data
        switch predata.width.value.unit {
            case .inches:
                for i in DuctData.MeasureKeys.allCases {
                    let nd = predata[i].value.asInchFrac
                    if nd == nil && abs(predata[i].value.value.rounded()) > abs(predata[i].value.value) {
                        predata[i].value.value = predata[i].value.value.rounded(.awayFromZero)
                    } else if nd != nil {
                        let derp = (nd!.n.d / nd!.d.d)
                        predata[i].value.value = predata[i].value.value.rounded(.towardZero) + (predata[i].value.value < 0 ? -derp : derp)
                    } else {
                        predata[i].value.value = predata[i].value.value.rounded(.towardZero)
                    }
                }
            default: break
        }
        self.data = predata
        outer = o
        inner = i
        tabs = tc
        let units = data.width.value.unit
        measurements = Self.genMeasurements(o: o, units: units, data: data)
        geometry = Self.initGeometry(o: o, i: i, tc: tc)
    }
    
    static func sanatize(_ data: DuctData) {
    }
    
    init() {
        let d = DuctData(name: "", units: .inch)
        data = d
        tabs = DuctTabCoordinates()
        let (o,i) = d.generateCoordinates()
        outer = o
        inner = i
        measurements = Self.genMeasurements(o: o, units: .inches, data: d)
        geometry = Self.initGeometry(o: o, i: i, tc: DuctTabCoordinates())
    }
    
    static func initGeometry(o: DuctCoordinates, i: DuctCoordinates, tc: DuctTabCoordinates) -> DuctGeometry {
        let frontG = Self.coordToGeo(
            o[.ftr],
            o[.ftl],
            o[.fbl],
            o[.fbr],
            i[.ftr],
            i[.ftl],
            i[.fbl],
            i[.fbr])
        let backG = Self.coordToGeo(
            o[.btr],
            o[.btl],
            o[.bbl],
            o[.bbr],
            i[.btr],
            i[.btl],
            i[.bbl],
            i[.bbr])
        let leftG = Self.coordToGeo(
            o[.ltr],
            o[.ltl],
            o[.lbl],
            o[.lbr],
            i[.ltr],
            i[.ltl],
            i[.lbl],
            i[.lbr])
        let rightG = Self.coordToGeo(
            o[.rtr],
            o[.rtl],
            o[.rbl],
            o[.rbr],
            i[.rtr],
            i[.rtl],
            i[.rbl],
            i[.rbr])
        var geo = DuctGeometry(front: frontG, back: backG, left: leftG, right: rightG, tabs: .init())
        for tab in DuctTab.FaceTab.allCases {
            if let t = tc[tab] {
                let a = [t.ftr, t.ftl, t.fbl, t.fbr, t.btr, t.btl, t.bbl, t.bbr]
                let geoC = Self.coordToGeo(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7])
                geo.tabs[tab] = geoC
            }
        }
        return geo
    }
    
    static func coordToGeo(_ v0: V3, _ v1: V3, _ v2: V3, _ v3: V3, _ v4: V3, _ v5: V3, _ v6: V3, _ v7: V3) -> GeometryComplete {
        var quads: [Quad] = []
        quads.append(Quad(v0, v1, v2, v3))
        quads.append(Quad(v5, v4, v7, v6))
        quads.append(Quad(v1, v5, v6, v2))
        quads.append(Quad(v4, v0, v3, v7))
        quads.append(Quad(v4, v5, v1, v0))
        quads.append(Quad(v3, v2, v6, v7))
        return GeometryBuilder(quads: quads).getGeometryParts()
    }
    
    
    private func coordToGeometry(_ v0: V3, _ v1: V3, _ v2: V3, _ v3: V3, _ v4: V3, _ v5: V3, _ v6: V3, _ v7: V3) -> SCNGeometry {
        var quads: [Quad] = []
        quads.append(Quad(v0, v1, v2, v3))
        quads.append(Quad(v5, v4, v7, v6))
        quads.append(Quad(v1, v5, v6, v2))
        quads.append(Quad(v4, v0, v3, v7))
        quads.append(Quad(v4, v5, v1, v0))
        quads.append(Quad(v3, v2, v6, v7))
        return GeometryBuilder(quads: quads).getGeometry()
    }
    
    func getNodes() -> [String: SCNNode] {
        let frontG = coordToGeometry(
            outer[.ftr],
            outer[.ftl],
            outer[.fbl],
            outer[.fbr],
            inner[.ftr],
            inner[.ftl],
            inner[.fbl],
            inner[.fbr])
        let backG = coordToGeometry(
            outer[.btr],
            outer[.btl],
            outer[.bbl],
            outer[.bbr],
            inner[.btr],
            inner[.btl],
            inner[.bbl],
            inner[.bbr])
        let leftG = coordToGeometry(
            outer[.ltr],
            outer[.ltl],
            outer[.lbl],
            outer[.lbr],
            inner[.ltr],
            inner[.ltl],
            inner[.lbl],
            inner[.lbr])
        let rightG = coordToGeometry(
            outer[.rtr],
            outer[.rtl],
            outer[.rbl],
            outer[.rbr],
            inner[.rtr],
            inner[.rtl],
            inner[.rbl],
            inner[.rbr])
        var nodes = [String: SCNNode]()
        let namedNode: (String, SCNGeometry) -> SCNNode = { (n, g) in
            let node = SCNNode()
            node.name = n
            node.geometry = g
            return node
        }
        nodes["Front"] = namedNode("Front", frontG)
        nodes["Back"] = namedNode("Back", backG)
        nodes["Left"] = namedNode("Left", leftG)
        nodes["Right"] = namedNode("Right", rightG)
        
        for tab in DuctTab.FaceTab.allCases {
            if let t = data.tabs[tab] {
                let a = t.generate(tab, duct: outer)
                let geo = coordToGeometry(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7])
                nodes[tab.tabNodeName] = namedNode(tab.tabNodeName, geo)
            }
        }
        
        return nodes
    }
    
    mutating func makeSideFlat(_ side: String) {
        let depth = data.depth.value.value
        let tdepth = data.tdepth.value.value
        let width = data.width.value.value
        let twidth = data.twidth.value.value
        switch side {
            case "Front":
                print("Made side flat")
                data.offsety.value.value = abs(depth - tdepth)
            case "Back":
                data.offsety.value.value = -abs(depth - tdepth)
            case "Right":
                data.offsetx.value.value = abs(width - twidth)
            case "Left":
                data.offsetx.value.value = -abs(width - twidth)
            default: break
        }
    }
    
}

struct DuctData: Codable, Identifiable {
    typealias V3 = SCNVector3
    typealias DM = DuctMeasurement
    enum DType: String, Codable {
        case fourpiece = "4 Piece"
        case twopiece = "2 Piece"
        case unibody = "Unibody"
    }
    enum Face: String, Codable, CaseIterable {
        case front = "Front"
        case back = "Back"
        case left = "Left"
        case right = "Right"
    }
    enum FaceAndAll: String, CaseIterable, Identifiable {
        case front = "Front"
        case back = "Back"
        case left = "Left"
        case right = "Right"
        case all = "All"
        var id: String { self.rawValue }
        var noAll: Face {
            switch self {
                case .back: return .back
                case .left: return .left
                case .right: return .right
                default: return .front
            }
        }
    }
    enum MeasureKeys: String, CaseIterable, Identifiable {
        case width, depth, length, offsetx, offsety, twidth, tdepth
        var id: String { rawValue }
    }
    
    func toURL() -> String {
        var url = "fieldfab://load?width=\(width.value.value)&"
        url += "length=\(length.value.value)&"
        url += "depth=\(depth.value.value)&"
        url += "offsetX=\(offsetx.value.value)&"
        url += "offsetY=\(offsety.value.value)&"
        url += "tWidth=\(twidth.value.value)&"
        url += "tDepth=\(tdepth.value.value)&"
        url += "tabs=\(tabs.toURL())&"
        url += "name=\(name)"
        return url
    }
    
    subscript(measure: MeasureKeys) -> DuctMeasurement {
        get {
            switch measure {
                case .width: return width
                case .depth: return depth
                case .length: return length
                case .offsetx: return offsetx
                case .offsety: return offsety
                case .twidth: return twidth
                case .tdepth: return tdepth
            }
        } set(v) {
            switch measure {
                case .width: width = v
                case .depth: depth = v
                case .length: length = v
                case .offsetx: offsetx = v
                case .offsety: offsety = v
                case .twidth: twidth = v
                case .tdepth: tdepth = v
            }
        }
    }
    
    var name:    String
    var id:      UUID
    var created: Date
    var width:   DuctMeasurement
    var depth:   DuctMeasurement
    var length:  DuctMeasurement
    var offsetx: DuctMeasurement
    var offsety: DuctMeasurement
    var twidth:  DuctMeasurement
    var tdepth:  DuctMeasurement
    var type:    DType
    var tabs:    DuctTabContainer
    
    init(name: String, units: MeasurementUnits) {
        self.name = name
        id = UUID()
        created = Date()
        var def: [DuctMeasurement] = []
        switch units {
            case let unit where unit == .feet:
                def.append(contentsOf: [1,1,1,0,0,1,1].map({DuctMeasurement.init(value: .init(value: $0, unit: unit.unit))}))
            case let unit where unit == .meters:
                def.append(contentsOf: [0.3,0.3,0.3,0,0,0.3,0.3].map({DuctMeasurement.init(value: .init(value: $0, unit: unit.unit))}))
            case let unit where unit == .centimeters:
                def.append(contentsOf: [30,30,30,0,0,30,30].map({DuctMeasurement.init(value: .init(value: $0, unit: unit.unit))}))
            case let unit where unit == .millimeters:
                def.append(contentsOf: [300,300,300,0,0,300,300].map({DuctMeasurement.init(value: .init(value: $0, unit: unit.unit))}))
            case let unit where unit == .inch:
                fallthrough
            default:
                def.append(contentsOf: [12,12,12,0,0,12,12].map({DuctMeasurement.init(value: .init(value: $0, unit: .inches))}))
        }
        width = def[0]
        depth = def[1]
        length = def[2]
        offsetx = def[3]
        offsety = def[4]
        twidth = def[5]
        tdepth = def[6]
        type = .fourpiece
        tabs = DuctTabContainer()
    }
    init(name: String, id: UUID, created: Date, width: DM, depth: DM, length: DM, offsetx: DM, offsety: DM, twidth: DM, tdepth: DM, type: DType, tabs: DuctTabContainer) {
        self.name = name
        self.id = id
        self.created = created
        self.width = width
        self.depth = depth
        self.length = length
        self.offsetx = offsetx
        self.offsety = offsety
        self.twidth = twidth
        self.tdepth = tdepth
        self.type = type
        self.tabs = tabs
    }
    init() { self.init(name: "", units: .inch)}
    init(from: DuctData) {
        name = from.name
        id = from.id
        created = from.created
        width = from.width
        depth = from.depth
        length = from.length
        offsety = from.offsety
        offsetx = from.offsetx
        twidth = from.twidth
        tdepth = from.tdepth
        type = from.type
        tabs = from.tabs
    }
    
    func generateCoordinates() -> (DuctCoordinates, DuctCoordinates) {
        typealias DM = DuctMeasurement
        let w = width.rendered3D
        let d = depth.rendered3D
        let l = length.rendered3D
        let x = offsetx.rendered3D
        let y = offsety.rendered3D
        let tw = twidth.rendered3D
        let td = tdepth.rendered3D
        let o: DuctCoordinates = {
            let fbl = V3(  -w  / 2,  -l / 2,   d  / 2  )
            let fbr = V3(   w  / 2,  -l / 2,   d  / 2  )
            let ftl = V3(  -tw / 2,   l / 2,   td / 2  ).translated([.x: x/2, .z: y/2])
            let ftr = V3(   tw / 2,   l / 2,   td / 2  ).translated([.x: x/2, .z: y/2])
            let bbl = V3(  -w  / 2,  -l / 2,  -d  / 2  )
            let bbr = V3(   w  / 2,  -l / 2,  -d  / 2  )
            let btl = V3(  -tw / 2,   l / 2,  -td / 2  ).translated([.x: x/2, .z: y/2])
            let btr = V3(   tw / 2,   l / 2,  -td / 2  ).translated([.x: x/2, .z: y/2])
            return DuctCoordinates(array: [ftr, ftl, fbl, fbr, btr, btl, bbl, bbr])
        }()
        let i: DuctCoordinates = {
            let g = DM.GAUGE
            let fbl = o.fbl.translated([.x:  g, .z: -g])
            let fbr = o.fbr.translated([.x: -g, .z: -g])
            let ftl = o.ftl.translated([.x:  g, .z: -g])
            let ftr = o.ftr.translated([.x: -g, .z: -g])
            let bbl = o.bbl.translated([.x:  g, .z:  g])
            let bbr = o.bbr.translated([.x: -g, .z:  g])
            let btl = o.btl.translated([.x:  g, .z:  g])
            let btr = o.btr.translated([.x: -g, .z:  g])
            return DuctCoordinates(array: [ftr, ftl, fbl, fbr, btr, btl, bbl, bbr])
        }()
        return (o, i)
    }
}

struct DuctCoordinates {
    typealias V3 = SCNVector3
    var fbl: V3
    var fbr: V3
    var ftl: V3
    var ftr: V3
    var bbl: V3
    var bbr: V3
    var btl: V3
    var btr: V3
    init(array a: [SCNVector3]) {
        ftr = a[0]
        ftl = a[1]
        fbl = a[2]
        fbr = a[3]
        btr = a[4]
        btl = a[5]
        bbl = a[6]
        bbr = a[7]
    }
    subscript(raw: PerspectiveV3) -> V3 {
        get {
            switch raw.raw {
                case .ftl: return ftl
                case .ftr: return ftr
                case .fbl: return fbl
                case .fbr: return fbr
                case .btl: return btl
                case .btr: return btr
                case .bbl: return bbl
                case .bbr: return bbr
            }
        } set(v) {
            switch raw.raw {
                case .ftl: ftl = v
                case .ftr: ftr = v
                case .fbl: fbl = v
                case .fbr: fbr = v
                case .btl: btl = v
                case .btr: btr = v
                case .bbl: bbl = v
                case .bbr: bbr = v
            }
        }
    }
}

protocol DTSubscriptable {
    associatedtype Element
    var fl: Element? { get set }
    var fr: Element? { get set }
    var ft: Element? { get set }
    var fb: Element? { get set }
    var ll: Element? { get set }
    var lr: Element? { get set }
    var lt: Element? { get set }
    var lb: Element? { get set }
    var rl: Element? { get set }
    var rr: Element? { get set }
    var rt: Element? { get set }
    var rb: Element? { get set }
    var bl: Element? { get set }
    var br: Element? { get set }
    var bt: Element? { get set }
    var bb: Element? { get set }
}
extension DTSubscriptable {
    subscript(lol: DuctTab.FaceTab) -> Element? {
        get {
            switch lol {
                case .fl: return fl
                case .fr: return fr
                case .ft: return ft
                case .fb: return fb
                case .ll: return ll
                case .lr: return lr
                case .lt: return lt
                case .lb: return lb
                case .rl: return rl
                case .rr: return rr
                case .rt: return rt
                case .rb: return rb
                case .bl: return bl
                case .br: return br
                case .bt: return bt
                case .bb: return bb
            }
        } set(v) {
            switch lol {
                case .fl: fl = v
                case .fr: fr = v
                case .ft: ft = v
                case .fb: fb = v
                case .ll: ll = v
                case .lr: lr = v
                case .lt: lt = v
                case .lb: lb = v
                case .rl: rl = v
                case .rr: rr = v
                case .rt: rt = v
                case .rb: rb = v
                case .bl: bl = v
                case .br: br = v
                case .bt: bt = v
                case .bb: bb = v
            }
        }
    }
}

struct DuctTabCoordinates: DTSubscriptable {
    typealias Element = DuctCoordinates
    var fl: Element?
    var fr: Element?
    var ft: Element?
    var fb: Element?
    var ll: Element?
    var lr: Element?
    var lt: Element?
    var lb: Element?
    var rl: Element?
    var rr: Element?
    var rt: Element?
    var rb: Element?
    var bl: Element?
    var br: Element?
    var bt: Element?
    var bb: Element?
    init() {}
}

struct DuctTabContainer: Codable, DTSubscriptable, Equatable {
    
    typealias Element = DuctTab
    var fl: Element? { didSet { if fl != nil { lr = nil } }}
    var fr: Element? { didSet { if fr != nil { rl = nil } }}
    var ft: Element?
    var fb: Element?
    var ll: Element? { didSet { if ll != nil { br = nil } }}
    var lr: Element? { didSet { if lr != nil { fl = nil } }}
    var lt: Element?
    var lb: Element?
    var rl: Element? { didSet { if rl != nil { fr = nil } }}
    var rr: Element? { didSet { if rr != nil { bl = nil } }}
    var rt: Element?
    var rb: Element?
    var bl: Element? { didSet { if bl != nil { rr = nil } }}
    var br: Element? { didSet { if br != nil { ll = nil } }}
    var bt: Element?
    var bb: Element?
    init() {}
    func toURL() -> String {
        var url = ""
        url += "ftT\(ft?.type.rawValue ?? 9)L\(ft?.length.rawValue ?? 9),"
        url += "fbT\(fb?.type.rawValue ?? 9)L\(fb?.length.rawValue ?? 9),"
        url += "flT\(fl?.type.rawValue ?? 9)L\(fl?.length.rawValue ?? 9),"
        url += "frT\(fr?.type.rawValue ?? 9)L\(fr?.length.rawValue ?? 9),"
        url += "btT\(bt?.type.rawValue ?? 9)L\(bt?.length.rawValue ?? 9),"
        url += "bbT\(bb?.type.rawValue ?? 9)L\(bb?.length.rawValue ?? 9),"
        url += "blT\(bl?.type.rawValue ?? 9)L\(bl?.length.rawValue ?? 9),"
        url += "brT\(br?.type.rawValue ?? 9)L\(br?.length.rawValue ?? 9),"
        url += "ltT\(lt?.type.rawValue ?? 9)L\(lt?.length.rawValue ?? 9),"
        url += "lbT\(lb?.type.rawValue ?? 9)L\(lb?.length.rawValue ?? 9),"
        url += "llT\(ll?.type.rawValue ?? 9)L\(ll?.length.rawValue ?? 9),"
        url += "lrT\(lr?.type.rawValue ?? 9)L\(lr?.length.rawValue ?? 9),"
        url += "rtT\(rt?.type.rawValue ?? 9)L\(rt?.length.rawValue ?? 9),"
        url += "rbT\(rb?.type.rawValue ?? 9)L\(rb?.length.rawValue ?? 9),"
        url += "rlT\(rl?.type.rawValue ?? 9)L\(rl?.length.rawValue ?? 9),"
        url += "rrT\(rr?.type.rawValue ?? 9)L\(rr?.length.rawValue ?? 9)"
        return url
    }
    
    init(url: String) {
        let iter = url.split(separator: ",")
        for i in iter {
            let type = DuctTab.TType(rawValue: NumberFormatter().number(from: "\(i[3])")?.intValue ?? 9)
            let length = DuctTab.Length(rawValue: NumberFormatter().number(from: "\(i[5])")?.intValue ?? 9)
            if type == nil { continue }
            switch i[0] {
                case "f":
                    switch i[1] {
                        case "t":
                            ft = DuctTab(length: length!, type: type!)
                        case "b":
                            fb = DuctTab(length: length!, type: type!)
                        case "l":
                            fl = DuctTab(length: length!, type: type!)
                        default:
                            fr = DuctTab(length: length!, type: type!)
                    }
                case "b":
                    switch i[1] {
                        case "t":
                            bt = DuctTab(length: length!, type: type!)
                        case "b":
                            bb = DuctTab(length: length!, type: type!)
                        case "l":
                            bl = DuctTab(length: length!, type: type!)
                        default:
                            br = DuctTab(length: length!, type: type!)
                    }
                case "l":
                    switch i[1] {
                        case "t":
                            lt = DuctTab(length: length!, type: type!)
                        case "b":
                            lb = DuctTab(length: length!, type: type!)
                        case "l":
                            ll = DuctTab(length: length!, type: type!)
                        default:
                            lr = DuctTab(length: length!, type: type!)
                    }
                default:
                    switch i[1] {
                        case "t":
                            rt = DuctTab(length: length!, type: type!)
                        case "b":
                            rb = DuctTab(length: length!, type: type!)
                        case "l":
                            rl = DuctTab(length: length!, type: type!)
                        default:
                            rr = DuctTab(length: length!, type: type!)
                    }
            }
        }
    }
    
    func getAll() -> [DuctTab] {
        var arr = [DuctTab]()
        let tabs: [DuctTab.FaceTab] = [.fl, .fr, .ft, .fb, .ll, .lr, .lt, .lb, .rl, .rr, .rt, .rb, .bl, .br, .bt, .bb]
        for tab in tabs { if let t = self[tab] { arr.append(t)}}
        return arr
    }
    subscript(face: DuctData.Face, edge: DuctTab.Edge) -> Element? {
        get {
            switch face {
                case .front: switch edge {
                    case .top: return ft
                    case .bottom: return fb
                    case .left: return fl
                    case .right: return fr
                }
                case .back: switch edge {
                    case .top: return bt
                    case .bottom: return bb
                    case .left: return bl
                    case .right: return br
                }
                case .left: switch edge {
                    case .top: return lt
                    case .bottom: return lb
                    case .left: return ll
                    case .right: return lr
                }
                case .right: switch edge {
                    case .top: return rt
                    case .bottom: return rb
                    case .left: return rl
                    case .right: return rr
                }
            }
        } set (v) {
            switch face {
                case .front: switch edge {
                    case .top: ft = v
                    case .bottom: fb = v
                    case .left: fl = v
                    case .right: fr = v
                }
                case .back: switch edge {
                    case .top: bt = v
                    case .bottom: bb = v
                    case .left: bl = v
                    case .right: br = v
                }
                case .left: switch edge {
                    case .top: lt = v
                    case .bottom: lb = v
                    case .left: ll = v
                    case .right: lr = v
                }
                case .right: switch edge {
                    case .top: rt = v
                    case .bottom: rb = v
                    case .left: rl = v
                    case .right: rr = v
                }
            }
        }
    }
}


#if DEBUG
struct DuctPreview: PreviewProvider {
    static var previews: some View {
//        let duct = Duct()
        return ZStack {
            Text("\(69 + 420)").background(Color.blue)
        }
    }
    
}
#endif
