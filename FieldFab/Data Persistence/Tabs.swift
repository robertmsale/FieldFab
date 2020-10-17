//
//  Tabs.swift
//  FieldFab
//
//  Created by Robert Sale on 10/1/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI

enum TabType: Int, CaseIterable, Identifiable {
    case straight = 0
    case tapered
    case drive
    case foldIn
    case foldOut
    case slock
    case none

    var id: Int { self.rawValue }
    var asText: String {
        switch self {
        case .straight: return "Straight"
        case .tapered: return "Tapered"
        case .drive: return "Drive"
        case .foldIn: return "Fold Inward"
        case .foldOut: return "Fold Outward"
        case .slock: return "S-Lock"
        case .none: return "None"
        }
    }
}

enum TabLength: CGFloat, CaseIterable, Identifiable {
    case inch        = 1.0
    case half        = 0.5
    case threeEighth = 0.375
    case none = 0.0
    
    init(url: Int) {
        switch url {
            case 3: self = .inch
            case 2: self = .half
            case 1: self = .threeEighth
            default: self = .none
        }
    }

    var id: CGFloat { self.rawValue }
    var asText: String {
        switch self {
        case .inch: return "Inch"
        case .half: return "Half Inch"
        case .threeEighth: return "Three Eighth"
        case .none: return "None"
        }
    }
    var asURL: Int {
        switch self {
            case .inch: return 3
            case .half: return 2
            case .threeEighth: return 1
            case .none: return 0
        }
    }
}

enum TabSide: Int, CaseIterable, Identifiable {
    case top = 0
    case bottom
    case left
    case right

    var id: Int { self.rawValue }
    var name: String {
        switch self.rawValue {
        case 0: return "Top"
        case 1: return "Bottom"
        case 2: return "Left"
        case 3: return "Right"
        default: return ""
        }
    }
}

enum DuctFace: Int, CaseIterable, Identifiable {
    case front = 0
    case back
    case left
    case right

    var id: Int { self.rawValue }
}

struct TabsData: Codable {
    var front: TabSidesData
    var back: TabSidesData
    var left: TabSidesData
    var right: TabSidesData
    
    func toURL() -> String {
        var url = ""
        url += "ftT\(self[.front,.top,1].rawValue)L\(self[   .front,.top,1.0].asURL),"
        url += "fbT\(self[.front,.bottom,1].rawValue)L\(self[.front,.bottom,1.0].asURL),"
        url += "flT\(self[.front,.left,1].rawValue)L\(self[  .front,.left,1.0].asURL),"
        url += "frT\(self[.front,.right,1].rawValue)L\(self[ .front,.right,1.0].asURL),"
        url += "btT\(self[.back, .top,1].rawValue)L\(self[   .back, .top,1.0].asURL),"
        url += "bbT\(self[.back, .bottom,1].rawValue)L\(self[.back, .bottom,1.0].asURL),"
        url += "blT\(self[.back, .left,1].rawValue)L\(self[  .back, .left,1.0].asURL),"
        url += "brT\(self[.back, .right,1].rawValue)L\(self[ .back, .right,1.0].asURL),"
        url += "ltT\(self[.left, .top,1].rawValue)L\(self[   .left, .top,1.0].asURL),"
        url += "lbT\(self[.left, .bottom,1].rawValue)L\(self[.left, .bottom,1.0].asURL),"
        url += "llT\(self[.left, .left,1].rawValue)L\(self[  .left, .left,1.0].asURL),"
        url += "lrT\(self[.left, .right,1].rawValue)L\(self[ .left, .right,1.0].asURL),"
        url += "rtT\(self[.right,.top,1].rawValue)L\(self[   .right,.top,1.0].asURL),"
        url += "rbT\(self[.right,.bottom,1].rawValue)L\(self[.right,.bottom,1.0].asURL),"
        url += "rlT\(self[.right,.left,1].rawValue)L\(self[  .right,.left,1.0].asURL),"
        url += "rrT\(self[.right,.right,1].rawValue)L\(self[ .right,.right,1.0].asURL)"
        return url
    }
    
    init(url: String) {
        let iter = url.split(separator: ",")
        var front = TabSidesData()
        var back = TabSidesData()
        var left = TabSidesData()
        var right = TabSidesData()
        for i in iter {
            let type = NumberFormatter().number(from: "\(i[3])")?.intValue ?? 6
            let length = NumberFormatter().number(from: "\(i[5])")?.intValue ?? 0
            switch i[0] {
                case "f":
                    switch i[1] {
                        case "t":
                            front.top.type = type
                            front.top.length = TabLength(url: length).rawValue
                        case "b":
                            front.bottom.type = type
                            front.bottom.length = TabLength(url: length).rawValue
                        case "l":
                            front.left.type = type
                            front.left.length = TabLength(url: length).rawValue
                        default:
                            front.right.type = type
                            front.right.length = TabLength(url: length).rawValue
                    }
                case "b":
                    switch i[1] {
                        case "t":
                            back.top.type = type
                            back.top.length = TabLength(url: length).rawValue
                        case "b":
                            back.bottom.type = type
                            back.bottom.length = TabLength(url: length).rawValue
                        case "l":
                            back.left.type = type
                            back.left.length = TabLength(url: length).rawValue
                        default:
                            back.right.type = type
                            back.right.length = TabLength(url: length).rawValue
                    }
                case "l":
                    switch i[1] {
                        case "t":
                            left.top.type = type
                            left.top.length = TabLength(url: length).rawValue
                        case "b":
                            left.bottom.type = type
                            left.bottom.length = TabLength(url: length).rawValue
                        case "l":
                            left.left.type = type
                            left.left.length = TabLength(url: length).rawValue
                        default:
                            left.right.type = type
                            left.right.length = TabLength(url: length).rawValue
                    }
                default:
                    switch i[1] {
                        case "t":
                            right.top.type = type
                            right.top.length = TabLength(url: length).rawValue
                        case "b":
                            right.bottom.type = type
                            right.bottom.length = TabLength(url: length).rawValue
                        case "l":
                            right.left.type = type
                            right.left.length = TabLength(url: length).rawValue
                        default:
                            right.right.type = type
                            right.right.length = TabLength(url: length).rawValue
                    }
            }
        }
        self.front = front
        self.back = back
        self.left = left
        self.right = right
    }

    init() {
        front = TabSidesData()
        back = TabSidesData()
        left = TabSidesData()
        right = TabSidesData()
    }

    subscript(_ f: DuctFace) -> TabSidesData {
        get {
            switch f {
            case .front: return front
            case .back: return back
            case .left: return left
            case .right: return right
            }
        } set {
            switch f {
            case .front: front = newValue
            case .back: back = newValue
            case .left: left = newValue
            case .right: right = newValue
            }
        }
    }
    subscript(_ f: DuctFace, side: TabSide, type: Int) -> TabType {
        get {
            return self[f][side][1]
        } set {
            let sTest = newValue == .slock || newValue == .foldIn
            switch side {
            case .top, .bottom: self[f][side][1] = newValue
            case .left:
                switch f {
                case .front:
                    if sTest {
                        self[.left][.right][1] = .none
                        self[.left][.right][1.0] = .none
                    }
                case .left:
                    if sTest {
                        self[.back][.right][1] = .none
                        self[.back][.right][1.0] = .none
                    }
                case .back:
                    if sTest {
                        self[.right][.right][1] = .none
                        self[.right][.right][1.0] = .none
                    }
                case .right:
                    if sTest {
                        self[.front][.right][1] = .none
                        self[.front][.right][1.0] = .none
                    }
                }
            case .right:
                switch f {
                case .front:
                    if sTest {
                        self[.right][.left][1] = .none
                        self[.right][.left][1.0] = .none
                    }
                case .left:
                    if sTest {
                        self[.front][.left][1] = .none
                        self[.front][.left][1.0] = .none
                    }
                case .back:
                    if sTest {
                        self[.left][.left][1] = .none
                        self[.left][.left][1.0] = .none
                    }
                case .right:
                    if sTest {
                        self[.back][.left][1] = .none
                        self[.back][.left][1.0] = .none
                    }
                }
            }
            if newValue == .none {
                self[f][side][1.0] = .none
            } else {
                if self[f][side][1.0] == .none {
                    self[f][side][1.0] = .inch
                }
            }
            self[f][side][1] = newValue
        }
    }
    subscript(_ f: DuctFace, side: TabSide, length: CGFloat) -> TabLength {
        get {
            return self[f][side][1.0]
        } set {
            if newValue == .threeEighth {
                print("new length is threeEighth")
            }
            switch side {
                case .top, .bottom:
                self[f][side][1.0] = newValue
            case .left:
                switch f {
                case .front:
                    if newValue != .none {
                        self[.left][.right][1.0] = .none
                        self[.left][.right][1] = .none
                    }
                case .left:
                    if newValue != .none {
                        self[.back][.right][1.0] = .none
                        self[.back][.right][1] = .none
                    }
                case .back:
                    if newValue != .none {
                        self[.right][.right][1.0] = .none
                        self[.right][.right][1] = .none
                    }
                case .right:
                    if newValue != .none {
                        self[.front][.right][1.0] = .none
                        self[.front][.right][1] = .none
                    }
                }
            case .right:
                switch f {
                case .front:
                    if newValue != .none {
                        self[.right][.left][1.0] = .none
                        self[.right][.left][1] = .none
                    }
                case .left:
                    if newValue != .none {
                        self[.front][.left][1.0] = .none
                        self[.front][.left][1] = .none
                    }
                case .back:
                    if newValue != .none {
                        self[.left][.left][1.0] = .none
                        self[.left][.left][1] = .none
                    }
                case .right:
                    if newValue != .none {
                        self[.back][.left][1.0] = .none
                        self[.back][.left][1] = .none
                    }
                }
            }
            self[f][side][1.0] = newValue
        }
    }
}

struct TabSidesData: Codable {
    var top: TabData
    var bottom: TabData
    var left: TabData
    var right: TabData

    init() {
        top = TabData()
        bottom = TabData()
        left = TabData()
        right = TabData()
    }

    subscript(_ s: TabSide) -> TabData {
        get {
            switch s {
            case .top: return top
            case .bottom: return bottom
            case .left: return left
            case .right: return right
            }
        } set {
            switch s {
            case .top: top = newValue
            case .bottom: bottom = newValue
            case .left: left = newValue
            case .right: right = newValue
            }
        }
    }
}

struct TabData: Codable {
    var type: Int
    var length: CGFloat

    init() {
        type = TabType.none.rawValue
        length = TabLength.none.rawValue
    }

    subscript(_: Int) -> TabType {
        get {
            return getType()
        } set {
            type = newValue.rawValue
        }
    }
    subscript(_: CGFloat) -> TabLength {
        get {
            return getLength()
        } set {
            length = newValue.rawValue
        }
    }

    func getType() -> TabType {
        switch type {
        case 0: return .straight
        case 1: return .tapered
        case 2: return .drive
        case 3: return .foldIn
        case 4: return .foldOut
        case 5: return .slock
        default: return .none
        }
    }
    func getLength() -> TabLength {
        switch length {
        case 1.0: return .inch
        case 0.5: return .half
        case 0.375: return .threeEighth
        default: return .none
        }
    }
}
