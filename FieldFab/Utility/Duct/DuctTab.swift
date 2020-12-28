//
//  DuctTab.swift
//  FieldFab
//
//  Created by Robert Sale on 12/24/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import Foundation
import VectorExtensions
import SceneKit

struct DuctTab: Codable, Equatable {
    typealias V3 = SCNVector3
    typealias V2 = CGPoint
    typealias DM = DuctMeasurement
    enum TabLengthAndNil: String, CaseIterable, Identifiable {
        case inch = "Inch"
        case half = "Half Inch"
        case threeeighth = "Three Eighths"
        case none = "None"
        var id: String { self.rawValue }
    }
    enum Length: Int, Codable, CaseIterable, Identifiable {
        case inch, half, threeeighth
        func to3D() -> V3.BFP {
            switch self {
                case .inch: return 0.0254
                case .half: return 0.0127
                case .threeeighth: return 0.009525
            }
        }
        var text: String {
            switch self {
                case .inch: return "Inch"
                case .half: return "Half Inch"
                case .threeeighth: return "Three Eighths"
            }
        }
        var id: Int { rawValue }
    }
    enum TabTypeAndNil: String, CaseIterable, Identifiable {
        case none = "None"
        case slock = "S-Lock"
        case drive = "Drive"
        case straight = "Straight"
        case tapered = "Tapered"
        case foldin = "Fold-In"
        case foldout = "Fold-Out"
        var id: String { self.rawValue }
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
        var text: String {
            switch self {
                case .straight: return "Straight"
                case .tapered: return "Tapered"
                case .slock: return "S-Lock"
                case .drive: return "Drive"
                case .foldin: return "Fold-In"
                case .foldout: return "Fold-Out"
            }
        }
    }
    enum Edge: String, CaseIterable, Identifiable {
        case top = "Top"
        case bottom = "Bottom"
        case left = "Left"
        case right = "Right"
        var id: String { self.rawValue }
        func getEdge(face: DuctData.Face) -> FaceTab {
            switch self {
                case .top: switch face {
                    case .front: return .ft
                    case .back: return .bt
                    case .left: return .lt
                    case .right: return .rt
                }
                case .bottom: switch face {
                    case .front: return .fb
                    case .back: return .bb
                    case .left: return .lb
                    case .right: return .rb
                }
                case .left: switch face {
                    case .front: return .fl
                    case .back: return .bl
                    case .left: return .ll
                    case .right: return .rl
                }
                case .right: switch face {
                    case .front: return .fr
                    case .back: return .br
                    case .left: return .lr
                    case .right: return .rr
                }
            }
        }
    }
    enum FaceTab: Int, Codable, CaseIterable {
        case fl, fr, ft, fb, ll, lr, lt, lb, rl, rr, rt, rb, bl, br, bt, bb
        var tabNodeName: String {
            switch self {
                case .fl: return "tab-front-left"
                case .fr: return "tab-front-right"
                case .ft: return "tab-front-top"
                case .fb: return "tab-front-bottom"
                case .ll: return "tab-left-left"
                case .lr: return "tab-left-right"
                case .lt: return "tab-left-top"
                case .lb: return "tab-left-bottom"
                case .rl: return "tab-right-left"
                case .rr: return "tab-right-right"
                case .rt: return "tab-right-top"
                case .rb: return "tab-right-bottom"
                case .bl: return "tab-back-left"
                case .br: return "tab-back-right"
                case .bt: return "tab-back-top"
                case .bb: return "tab-back-bottom"
            }
        }
    }
    var length: Length
    var type: TType
    func generate(_ f: FaceTab, duct: DuctCoordinates) -> [SCNVector3] {
        let len = length.to3D()
        var arr: [SCNVector3] = []
        switch f {
            case .fl:
                let v0 = duct[.ftl].translated([.x: -DM.GAUGE])
                let v1 = duct[.ftl].translated([.x: -DM.GAUGE, .z: -len])
                let v2 = duct[.fbl].translated([.x: -DM.GAUGE, .z: -len])
                let v3 = duct[.fbl].translated([.x: -DM.GAUGE])
                let v4 = duct[.ftl]
                let v5 = duct[.ftl].translated([.z: -len])
                let v6 = duct[.fbl].translated([.z: -len])
                let v7 = duct[.fbl]
                arr.append(contentsOf: [v0, v1, v2, v3, v4, v5, v6, v7])
                switch type {
                    case .slock: for i in 0...3 { arr[i].translate([.x: -DM.GAUGE * 3]) }
                    default: break
                }
            case .fr:
                let v0 = duct[.ftr].translated([.x: DM.GAUGE, .z: -len])
                let v1 = duct[.ftr].translated([.x: DM.GAUGE])
                let v2 = duct[.fbr].translated([.x: DM.GAUGE])
                let v3 = duct[.fbr].translated([.x: DM.GAUGE, .z: -len])
                let v4 = duct[.ftr].translated([.z: -len])
                let v5 = duct[.ftr]
                let v6 = duct[.fbr]
                let v7 = duct[.fbr].translated([.z: -len])
                arr.append(contentsOf: [v0, v1, v2, v3, v4, v5, v6, v7])
                switch type {
                    case .slock: for i in 0...3 { arr[i].translate([.x: DM.GAUGE * 3]) }
                    default: break
                }
            case .ft:
                let v0 = duct[.ftr].translated([.y: len])
                let v1 = duct[.ftl].translated([.y: len])
                let v2 = duct[.ftl]
                let v3 = duct[.ftr]
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
                        for i in [0, 4]    { arr[i].translate([.x: -len])             }
                        for i in [1, 5]    { arr[i].translate([.x: len])            }
                        if x == .foldin {
                            for i in 4...7     { arr[i].translate([.y: -DM.GAUGE])       }
                            for i in [0,1,4,5] { arr[i].translate([.z: -len, .y: -len])  }
                        } else if x == .foldout {
                            for i in 0...3     { arr[i].translate([.y: -DM.GAUGE])       }
                            for i in [0,1,4,5] { arr[i].translate([.z: len, .y: -len])   }
                        }
                    default: break
                }
            case .fb:
                let v0 = duct[.fbr]
                let v1 = duct[.fbl]
                let v2 = duct[.fbl].translated([.y: -len])
                let v3 = duct[.fbr].translated([.y: -len])
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
                        for i in [2, 6]    { arr[i].translate([.x: len])             }
                        for i in [3, 7]    { arr[i].translate([.x: -len])            }
                        if x == .foldin {
                            for i in 4...7     { arr[i].translate([.y: DM.GAUGE])       }
                            for i in [2,3,6,7] { arr[i].translate([.z: -len, .y: len])  }
                        } else if x == .foldout {
                            for i in 0...3     { arr[i].translate([.y: DM.GAUGE])       }
                            for i in [2,3,6,7] { arr[i].translate([.z: len, .y: len])   }
                        }
                    default: break
                }
            case .ll:
                let v0 = duct[.ltl].translated([.z: -DM.GAUGE])
                let v1 = duct[.ltl].translated([.z: -DM.GAUGE, .x: len])
                let v2 = duct[.lbl].translated([.z: -DM.GAUGE, .x: len])
                let v3 = duct[.lbl].translated([.z: -DM.GAUGE])
                let v4 = duct[.ltl]
                let v5 = duct[.ltl].translated([.x: len])
                let v6 = duct[.lbl].translated([.x: len])
                let v7 = duct[.lbl]
                arr.append(contentsOf: [v0, v1, v2, v3, v4, v5, v6, v7])
                switch type {
                    case .slock: for i in 0...3 { arr[i].translate([.z: -DM.GAUGE * 3]) }
                    default: break
                }
            case .lr:
                let v0 = duct[.ltr].translated([.z: DM.GAUGE, .x: len])
                let v1 = duct[.ltr].translated([.z: DM.GAUGE])
                let v2 = duct[.lbr].translated([.z: DM.GAUGE])
                let v3 = duct[.lbr].translated([.z: DM.GAUGE, .x: len])
                let v4 = duct[.ltr].translated([.x: len])
                let v5 = duct[.ltr]
                let v6 = duct[.lbr]
                let v7 = duct[.lbr].translated([.x: len])
                arr.append(contentsOf: [v0, v1, v2, v3, v4, v5, v6, v7])
                switch type {
                    case .slock: for i in 0...3 { arr[i].translate([.z: DM.GAUGE * 3]) }
                    default: break
                }
            case .lt:
                let v0 = duct[.ltr].translated([.y: len])
                let v1 = duct[.ltl].translated([.y: len])
                let v2 = duct[.ltl]
                let v3 = duct[.ltr]
                let v4 = v0.translated([.x: DM.GAUGE])
                let v5 = v1.translated([.x: DM.GAUGE])
                let v6 = v2.translated([.x: DM.GAUGE])
                let v7 = v3.translated([.x: DM.GAUGE])
                arr.append(contentsOf: [v0, v1, v2, v3, v4, v5, v6, v7])
                switch type {
                    case .slock:
                        for i in 0...3     { arr[i].translate([.x: -DM.GAUGE * 1.5])  }
                        for i in 4...7     { arr[i].translate([.x: DM.GAUGE * 1.5]) }
                    case let x where x == .tapered || x == .foldin || x == .foldout:
                        for i in [0, 4]    { arr[i].translate([.z: -len])             }
                        for i in [1, 5]    { arr[i].translate([.z: len])            }
                        if x == .foldin {
                            for i in 4...7     { arr[i].translate([.y: -DM.GAUGE])       }
                            for i in [0,1,4,5] { arr[i].translate([.x: len, .y: -len])  }
                        } else if x == .foldout {
                            for i in 0...3     { arr[i].translate([.y: -DM.GAUGE])       }
                            for i in [0,1,4,5] { arr[i].translate([.x: -len, .y: -len])   }
                        }
                    default: break
                }
            case .lb:
                let v0 = duct[.lbr]
                let v1 = duct[.lbl]
                let v2 = duct[.lbl].translated([.y: -len])
                let v3 = duct[.lbr].translated([.y: -len])
                let v4 = v0.translated([.x: DM.GAUGE])
                let v5 = v1.translated([.x: DM.GAUGE])
                let v6 = v2.translated([.x: DM.GAUGE])
                let v7 = v3.translated([.x: DM.GAUGE])
                arr.append(contentsOf: [v0, v1, v2, v3, v4, v5, v6, v7])
                switch type {
                    case .slock:
                        for i in 0...3     { arr[i].translate([.x: -DM.GAUGE * 1.5])  }
                        for i in 4...7     { arr[i].translate([.x: DM.GAUGE * 1.5]) }
                    case let x where x == .tapered || x == .foldin || x == .foldout:
                        for i in [2, 6]    { arr[i].translate([.z: len])             }
                        for i in [3, 7]    { arr[i].translate([.z: -len])            }
                        if x == .foldin {
                            for i in 4...7     { arr[i].translate([.y: DM.GAUGE])       }
                            for i in [2,3,6,7] { arr[i].translate([.x: len, .y: len])  }
                        } else if x == .foldout {
                            for i in 0...3     { arr[i].translate([.y: DM.GAUGE])       }
                            for i in [2,3,6,7] { arr[i].translate([.x: -len, .y: len])   }
                        }
                    default: break
                }
            case .rl:
                let v0 = duct[.rtl].translated([.z: DM.GAUGE])
                let v1 = duct[.rtl].translated([.z: DM.GAUGE, .x: -len])
                let v2 = duct[.rbl].translated([.z: DM.GAUGE, .x: -len])
                let v3 = duct[.rbl].translated([.z: DM.GAUGE])
                let v4 = duct[.rtl]
                let v5 = duct[.rtl].translated([.x: -len])
                let v6 = duct[.rbl].translated([.x: -len])
                let v7 = duct[.rbl]
                arr.append(contentsOf: [v0, v1, v2, v3, v4, v5, v6, v7])
                switch type {
                    case .slock:
                        switch type {
                            case .slock: for i in 0...3 { arr[i].translate([.z: DM.GAUGE * 3]) }
                            default: break
                        }
                    default: break
                }
            case .rr:
                let v0 = duct[.rtr].translated([.z: -DM.GAUGE, .x: -len])
                let v1 = duct[.rtr].translated([.z: -DM.GAUGE])
                let v2 = duct[.rbr].translated([.z: -DM.GAUGE])
                let v3 = duct[.rbr].translated([.z: -DM.GAUGE, .x: -len])
                let v4 = duct[.rtr].translated([.x: -len])
                let v5 = duct[.rtr]
                let v6 = duct[.rbr]
                let v7 = duct[.rbr].translated([.x: -len])
                arr.append(contentsOf: [v0, v1, v2, v3, v4, v5, v6, v7])
                switch type {
                    case .slock:
                        switch type {
                            case .slock: for i in 0...3 { arr[i].translate([.z: -DM.GAUGE * 3]) }
                            default: break
                        }
                    default: break
                }
            case .rt:
                let v0 = duct[.rtr].translated([.y: len])
                let v1 = duct[.rtl].translated([.y: len])
                let v2 = duct[.rtl]
                let v3 = duct[.rtr]
                let v4 = v0.translated([.x: -DM.GAUGE])
                let v5 = v1.translated([.x: -DM.GAUGE])
                let v6 = v2.translated([.x: -DM.GAUGE])
                let v7 = v3.translated([.x: -DM.GAUGE])
                arr.append(contentsOf: [v0, v1, v2, v3, v4, v5, v6, v7])
                switch type {
                    case .slock:
                        for i in 0...3     { arr[i].translate([.x: DM.GAUGE * 1.5])  }
                        for i in 4...7     { arr[i].translate([.x: -DM.GAUGE * 1.5]) }
                    case let x where x == .tapered || x == .foldin || x == .foldout:
                        for i in [0, 4]    { arr[i].translate([.z: len])            }
                        for i in [1, 5]    { arr[i].translate([.z: -len])             }
                        if x == .foldin {
                            for i in 4...7     { arr[i].translate([.y: -DM.GAUGE])       }
                            for i in [0,1,4,5] { arr[i].translate([.x: -len, .y: -len])  }
                        } else if x == .foldout {
                            for i in 0...3     { arr[i].translate([.y: -DM.GAUGE])       }
                            for i in [0,1,4,5] { arr[i].translate([.x: len, .y: -len])   }
                        }
                    default: break
                }
            case .rb:
                let v0 = duct[.rbr]
                let v1 = duct[.rbl]
                let v2 = duct[.rbl].translated([.y: -len])
                let v3 = duct[.rbr].translated([.y: -len])
                let v4 = v0.translated([.x: DM.GAUGE])
                let v5 = v1.translated([.x: DM.GAUGE])
                let v6 = v2.translated([.x: DM.GAUGE])
                let v7 = v3.translated([.x: DM.GAUGE])
                arr.append(contentsOf: [v0, v1, v2, v3, v4, v5, v6, v7])
                switch type {
                    case .slock:
                        for i in 0...3     { arr[i].translate([.x: DM.GAUGE * 1.5])  }
                        for i in 4...7     { arr[i].translate([.x: -DM.GAUGE * 1.5]) }
                    case let x where x == .tapered || x == .foldin || x == .foldout:
                        for i in [2, 6]    { arr[i].translate([.z: -len])             }
                        for i in [3, 7]    { arr[i].translate([.z: len])            }
                        if x == .foldin {
                            for i in 4...7     { arr[i].translate([.y: DM.GAUGE])        }
                            for i in [2,3,6,7] { arr[i].translate([.x: -len, .y: len])   }
                        } else if x == .foldout {
                            for i in 0...3     { arr[i].translate([.y: DM.GAUGE])        }
                            for i in [2,3,6,7] { arr[i].translate([.x: len, .y: len])    }
                        }
                    default: break
                }
            case .bl:
                let v0 = duct[.btl].translated([.x: DM.GAUGE])
                let v1 = duct[.btl].translated([.x: DM.GAUGE, .z: len])
                let v2 = duct[.bbl].translated([.x: DM.GAUGE, .z: len])
                let v3 = duct[.bbl].translated([.x: DM.GAUGE])
                let v4 = duct[.btl]
                let v5 = duct[.btl].translated([.z: len])
                let v6 = duct[.bbl].translated([.z: len])
                let v7 = duct[.bbl]
                arr.append(contentsOf: [v0, v1, v2, v3, v4, v5, v6, v7])
                switch type {
                    case .slock: for i in 0...3 { arr[i].translate([.x: DM.GAUGE * 3]) }
                    default: break
                }
            case .br:
                let v0 = duct[.btr].translated([.x: -DM.GAUGE, .z: len])
                let v1 = duct[.btr].translated([.x: -DM.GAUGE])
                let v2 = duct[.bbr].translated([.x: -DM.GAUGE])
                let v3 = duct[.bbr].translated([.x: -DM.GAUGE, .z: len])
                let v4 = duct[.btr].translated([.z: len])
                let v5 = duct[.btr]
                let v6 = duct[.bbr]
                let v7 = duct[.bbr].translated([.z: len])
                arr.append(contentsOf: [v0, v1, v2, v3, v4, v5, v6, v7])
                switch type {
                    case .slock: for i in 0...3 { arr[i].translate([.x: -DM.GAUGE * 3]) }
                    default: break
                }
            case .bt:
                let v0 = duct[.btr].translated([.y: len])
                let v1 = duct[.btl].translated([.y: len])
                let v2 = duct[.btl]
                let v3 = duct[.btr]
                let v4 = v0.translated([.z: DM.GAUGE])
                let v5 = v1.translated([.z: DM.GAUGE])
                let v6 = v2.translated([.z: DM.GAUGE])
                let v7 = v3.translated([.z: DM.GAUGE])
                arr.append(contentsOf: [v0, v1, v2, v3, v4, v5, v6, v7])
                switch type {
                    case .slock:
                        for i in 0...3     { arr[i].translate([.z: -DM.GAUGE * 1.5])  }
                        for i in 4...7     { arr[i].translate([.z: DM.GAUGE * 1.5]) }
                    case let x where x == .tapered || x == .foldin || x == .foldout:
                        for i in [0, 4]    { arr[i].translate([.x: len])             }
                        for i in [1, 5]    { arr[i].translate([.x: -len])            }
                        if x == .foldout {
                            for i in 4...7     { arr[i].translate([.y: -DM.GAUGE])       }
                            for i in [0,1,4,5] { arr[i].translate([.z: -len, .y: -len])  }
                        } else if x == .foldin {
                            for i in 0...3     { arr[i].translate([.y: DM.GAUGE])       }
                            for i in [0,1,4,5] { arr[i].translate([.z: len, .y: -len])   }
                        }
                    default: break
                }
            case .bb:
                let v0 = duct[.bbr]
                let v1 = duct[.bbl]
                let v2 = duct[.bbl].translated([.y: -len])
                let v3 = duct[.bbr].translated([.y: -len])
                let v4 = v0.translated([.z: DM.GAUGE])
                let v5 = v1.translated([.z: DM.GAUGE])
                let v6 = v2.translated([.z: DM.GAUGE])
                let v7 = v3.translated([.z: DM.GAUGE])
                arr.append(contentsOf: [v0, v1, v2, v3, v4, v5, v6, v7])
                switch type {
                    case .slock:
                        for i in 0...3     { arr[i].translate([.z: -DM.GAUGE * 1.5])  }
                        for i in 4...7     { arr[i].translate([.z: DM.GAUGE * 1.5]) }
                    case let x where x == .tapered || x == .foldin || x == .foldout:
                        for i in [2, 6]    { arr[i].translate([.x: -len])             }
                        for i in [3, 7]    { arr[i].translate([.x: len])            }
                        if x == .foldout {
                            for i in 4...7     { arr[i].translate([.y: -DM.GAUGE])       }
                            for i in [2,3,6,7] { arr[i].translate([.z: -len, .y: len])  }
                        } else if x == .foldin {
                            for i in 0...3     { arr[i].translate([.y: DM.GAUGE])       }
                            for i in [2,3,6,7] { arr[i].translate([.z: len, .y: len])   }
                        }
                    default: break
                }
        }
        return arr
    }
}
