//
//  LoadSharedView.swift
//  FieldFab
//
//  Created by Robert Sale on 10/17/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI

struct LoadSharedView: View {
    @EnvironmentObject var al: AppLogic
    @EnvironmentObject var lsd: LoadSharedDimensions
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader { g in
            VStack {
                Text("Are you sure you want to load this model?")
                Text("(Loading will overwrite any unsaved data)").font(.caption)
                Spacer()
                ScenePreview(geo: g, dimensions: lsd.dimensions, shown: $al.loadSharedSheetShown)
                    .frame(width: min(g.size.width, g.size.height), height: min(g.size.width, g.size.height))
                Spacer()
                HStack {
                    Button(action: {
                        al.loadSharedSheetShown = false
                    }, label: {
                        Text("Cancel")
                    })
                    .padding()
                    .background(AppColors.ControlBG[colorScheme])
                    .cornerRadius(15)
                    .foregroundColor(.red)
                    Spacer()
                    Button(action: {
                        al.width = Fraction(lsd.dimensions.width)
                        al.length = Fraction(lsd.dimensions.length)
                        al.depth = Fraction(lsd.dimensions.depth)
                        al.offsetX = Fraction(lsd.dimensions.offsetX)
                        al.offsetY = Fraction(lsd.dimensions.offsetY)
                        al.isTransition = lsd.dimensions.isTransition
                        al.tWidth = Fraction(lsd.dimensions.tWidth)
                        al.tDepth = Fraction(lsd.dimensions.tDepth)
                        al.tabs = lsd.dimensions.tabs
                        al.sessionName = lsd.dimensions.name
                        al.loadSharedSheetShown = false
                    }, label: {
                        Text("Confirm")
                    })
                    .padding()
                    .background(AppColors.ControlBG[colorScheme])
                    .cornerRadius(15)
                }.padding()
            }
        }
    }
}

struct LoadSharedView_Previews: PreviewProvider {
    static var previews: some View {
        LoadSharedView().environmentObject(AppLogic()).environmentObject(LoadSharedDimensions())
    }
}
