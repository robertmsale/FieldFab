//
//  LoadDuctworkView.swift
//  FieldFab
//
//  Created by Robert Sale on 9/30/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI

struct LoadDuctworkView: View {
    @EnvironmentObject var al: AppLogic
    @EnvironmentObject var db: DB
    @Environment(\.colorScheme) var colorScheme
    
    func renderList() -> AnyView {
        let data = db.dimensions.sorted(by: {(prev, next) in
            prev.createdOn > next.createdOn
        })
        if data.count == 0 {
            return AnyView(Text("You currently have no saved sessions").font(.title2).padding(.top, 40))
        }
        return AnyView(ForEach(0...data.count - 1, id: \.self) { d in
            LoadDuctworkListItemView(dimensions: data[d])
        })
    }
    
    var body: some View {
        ScrollView {
            VStack {
                renderList()
                Button(action: {
                    al.loadDuctworkViewShown = false
                }, label: {
                    Text("Cancel")
                })
                .font(.title3)
                .foregroundColor(.red)
                .padding()
                .background(AppColors.ControlBG[colorScheme])
            }
            .padding(.horizontal)
            .padding(.top)
        }
    }
}

#if DEBUG
struct LoadDuctworkView_Previews: PreviewProvider {
    static var previews: some View {
        let db = DB([
            DimensionsData(
                name: "Derpa",
                createdOn: Date(),
                tabs: TabsData(),
                length: 5,
                width: 16,
                depth: 20,
                offsetX: 1,
                offsetY: 0,
                isTransition: true,
                tWidth: 20,
                tDepth: 16,
                id: UUID())
        ])
        
        return LoadDuctworkView()
                .environmentObject(db)
                .environmentObject(AppLogic())
    }
}
#endif
