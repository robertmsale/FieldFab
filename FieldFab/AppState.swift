//
//  AppState.swift
//  FieldFab
//
//  Created by Robert Sale on 12/10/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI

struct SheetShownState: Codable {
    var share = false
    var tdMenu = false
    var help = false
    var helpWeb = false
    var about = false
    var arMenu = false
    var shared = false
    var load = false
    var advancedSettings = false
}

struct EventState: Codable {
    var measurementsChanged = false
    var textureChanged = false
    var arViewReset = false
}

struct DuctObjects: Codable {
    var active = 0
    var index: [Double] = []
    
}

final class AppState: ObservableObject {
    @Published var sheetsShown = SheetShownState()
    @Published var events = EventState()
}
