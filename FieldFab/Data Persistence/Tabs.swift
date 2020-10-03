//
//  Tabs.swift
//  FieldFab
//
//  Created by Robert Sale on 10/1/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI

enum TabType: Int {
    case straight = 0
    case tapered
    case drive
    case slock
}

enum TabLength: CGFloat {
    case inch        = 1.0
    case half        = 0.5
    case threeEighth = 0.375
}

enum TabSide: Int {
    case top = 0
    case bottom
    case left
    case right
}


enum TabFace: Int {
    case front = 0
    case back
    case left
    case right
}

struct Tab {
    var type:   TabType
    var length: TabLength
    var side:   TabSide
    
    init(_ l: TabLength, type: TabType = .straight, side: TabSide) {
        self.length = l
        self.type   = type
        self.side   = side
    }
    init(from: TabData) {
        switch from.type {
            case 0:  self.type = .straight
            case 1:  self.type = .tapered
            case 2:  self.type = .drive
            case 3:  self.type = .slock
            default: self.type = .straight
        }
        switch from.side {
            case 0:  self.side = .top
            case 1:  self.side = .bottom
            case 2:  self.side = .left
            case 3:  self.side = .right
            default: self.side = .top
        }
        switch from.length {
            case 1.0:    self.length = .inch
            case 0.5:    self.length = .half
            case 0.0375: self.length = .threeEighth
            default:     self.length = .inch
        }
    }
    
    func toData() -> TabData {
        return TabData(type: self.type.rawValue, length: self.length.rawValue, side: self.side.rawValue)
    }
}

struct Tabs {
    var front: Tab?
    var back:  Tab?
    var left:  Tab?
    var right: Tab?
    
    init() {}
    init(f: Tab?, b: Tab?, l: Tab?, r: Tab?) {
        front = f
        back  = b
        left  = l
        right = r
    }
    init(from: TabsData) {
        if from.front != nil { front = Tab(from: from.front!) }
        if from.back  != nil { back  = Tab(from: from.back! ) }
        if from.left  != nil { left  = Tab(from: from.left! ) }
        if from.right != nil { right = Tab(from: from.right!) }
    }
}

struct TabsData: Codable {
    var front: TabData?
    var back:  TabData?
    var left:  TabData?
    var right: TabData?
}

struct TabData: Codable {
    var type:   Int
    var length: CGFloat
    var side:   Int
}
