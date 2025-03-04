//
//  FittingType.swift
//  FieldFab
//
//  Created by Robert Sale on 4/3/24.
//  Copyright © 2024 Robert Sale. All rights reserved.
//

import Foundation

extension FittingIndex {
    struct FittingType {
        let groupNumber: UInt8
        let groupLetter: String
        let equivalentLength: Int
        var displayName: String { "\(groupNumber)\(groupLetter)" }
        var sceneName: String {"\(displayName).scn"}
    }
}
