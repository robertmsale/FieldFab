//
//  Duct.swift
//  FieldFab
//
//  Created by Robert Sale on 12/17/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI
import SceneKit
import VectorExtensions

struct DuctMeasurement: Codable {
    static let GAUGE: Float = 0.00079375
    var value: Measurement<UnitLength>
    var rendered3D: Float { value.converted(to: .meters).value.f }
    var rendered2D: CGFloat { value.converted(to: .meters).value.cg }
}

struct DuctTab: Codable {
    typealias V3 = SCNVector3
    typealias V2 = CGPoint
    typealias DM = DuctMeasurement
    enum Length: Int, Codable {
        case inch, half, threeeighth
        func to3D() -> V3.BFP {
            switch self {
                case .inch: return 0.0254
                case .half: return 0.0127
                case .threeeighth: return 0.009525
            }
        }
    }
    enum TType: Int, Codable, CaseIterable, Identifiable { case slock, drive, straight, tapered, foldin, foldout
        var rawType: TType {
            switch self {
                case .slock: return .slock
                case .drive: return .drive
                case .straight: return .straight
                case .tapered, .foldin, .foldout: return .tapered
            }
        }
        var id: Int { self.rawValue }
    }
    enum FaceTab: Int, Codable, CaseIterable {
        case fl, fr, ft, fb, ll, lr, lt, lb, rl, rr, rt, rb, bl, br, bt, bb
    }
    var length: Length
    var type: TType
    func generate(_ f: FaceTab, duct: DuctCoordinates, thickness: V3.BFP) -> [SCNVector3] {
        let len = length.to3D()
        var arr: [SCNVector3] = []
        switch f {
            case .fl:
                let v0 = duct.ftl.translated([.x: -DM.GAUGE])
                let v1 = v0.translated([.z: -len])
                let v3 = duct.fbl.translated([.x: -DM.GAUGE])
                let v2 = v3.translated([.z: -len])
                let v4 = duct.ftl
                let v5 = duct.ftl.translated([.z: -len])
                let v7 = duct.fbl
                let v6 = v7.translated([.z: -len])
                arr.append(contentsOf: [v0, v1, v2, v3, v4, v5, v6, v7])
                switch type {
                    case .slock: for i in 0...3 { arr[i].translate([.x: -DM.GAUGE * 3]) }
                    default: break
                }
            case .fr:
                let v0 = duct.ftr.translated([.x: DM.GAUGE])
                let v1 = v0.translated([.z: -len])
                let v3 = duct.fbr.translated([.x: DM.GAUGE])
                let v2 = v3.translated([.z: -len])
                let v4 = duct.ftr
                let v5 = v4.translated([.z: -len])
                let v7 = duct.fbr
                let v6 = v7.translated([.z: -len])
                arr.append(contentsOf: [v0, v1, v2, v3, v4, v5, v6, v7])
                switch type {
                    case .slock: for i in 0...3 { arr[i].translate([.x: -DM.GAUGE * 3]) }
                    default: break
                }
            case .ft:
                let v0 = duct.ftr.translated([.y: len])
                let v1 = duct.ftl.translated([.y: len])
                let v2 = duct.ftl
                let v3 = duct.ftr
                let v4 = v0.translated([.z: -DM.GAUGE])
                let v5 = v1.translated([.z: -DM.GAUGE])
                let v6 = v2.translated([.z: -DM.GAUGE])
                let v7 = v3.translated([.z: -DM.GAUGE])
                arr.append(contentsOf: [v0, v1, v2, v3, v4, v5, v6, v7])
                switch type {
                    case .slock:
                        for i in 0...3     { arr[i].translate([.z: DM.GAUGE * 1.5])  }
                        for i in 4...7     { arr[i].translate([.z: -DM.GAUGE * 1.5]) }
                    case let x where x == .tapered || x == .foldin || x == .foldout:
                        for i in [0, 4]    { arr[i].translate([.x: len])             }
                        for i in [1, 5]    { arr[i].translate([.x: -len])            }
                        fallthrough
                    case .foldin:
                        for i in 4...7     { arr[i].translate([.y: -DM.GAUGE])       }
                        for i in [0,1,4,5] { arr[i].translate([.z: -len, .y: -len])  }
                        fallthrough
                    case .foldout:
                        for i in 0...3     { arr[i].translate([.y: -DM.GAUGE])       }
                        for i in [0,1,4,5] { arr[i].translate([.z: len, .y: -len])   }
                    default: break
                }
            case .fb:
                let v3 = duct.fbr.translated([.y: -len])
                let v2 = duct.fbl.translated([.y: -len])
                let v1 = duct.fbl
                let v0 = duct.fbr
                let v4 = v0.translated([.z: -DM.GAUGE])
                let v5 = v1.translated([.z: -DM.GAUGE])
                let v6 = v2.translated([.z: -DM.GAUGE])
                let v7 = v3.translated([.z: -DM.GAUGE])
                arr.append(contentsOf: [v0, v1, v2, v3, v4, v5, v6, v7])
                switch type {
                    case .slock:
                        for i in 0...3     { arr[i].translate([.z: DM.GAUGE * 1.5])  }
                        for i in 4...7     { arr[i].translate([.z: -DM.GAUGE * 1.5]) }
                    case let x where x == .tapered || x == .foldin || x == .foldout:
                        for i in [0, 4]    { arr[i].translate([.x: len])             }
                        for i in [1, 5]    { arr[i].translate([.x: -len])            }
                        fallthrough
                    case .foldin:
                        for i in 4...7     { arr[i].translate([.y: -DM.GAUGE])       }
                        for i in [0,1,4,5] { arr[i].translate([.z: -len, .y: len])  }
                        fallthrough
                    case .foldout:
                        for i in 0...3     { arr[i].translate([.y: -DM.GAUGE])       }
                        for i in [0,1,4,5] { arr[i].translate([.z: len, .y: len])   }
                    default: break
                }
            case .ll:
                let v0 = duct[.ltl].translated([.z: -DM.GAUGE])
                let v1 = v0.translated([.x: len])
                let v3 = duct[.lbl].translated([.z: -DM.GAUGE])
                let v2 = v3.translated([.x: len])
                let v4 = duct[.ltl]
                let v5 = v4.translated([.x: -len])
                let v7 = duct[.lbl]
                let v6 = v7.translated([.x: -len])
                arr.append(contentsOf: [v0, v1, v2, v3, v4, v5, v6, v7])
                switch type {
                    case .slock: for i in 0...3 { arr[i].translate([.z: -DM.GAUGE * 3]) }
                    default: break
                }
            case .lr:
                let v0 = duct[.ltr].translated([.z: DM.GAUGE])
                let v1 = v0.translated([.x: len])
                let v3 = duct[.lbr].translated([.z: DM.GAUGE])
                let v2 = v3.translated([.x: len])
                let v4 = duct[.ltr]
                let v5 = v4.translated([.x: len])
                let v7 = duct[.lbr]
                let v6 = v7.translated([.x: len])
                arr.append(contentsOf: [v0, v1, v2, v3, v4, v5, v6, v7])
                switch type {
                    case .slock: for i in 0...3 { arr[i].translate([.z: DM.GAUGE * 3]) }
                    default: break
                }
            case .lt:
                let v0 = duct[.ltr].translated([.y: len])
                let v1 = duct[.ltl].translated([.y: len])
                let v3 = duct[.ltl]
                let v2 = duct[.ltr]
                let v4 = v0.translated([.x: -DM.GAUGE])
                let v5 = v1.translated([.x: -DM.GAUGE])
                let v7 = v2.translated([.x: -DM.GAUGE])
                let v6 = v3.translated([.x: -DM.GAUGE])
                arr.append(contentsOf: [v0, v1, v2, v3, v4, v5, v6, v7])
                switch type {
                    case .slock:
                        for i in 0...3     { arr[i].translate([.x: DM.GAUGE * 1.5])  }
                        for i in 4...7     { arr[i].translate([.x: -DM.GAUGE * 1.5]) }
                    case let x where x == .tapered || x == .foldin || x == .foldout:
                        for i in [0, 4]    { arr[i].translate([.x: len])             }
                        for i in [1, 5]    { arr[i].translate([.x: -len])            }
                        fallthrough
                    case .foldin:
                        for i in 4...7     { arr[i].translate([.y: -DM.GAUGE])       }
                        for i in [0,1,4,5] { arr[i].translate([.z: -len, .y: -len])  }
                        fallthrough
                    case .foldout:
                        for i in 0...3     { arr[i].translate([.y: -DM.GAUGE])       }
                        for i in [0,1,4,5] { arr[i].translate([.z: len, .y: -len])   }
                    default: break
                }
            case .lb: switch type {
                case .slock:

                case .tapered:

                case .straight:

                case .foldin:

                case .foldout:


            }
            case .rl: switch type {
                case .slock:

                case .tapered:

                case .straight:

                case .foldin:

                case .foldout:


            }
            case .rr: switch type {
                case .slock:

                case .tapered:

                case .straight:

                case .foldin:

                case .foldout:


            }
            case .rt: switch type {
                case .slock:

                case .tapered:

                case .straight:

                case .foldin:

                case .foldout:


            }
            case .rb: switch type {
                case .slock:

                case .tapered:

                case .straight:

                case .foldin:

                case .foldout:


            }
            case .bl: switch type {
                case .slock:

                case .tapered:

                case .straight:

                case .foldin:

                case .foldout:


            }
            case .br: switch type {
                case .slock:

                case .tapered:

                case .straight:

                case .foldin:

                case .foldout:


            }
            case .bt: switch type {
                case .slock:

                case .tapered:

                case .straight:

                case .foldin:

                case .foldout:


            }
            case .bb: switch type {
                case .slock:

                case .tapered:

                case .straight:

                case .foldin:

                case .foldout:


            }
        }
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

struct DuctData: Codable {
    enum DType: String, Codable {
        case fourpiece = "4 Piece"
        case twopiece = "2 Piece"
        case unibody = "Unibody"
    }
    enum Face: String, Codable {
        case front = "Front"
        case back = "Back"
        case left = "Left"
        case right = "Right"
    }
    
    var name:    String
    var width:   DuctMeasurement
    var depth:   DuctMeasurement
    var length:  DuctMeasurement
    var offsetx: DuctMeasurement
    var offsety: DuctMeasurement
    var twidth:  DuctMeasurement
    var tdepth:  DuctMeasurement
    var type:    DType
    
    func generate3DGeometry() {
        
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

struct DuctTabContainer: Codable {
    var fl: DuctTab?
    var fr: DuctTab?
    var ft: DuctTab?
    var fb: DuctTab?
    var ll: DuctTab?
    var lr: DuctTab?
    var lt: DuctTab?
    var lb: DuctTab?
    var rl: DuctTab?
    var rr: DuctTab?
    var rt: DuctTab?
    var rb: DuctTab?
    var bl: DuctTab?
    var br: DuctTab?
    var bt: DuctTab?
    var bb: DuctTab?
    subscript(lol: DuctTab.FaceTab) -> DuctTab? {
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

struct DuctPreview: PreviewProvider {
    static var previews: some View {
        var lol = SCNVector3(2, 3, 4)
        lol.lerp(.init(3, 4, 5), alpha: 0.4)
        return Text("x: \(lol.x), y: \(lol.y), z: \(lol.z)")
    }
    
}
