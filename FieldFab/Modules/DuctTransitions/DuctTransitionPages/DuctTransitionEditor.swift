//
//  DuctTransitionEditor.swift
//  FieldFab
//
//  Created by Robert Sale on 12/31/22.
//  Copyright © 2022 Robert Sale. All rights reserved.
//

import SwiftUI
#if DEBUG
@_exported import HotSwiftUI
#endif

extension DuctTransition {
    struct DuctEditor: View {
        enum TabLengthAndNone: Int, CaseIterable, Identifiable {
            case none, inch, half, threeEighth
            var id: Int { rawValue }
            var localizedString: String {
                switch self {
                case .none: return "None"
                case .inch: return "Inch"
                case .half: return "Half Inch"
                case .threeEighth: return "Three Eighths"
                }
            }
            var actual: DuctTransition.Tab.Length {
                return DuctTransition.Tab.Length(rawValue: self.rawValue) ?? .inch
            }
        }
        enum TabTypeAndNone: Int, CaseIterable, Identifiable {
            case none, straight, tapered, foldIn, foldOut
            var id: Int { rawValue }
            var localizedString: String {
                switch self {
                case .none: return "None"
                case .straight: return "Straight"
                case .tapered: return "Tapered"
                case .foldIn: return "Fold In"
                case .foldOut: return "Fold Out"
                }
            }
            var actual: DuctTransition.Tab.TType {
                return DuctTransition.Tab.TType(rawValue: self.rawValue) ?? .straight
            }
        }
        
        enum FacesAndAll: Int, CaseIterable, Identifiable {
            case front, back, left, right, all
            var id: Int { rawValue }
            var actual: DTF {
                return DTF(rawValue: id) ?? .front
            }
            var localizedString: String {
                if self == .all { return "All" }
                return actual.localizedString
            }
        }
        
        typealias DTF = DuctTransition.Face
        @Binding var ductwork: DuctTransition.DuctData
        @State var currentFace: FacesAndAll = .front
        @State var currentMeasurement: DuctTransition.UserMeasurement = .width
        @State var currentValue: String = "0"
        @State var currentTabEdge: DuctTransition.TabEdge = .top
        @State var currentTabLength: TabLengthAndNone = .none
        @State var currentTabType: TabTypeAndNone = .none
        @State var keyboardShown = false
        var currentCanBeNegative: Bool {
            currentMeasurement == .offsetx || currentMeasurement == .offsety
        }
        let debug = false
        
        @ViewBuilder
        func drawSideViews(_ g: GeometryProxy) -> some View {
            if currentFace == .all {
                let sq = max(g.size.height, g.size.width) / 4
                VStack {
                    HStack {
                        ZStack {
                            DuctTransition.DuctSideView(ductwork: ductwork, face: .front)
                                    .scaleEffect(0.75)
                            Text("F")
                        }
                            .clipped()
                            .frame(width: sq, height: sq)
                            .border(Color.blue, width: debug ? 2 : 0)
                        ZStack {
                            DuctTransition.DuctSideView(ductwork: ductwork, face: .back)
                                    .scaleEffect(0.75)
                            Text("B")
                        }
                            .clipped()
                            .frame(width: sq, height: sq)
                            .border(Color.blue, width: debug ? 2 : 0)
                    }
                    HStack {
                        ZStack {
                            DuctTransition.DuctSideView(ductwork: ductwork, face: .left)
                                    .scaleEffect(0.75)
                            Text("L")
                        }
                            .clipped()
                            .frame(width: sq, height: sq)
                            .border(Color.blue, width: debug ? 2 : 0)
                        ZStack {
                            DuctTransition.DuctSideView(ductwork: ductwork, face: .right)
                                    .scaleEffect(0.75)
                            Text("R")
                        }
                            .clipped()
                            .frame(width: sq, height: sq)
                            .border(Color.blue, width: debug ? 2 : 0)
                    }
                }
            } else {
                DuctTransition.DuctSideView(ductwork: ductwork, face: currentFace.actual)
//                        .scaleEffect(0.75)
                    .clipped()
                    .frame(width: max(g.size.height, g.size.width) / 2, height: max(g.size.height, g.size.width) / 2)
                    .border(Color.blue, width: debug ? 2 : 0)
            }
        }
        
        @ViewBuilder
        func drawMeasurements() -> some View {
            Section("Measurements") {
                Picker("Unit", selection: $ductwork.unit) {
                    ForEach(DuctTransition.MeasurementUnit.allCases) { u in
                        Text(u.localizedString).tag(u)
                    }
                }
//                Text("Ayyyy")
                ForEach(DuctTransition.UserMeasurement.allCases) { m in
                    HStack {
                        Text(m.localizedString)
                        Spacer()
                        Button(action: {
                            Task {
                                currentValue = ductwork.unit.asEditableString(ductwork[m])
                                currentMeasurement = m
                                keyboardShown = true
                            }
                        }) {
                            Text(ductwork.unit.asViewOnlyString(ductwork[m]))
                        }
                    }
                }
            }//.disabled(currentFace == .all)
        }
        
        @ViewBuilder
        func drawTabSelectors() -> some View {
            Section("Tabs") {
                Picker("Tab Edge", selection: $currentTabEdge) {
                    ForEach(DuctTransition.TabEdge.allCases) { e in
                        Text(e.localizedString).tag(e)
                    }
                }.disabled(currentFace == .all)
                .pickerStyle(SegmentedPickerStyle())
                Picker("Tab Length", selection: $currentTabLength) {
                    ForEach(TabLengthAndNone.allCases) { l in
                        Text(l.localizedString).tag(l)
                    }
                }.disabled(currentFace == .all)
                Picker("Tab Type", selection: $currentTabType) {
                    ForEach(TabTypeAndNone.allCases) { l in
                            Text(l.localizedString).tag(l)
                    }
                }.disabled(currentFace == .all)
                Menu("Tab Presets") {
                    Menu("Inch") {
                        Button(action: {
                            ductwork.tabs = Array(repeating: nil, count: 16)
                            for edge in DuctTransition.TabEdge.allCases {
                                for face in DuctTransition.Face.allCases {
                                    if (edge == .left || edge == .right) && (face == .left || face == .right) { continue }
                                    ductwork.tabs[face, edge] = Tab(length: .inch, type: .straight)
                                }
                            }
                        }) {
                            Text("All Edges, front and back horizontal")
                        }
                        Button(action: {
                            ductwork.tabs = Array(repeating: nil, count: 16)
                            for edge in DuctTransition.TabEdge.allCases {
                                for face in DuctTransition.Face.allCases {
                                    if (edge == .left || edge == .right) && (face == .front || face == .back) { continue }
                                    ductwork.tabs[face, edge] = Tab(length: .inch, type: .straight)
                                }
                            }
                        }) {
                            Text("All Edges, left and right horizontal")
                        }
                        Button(action: {
                            ductwork.tabs = Array(repeating: nil, count: 16)
                            for edge in DuctTransition.TabEdge.allCases {
                                for face in DuctTransition.Face.allCases {
                                    if (edge == .left || edge == .right) { continue }
                                    ductwork.tabs[face, edge] = Tab(length: .inch, type: .straight)
                                }
                            }
                        }) {
                            Text("All Top & Bottom")
                        }
                        Button(action: {
                            ductwork.tabs = Array(repeating: nil, count: 16)
                            for face in DuctTransition.Face.allCases {
                                ductwork.tabs[face, .top] = Tab(length: .inch, type: .straight)
                            }
                        }) {
                            Text("Top tabs only")
                        }
                        Button(action: {
                            ductwork.tabs = Array(repeating: nil, count: 16)
                            for face in DuctTransition.Face.allCases {
                                ductwork.tabs[face, .bottom] = Tab(length: .inch, type: .straight)
                            }
                        }) {
                            Text("Bottom tabs only")
                        }
                    }
                    Menu("Half") {
                        Button(action: {
                            ductwork.tabs = Array(repeating: nil, count: 16)
                            for edge in DuctTransition.TabEdge.allCases {
                                for face in DuctTransition.Face.allCases {
                                    if (edge == .left || edge == .right) && (face == .left || face == .right) { continue }
                                    ductwork.tabs[face, edge] = Tab(length: .half, type: .straight)
                                }
                            }
                        }) {
                            Text("All Edges, front and back horizontal")
                        }
                        Button(action: {
                            ductwork.tabs = Array(repeating: nil, count: 16)
                            for edge in DuctTransition.TabEdge.allCases {
                                for face in DuctTransition.Face.allCases {
                                    if (edge == .left || edge == .right) && (face == .front || face == .back) { continue }
                                    ductwork.tabs[face, edge] = Tab(length: .half, type: .straight)
                                }
                            }
                        }) {
                            Text("All Edges, left and right horizontal")
                        }
                        Button(action: {
                            ductwork.tabs = Array(repeating: nil, count: 16)
                            for edge in DuctTransition.TabEdge.allCases {
                                for face in DuctTransition.Face.allCases {
                                    if (edge == .left || edge == .right) { continue }
                                    ductwork.tabs[face, edge] = Tab(length: .half, type: .straight)
                                }
                            }
                        }) {
                            Text("All Top & Bottom")
                        }
                        Button(action: {
                            ductwork.tabs = Array(repeating: nil, count: 16)
                            for face in DuctTransition.Face.allCases {
                                ductwork.tabs[face, .top] = Tab(length: .half, type: .straight)
                            }
                        }) {
                            Text("Top tabs only")
                        }
                        Button(action: {
                            ductwork.tabs = Array(repeating: nil, count: 16)
                            for face in DuctTransition.Face.allCases {
                                ductwork.tabs[face, .bottom] = Tab(length: .half, type: .straight)
                            }
                        }) {
                            Text("Bottom tabs only")
                        }
                    }
                    Menu("Three Eighths") {
                        Button(action: {
                            ductwork.tabs = Array(repeating: nil, count: 16)
                            for edge in DuctTransition.TabEdge.allCases {
                                for face in DuctTransition.Face.allCases {
                                    if (edge == .left || edge == .right) && (face == .left || face == .right) { continue }
                                    ductwork.tabs[face, edge] = Tab(length: .threeEighth, type: .straight)
                                }
                            }
                        }) {
                            Text("All Edges, front and back horizontal")
                        }
                        Button(action: {
                            ductwork.tabs = Array(repeating: nil, count: 16)
                            for edge in DuctTransition.TabEdge.allCases {
                                for face in DuctTransition.Face.allCases {
                                    if (edge == .left || edge == .right) && (face == .front || face == .back) { continue }
                                    ductwork.tabs[face, edge] = Tab(length: .threeEighth, type: .straight)
                                }
                            }
                        }) {
                            Text("All Edges, left and right horizontal")
                        }
                        Button(action: {
                            ductwork.tabs = Array(repeating: nil, count: 16)
                            for edge in DuctTransition.TabEdge.allCases {
                                for face in DuctTransition.Face.allCases {
                                    if (edge == .left || edge == .right) { continue }
                                    ductwork.tabs[face, edge] = Tab(length: .threeEighth, type: .straight)
                                }
                            }
                        }) {
                            Text("All Top & Bottom")
                        }
                        Button(action: {
                            ductwork.tabs = Array(repeating: nil, count: 16)
                            for face in DuctTransition.Face.allCases {
                                ductwork.tabs[face, .top] = Tab(length: .threeEighth, type: .straight)
                            }
                        }) {
                            Text("Top tabs only")
                        }
                        Button(action: {
                            ductwork.tabs = Array(repeating: nil, count: 16)
                            for face in DuctTransition.Face.allCases {
                                ductwork.tabs[face, .bottom] = Tab(length: .threeEighth, type: .straight)
                            }
                        }) {
                            Text("Bottom tabs only")
                        }
                    }
                }
            }
        }
        
        
        var body: some View {
            GeometryReader { g in
                ZStack {
                    VStack {
                        Picker("Current Face", selection: $currentFace) {
                            ForEach(FacesAndAll.allCases) { f in
                                Text(f.localizedString).tag(f)
                            }
                        }
                        .pickerStyle(.segmented)
                        .border(Color.blue, width: debug ? 2 : 0)
                        .padding(.horizontal, 10)
                        .zIndex(5000)
                        
                        drawSideViews(g)
                        
                        Form {
                            drawMeasurements()
                            drawTabSelectors()
                        }
                        .border(Color.blue, width: debug ? 2 : 0)
                    }
                    .padding(.top)
                    .border(Color.blue, width: debug ? 2 : 0)
                    
                }
            }
            .border(Color.black, width: debug ? 2 : 0)
            .sheet(isPresented: $keyboardShown, content: {
                DuctTransition.CustomKeyboard(canBeNegative: currentCanBeNegative, text: $currentValue, shown: $keyboardShown, measure: $currentMeasurement, ductwork: $ductwork)
            })
            .onAppear {
                Task {
                    let cf = currentFace.actual
                    if ductwork.tabs[cf, currentTabEdge] != nil {
                        switch ductwork.tabs[cf, currentTabEdge]!.length {
                        case .inch: currentTabLength = .inch
                        case .half: currentTabLength = .half
                        case .threeEighth: currentTabLength = .threeEighth
                        }
                        switch ductwork.tabs[cf, currentTabEdge]!.type {
                        case .straight: currentTabType = .straight
                        case .tapered: currentTabType = .tapered
                        case .foldIn: currentTabType = .foldIn
                        case .foldOut: currentTabType = .foldOut
                        }
                    }
                }
            }
            .onChange(of: currentFace) { l in
                Task {
                    if currentFace == .all { return }
                    let cf = currentFace.actual
                    
                    if ductwork.tabs[cf, currentTabEdge] == nil {
                        currentTabType = .none
                        currentTabLength = .none
                    } else {
                        switch ductwork.tabs[cf, currentTabEdge]!.length {
                        case .inch: currentTabLength = .inch
                        case .half: currentTabLength = .half
                        case .threeEighth: currentTabLength = .threeEighth
                        }
                        switch ductwork.tabs[cf, currentTabEdge]!.type {
                        case .straight: currentTabType = .straight
                        case .tapered: currentTabType = .tapered
                        case .foldIn: currentTabType = .foldIn
                        case .foldOut: currentTabType = .foldOut
                        }
                    }
                }
            }
            .onChange(of: currentTabEdge) { l in
                Task {
                    if currentFace == .all { return }
                    let cf = currentFace.actual
                    if ductwork.tabs[cf, currentTabEdge] == nil {
                        currentTabType = .none
                        currentTabLength = .none
                    } else {
                        switch ductwork.tabs[cf, currentTabEdge]!.length {
                        case .inch: currentTabLength = .inch
                        case .half: currentTabLength = .half
                        case .threeEighth: currentTabLength = .threeEighth
                        }
                        switch ductwork.tabs[cf, currentTabEdge]!.type {
                        case .straight: currentTabType = .straight
                        case .tapered: currentTabType = .tapered
                        case .foldIn: currentTabType = .foldIn
                        case .foldOut: currentTabType = .foldOut
                        }
                    }
                }
            }
            .onChange(of: currentTabLength) { l in
                typealias Face = DuctTransition.Face
                typealias Edge = DuctTransition.TabEdge
                Task {
                    if currentFace == .all { return }
                    let cf = currentFace.actual
                    if l == .none {
                        currentTabType = .none
                        ductwork.tabs[cf, currentTabEdge] = nil
                    } else {
                        if ductwork.tabs[cf, currentTabEdge] == nil {
                            ductwork.tabs[cf, currentTabEdge] = DuctTransition.Tab(length: l.actual, type: .straight)
                            currentTabType = .straight
                            if currentTabEdge == .left {
                                switch cf {
                                case .front: ductwork.tabs[Face.left, Edge.right] = nil
                                case .left: ductwork.tabs[Face.back, Edge.right] = nil
                                case .back: ductwork.tabs[Face.right, Edge.right] = nil
                                case .right: ductwork.tabs[Face.front, Edge.right] = nil
                                }
                            } else if currentTabEdge == .right {
                                switch cf {
                                case .front: ductwork.tabs[Face.right, Edge.left] = nil
                                case .left: ductwork.tabs[Face.front, Edge.left] = nil
                                case .back: ductwork.tabs[Face.left, Edge.left] = nil
                                case .right: ductwork.tabs[Face.back, Edge.left] = nil
                                }
                            }
                        } else {
                            ductwork.tabs[cf, currentTabEdge]?.length = l.actual
                        }
                    }
                }
            }
            .onChange(of: currentTabType) { l in
                typealias Face = DuctTransition.Face
                typealias Edge = DuctTransition.TabEdge
                Task {
                    if currentFace == .all { return }
                    let cf = currentFace.actual
                    if l == .none {
                        currentTabLength = .none
                        ductwork.tabs[cf, currentTabEdge] = nil
                    } else {
                        if ductwork.tabs[cf, currentTabEdge] == nil {
                            ductwork.tabs[cf, currentTabEdge] = DuctTransition.Tab(length: .inch, type: l.actual)
                            currentTabLength = .inch
                            if currentTabEdge == .left {
                                switch cf {
                                case .front: ductwork.tabs[Face.left, Edge.right] = nil
                                case .left: ductwork.tabs[Face.back, Edge.right] = nil
                                case .back: ductwork.tabs[Face.right, Edge.right] = nil
                                case .right: ductwork.tabs[Face.front, Edge.right] = nil
                                }
                            } else if currentTabEdge == .right {
                                switch cf {
                                case .front: ductwork.tabs[Face.right, Edge.left] = nil
                                case .left: ductwork.tabs[Face.front, Edge.left] = nil
                                case .back: ductwork.tabs[Face.left, Edge.left] = nil
                                case .right: ductwork.tabs[Face.back, Edge.left] = nil
                                }
                            }
                        } else {
                            ductwork.tabs[cf, currentTabEdge]?.type = l.actual
                        }
                    }
                }
            }
            #if DEBUG
            .eraseToAnyView()
            #endif
        }
        #if DEBUG
        @ObservedObject var iO = injectionObserver
        #endif
    }
}
