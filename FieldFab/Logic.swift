//
//  Logic.swift
//  FieldFab
//
//  Created by Robert Sale on 9/5/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import Combine
import SwiftUI
import Guitar

enum AppLogicField {
    case width
    case depth
    case length
    case offsetX
    case offsetY
    case tWidth
    case tDepth
    case isTransition
}


class AppLogic : ObservableObject {
    @Published var width: Fraction {
        didSet {
            if !self.isTransition {
                self.tWidth.original = self.width.original
            }
        }
    }
    @Published var depth: Fraction {
        didSet {
            if !self.isTransition {
                self.tDepth.original = self.depth.original
            }
        }
    }
    @Published var length: Fraction
    @Published var offsetX: Fraction
    @Published var offsetY: Fraction
    @Published var tWidth: Fraction
    @Published var tDepth: Fraction
    @Published var isTransition: Bool

    
    init() {
        self.width = Fraction(16)
        self.depth = Fraction(20)
        self.length = Fraction(5)
        self.offsetX = Fraction(-1)
        self.offsetY = Fraction(1)
        self.tWidth = Fraction(20)
        self.tDepth = Fraction(21)
        self.isTransition = false
    }
    
    func mutate(x: Int, f: AppLogicField) {
        let v: CGFloat = x < 0 ? -0.03125 : 0.03125
        switch f {
        case .width:
            self.width.original = self.width.original + v
            if !self.isTransition { self.tWidth.original = self.width.original }
        case .depth:
            self.depth.original = self.depth.original + v
            if !self.isTransition { self.tDepth.original = self.depth.original }
        case .length:
            self.length.original = self.length.original + v
        case .offsetX:
            self.offsetX.original = self.offsetX.original + v
        case .offsetY:
            self.offsetY.original = self.offsetY.original + v
        case .tDepth:
            self.tDepth.original = self.tDepth.original + v
        case .tWidth:
            self.tWidth.original = self.tWidth.original + v
        default:
            return
        }
    }
    
    func mutateExact(x: CGFloat, f: AppLogicField) {
        switch f {
        case .width:
            self.width.original = x
            if !self.isTransition { self.tWidth.original = x }
        case .depth:
            self.depth.original = x
            if !self.isTransition { self.tDepth.original = x }
        case .length:
            self.length.original = x
        case .offsetX:
            self.offsetX.original = x
        case .offsetY:
            self.offsetY.original = x
        case .tDepth:
            self.tDepth.original = x
        case .tWidth:
            self.tWidth.original = x
        default:
            return
        }
    }
    
    func toggleTransition() {
        if self.isTransition {
            self.tWidth.original = self.width.original
            self.tDepth.original = self.depth.original
            self.tWidth.asStringNumeric = "\(self.width.whole)"
            self.tDepth.asStringNumeric = "\(self.depth.whole)"
        }
    }
}
