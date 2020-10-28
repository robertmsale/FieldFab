//
//  HelpView.swift
//  FieldFab
//
//  Created by Robert Sale on 10/2/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI

struct HelpView: View {
    @EnvironmentObject var al: AppLogic
    var body: some View {
        VStack {
            Image("HelpOrientation")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.blue).padding(.bottom, 40)
            Text("When you take your measurements refer to the image above.")
                .multilineTextAlignment(.center).padding(.bottom, 40)
            Text("If you are constructing a horizontal flow transition then you may use the rotation buttons in the Augmented Reality view to rotate your ductwork.")
                .multilineTextAlignment(.center).padding(.bottom, 40)
            Text("You must input all measurements as if the ductwork is being designed for an upflow application.")
                .multilineTextAlignment(.center).padding(.bottom, 40)
            Spacer()
            Button(action: { al.helpViewShown = false }, label: {
                Text("Return to Settings").font(.title)
            })
        }
    }
}

#if DEBUG
struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView().environmentObject(AppLogic())
    }
}
#endif
