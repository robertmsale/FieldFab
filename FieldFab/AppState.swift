//
//  AppState.swift
//  FieldFab
//
//  Created by Robert Sale on 12/10/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI
import Disk
import SceneKit
import StringFix

protocol MockState: Equatable {}
protocol MockableStateObject: ObservableObject {
    associatedtype MockDataEnum = MockState
    associatedtype StateObj: MockableStateObject
    static func loadWith(mockState: MockDataEnum) -> StateObj
}

class StateLoader {
    static func loadInto<Content: View, ObservableObj: MockableStateObject>(view: Content, object: ObservableObj) -> some View {
        return view.environmentObject(object)
    }
}


final class AppState: MockableStateObject {
    enum MockCases: MockState {
        case production, development
    }
    static func loadWith(mockState: MockCases) -> AppState {
        switch mockState {
        case .production: return AppState()
        case .development: return AppState()
        }
    }
    
    @Published var aboutSheetShown = false
    @Published var navPath = NavigationPath()
    @Published var currentModule: AppView.AvailableModules? = nil
    
}
