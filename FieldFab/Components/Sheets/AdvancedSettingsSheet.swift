//
//  ExperimentalFeaturesSheet.swift
//  FieldFab
//
//  Created by Robert Sale on 10/25/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI

struct FeatureToggle: View {
    @EnvironmentObject var al: AppLogic
    var feature: ExperimentalFeatures
    
    var body: some View {
        Toggle("", isOn: Binding(get: {
            al.experimentalFeaturesEnabled.contains(feature)
        }, set: {v in
            if v { al.experimentalFeaturesEnabled.insert(feature) }
            else { al.experimentalFeaturesEnabled.remove(feature) }
        }))
    }
}

struct AdvancedSettingsSheet: View {
    @EnvironmentObject var al: AppLogic
    var body: some View {
        ScrollView {
            VStack {
                Text("Advanced Settings").font(.title)
                Divider()
                VStack {
                    HStack {
                        Text("Experimental Features").font(.title3)
                        Spacer()
                    }
                    Divider()
                    HStack {
                        Text("New Layout Enabled")
                        Spacer()
                        FeatureToggle(feature: .newLayout)
                    }
                    HStack {
                        Text("Show Debug Info")
                        Spacer()
                        FeatureToggle(feature: .showDebugInfo)
                    }
                }.padding()
            }.padding(.vertical)
        }
    }
}

struct ExperimentalFeaturesSheet_Previews: PreviewProvider {
    static var previews: some View {
        AdvancedSettingsSheet().environmentObject(AppLogic())
    }
}
