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

    func getURL(_ id: UUID) -> URL? {
        var index = 0
        if dimensions.count < 1 { return nil }
        for i in 0...dimensions.count - 1 {
            if dimensions[i].id == id { index = i }
        }
        var url = "fieldfab://load?width=\(dimensions[index].width.description)&"
        url += "length=\(dimensions[index].length.description)&"
        url += "depth=\(dimensions[index].depth.description)&"
        url += "offsetX=\(dimensions[index].offsetX.description)&"
        url += "offsetY=\(dimensions[index].offsetY.description)&"
        url += "tWidth=\(dimensions[index].tWidth.description)&"
        url += "tDepth=\(dimensions[index].tDepth.description)&"
        url += "isTransition=\(dimensions[index].isTransition.description)&"
        url += "name=\(dimensions[index].name)&"
        url += "tabs=\(dimensions[index].tabs.toURL())"
        return URL(string: url)!
    }

    init() {
        let defaultDimensions = [
            DimensionsData(
                n: "16x20 to 20x20",
                c: Date(),
                t: TabsData(),
                l: 6,
                w: 16,
                d: 20,
                oX: 0,
                oY: 0,
                iT: true,
                tW: 20,
                tD: 20),
            DimensionsData(
                n: "16x20 to 20x20 w/ offset",
                c: Date(),
                t: TabsData(),
                l: 8,
                w: 16,
                d: 20,
                oX: 2,
                oY: 1,
                iT: true,
                tW: 20,
                tD: 20)
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
