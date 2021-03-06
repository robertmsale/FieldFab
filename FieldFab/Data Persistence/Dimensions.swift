//
//  Dimensions.swift
//  FieldFab
//
//  Created by Robert Sale on 10/1/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI

struct DimensionsData {
    let name: String
    let createdOn: Date
    let tabs: TabsData
    let length: CGFloat
    let width: CGFloat
    let depth: CGFloat
    let offsetX: CGFloat
    let offsetY: CGFloat
    let isTransition: Bool
    let tWidth: CGFloat
    let tDepth: CGFloat
    let id: UUID
    
    init(n: String, c: Date, t: TabsData, l: CGFloat, w: CGFloat, d: CGFloat, oX: CGFloat, oY: CGFloat, iT: Bool, tW: CGFloat, tD: CGFloat) {
        name = n
        createdOn = c
        tabs = t
        length = l
        width = w
        depth = d
        offsetX = oX
        offsetY = oY
        isTransition = iT
        tWidth = tW
        tDepth = tD
        id = UUID()
    }
    
    init() {
        name = ""
        createdOn = Date()
        tabs = TabsData()
        length = 0
        width = 0
        depth = 0
        offsetX = 0
        offsetY = 0
        isTransition = false
        tWidth = 0
        tDepth = 0
        id = UUID()
    }
}

extension DimensionsData: Codable, Identifiable {}

struct Dimensions {
    typealias F = CGFloat
    let length: CGFloat
    let width: CGFloat
    let depth: CGFloat
    let offsetX: CGFloat
    let offsetY: CGFloat
    let isTransition: Bool
    let tWidth: CGFloat
    let tDepth: CGFloat

    init(l: F, w: F, d: F, oX: F, oY: F, iT: Bool, tW: F, tD: F) {
        length = l
        width = w
        depth = d
        offsetX = oX
        offsetY = oY
        isTransition = iT
        if iT {
            tWidth = tW
            tDepth = tD
        } else {
            tWidth = w
            tDepth = d
        }
    }
    init(from: DimensionsData) {
        self.init(
            l: from.length,
            w: from.width,
            d: from.depth,
            oX: from.offsetX,
            oY: from.offsetY,
            iT: from.isTransition,
            tW: from.tWidth,
            tD: from.tDepth)
    }
}
