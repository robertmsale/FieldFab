//
//  DB.swift
//  FieldFab
//
//  Created by Robert Sale on 10/1/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI
import Disk

class DB: ObservableObject {
    @Published var dimensions: [DimensionsData]
    
    func persist() {
        do {
            try Disk.save(self.dimensions, to: .caches, as: "saved-dimensions.json")
        } catch {
            print("Data could not be saved")
        }
    }
    
    init() {
        let defaultDimensions = [
            DimensionsData(
                name: "16x20 to 20x20",
                createdOn: Date(),
                tabs: TabsData(),
                length: 6,
                width: 16,
                depth: 20,
                offsetX: 0,
                offsetY: 0,
                isTransition: true,
                tWidth: 20,
                tDepth: 20,
                id: UUID()),
            DimensionsData(
                name: "16x20 to 20x20 w/ offset",
                createdOn: Date(),
                tabs: TabsData(),
                length: 8,
                width: 16,
                depth: 20,
                offsetX: 2,
                offsetY: 1,
                isTransition: true,
                tWidth: 20,
                tDepth: 20,
                id: UUID()),
        ]
        do {
            self.dimensions = try Disk.retrieve("saved-dimensions.json", from: .caches, as: [DimensionsData].self)
            if self.dimensions.count < 1 {
                self.dimensions = defaultDimensions
                self.persist()
            }
        } catch {
            print("cache could not be retreived")
            do {
                try Disk.remove("saved-dimensions.json", from: .caches)
                self.dimensions = defaultDimensions
                self.persist()
            } catch {
                print("cache could not be removed")
                self.dimensions = defaultDimensions
            }
        }
    }
    init(_ db: [DimensionsData]) {
        self.dimensions = db
    }
}
